import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/labs_vitals/data/gemini_lab_report_extractor.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_document_picker.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/screens/lab_reports_screen.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

class _FakeMultiPageCameraPicker implements LabDocumentPicker {
  int _call = 0;

  @override
  Future<PickedLabDocument?> pickPdfOrImage() async => null;

  @override
  Future<PickedLabDocument?> pickCameraPhoto() async {
    _call++;
    return PickedLabDocument(
      fileName: 'lab_page_$_call.jpg',
      mimeType: 'image/jpeg',
      bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, _call]),
    );
  }
}

class _FakeMultiPageAiExtractor implements LabDocumentAiExtractor {
  @override
  bool get isAvailable => true;

  @override
  Future<AiLabExtractionResult> extractFromDocument(
    PickedLabDocument document,
  ) async {
    if (document.fileName.contains('page_1')) {
      return AiLabExtractionResult(
        hospitalName: 'Merkez Devlet Hastanesi',
        detectedDate: DateTime(2026, 11, 20),
        items: [
          LabReportAnalyzer.evaluateExtractedItem(
            rawName: 'Hemoglobin',
            value: 10.6,
            unit: 'g/dL',
            refMin: 12.0,
            refMax: 16.0,
          ),
          LabReportAnalyzer.evaluateExtractedItem(
            rawName: 'Glukoz',
            value: 92,
            unit: 'mg/dL',
            refMin: 70,
            refMax: 99,
          ),
        ],
      );
    }
    return AiLabExtractionResult(
      items: [
        LabReportAnalyzer.evaluateExtractedItem(
          rawName: 'Vitamin D',
          value: 45,
          unit: 'nmol/L', // SI unit from abroad -> ~18.0 ng/mL (low)
        ),
      ],
    );
  }
}

void main() {
  group('International Hospital Lab Parsers & SI Unit Normalization', () {
    test('parses US Quest/LabCorp format with H/L flags, thousands separators, and BUN conversion', () {
      const questText = '''
Patient Name: John Doe
Collected: 11/15/2026
Glucose 142 H mg/dL 70-99
Platelets 245,000 /uL 150,000-450,000
WBC 6,800 /uL 4,000-10,500
BUN 18 mg/dL 7-20
Total Bilirubin 1.8 HIGH mg/dL 0.1-1.2
''';
      final parsed = LabReportAnalyzer.parseReportText(questText);
      final byCode = {for (final i in parsed.items) i.code: i};

      expect(byCode['GLU']?.value, 142);
      expect(byCode['GLU']?.status, LabStatus.high);

      // 245,000 /uL -> 245.0 10^3/uL (Normal!)
      expect(byCode['PLT']?.value, closeTo(245.0, 0.2));
      expect(byCode['PLT']?.status, LabStatus.normal);

      // 6,800 /uL -> 6.8 10^3/uL (Normal!)
      expect(byCode['WBC']?.value, closeTo(6.8, 0.2));
      expect(byCode['WBC']?.status, LabStatus.normal);

      // BUN 18 mg/dL -> Urea ~38.6 mg/dL (Normal!)
      expect(byCode['UREA']?.value, closeTo(38.6, 0.5));
      expect(byCode['UREA']?.status, LabStatus.normal);

      expect(byCode['TBIL']?.value, 1.8);
      expect(byCode['TBIL']?.status, LabStatus.high);
    });

    test('parses UK NHS SI-unit format accurately without false critical alarms', () {
      const nhsText = '''
Haemoglobin 138 g/L (120 - 160)
Glucose 5.4 mmol/L (3.9 - 5.5)
HbA1c 38 mmol/mol (< 48)
Creatinine 82 umol/L (60 - 110)
Cholesterol, Total 4.8 mmol/L (< 5.2)
25-Hydroxy Vitamin D 85 nmol/L (50 - 125)
''';
      final parsed = LabReportAnalyzer.parseReportText(nhsText);
      final byCode = {for (final i in parsed.items) i.code: i};

      // 138 g/L -> 13.8 g/dL (Normal)
      expect(byCode['HGB']?.value, closeTo(13.8, 0.1));
      expect(byCode['HGB']?.status, LabStatus.normal);

      // 5.4 mmol/L -> 97.3 mg/dL (Normal, NOT falsely criticalLow!)
      expect(byCode['GLU']?.value, closeTo(97.3, 0.5));
      expect(byCode['GLU']?.status, LabStatus.normal);

      // 38 mmol/mol IFCC -> 5.6% NGSP (Normal)
      expect(byCode['HBA1C']?.value, closeTo(5.6, 0.15));
      expect(byCode['HBA1C']?.status, LabStatus.normal);

      // 82 umol/L -> 0.93 mg/dL (Normal)
      expect(byCode['CREA']?.value, closeTo(0.93, 0.05));
      expect(byCode['CREA']?.status, LabStatus.normal);

      // 4.8 mmol/L -> 185.6 mg/dL (Normal)
      expect(byCode['TOTAL_CHOL']?.value, closeTo(185.6, 1.0));
      expect(byCode['TOTAL_CHOL']?.status, LabStatus.normal);

      // 85 nmol/L -> 34.1 ng/mL (Normal)
      expect(byCode['VITD']?.value, closeTo(34.1, 0.5));
      expect(byCode['VITD']?.status, LabStatus.normal);
    });

    test('parses German, Russian, and Chinese Unicode lab reports cleanly', () {
      const intlText = '''
Hämoglobin 14,2 g/dL [12,0 - 16,0]
Glukose 5,2 mmol/L [3,9 - 5,5]
Холестерин общий 5,0 ммоль/л < 5,2
Гемоглобин 135 г/л 120-160
血糖 5.4 mmol/L 3.9-6.1
''';
      final parsed = LabReportAnalyzer.parseReportText(intlText);
      final byCode = {for (final i in parsed.items) i.code: i};

      expect(byCode['HGB'], isNotNull);
      expect(byCode['HGB']!.status, LabStatus.normal);
      expect(byCode['GLU'], isNotNull);
      expect(byCode['GLU']!.status, LabStatus.normal);
      expect(byCode['TOTAL_CHOL'], isNotNull);
      expect(byCode['TOTAL_CHOL']!.value, closeTo(193.4, 1.0));
    });

    test('identifies missing core blood tests accurately', () {
      final partialItems = [
        LabReportAnalyzer.evaluateExtractedItem(rawName: 'HGB', value: 13.5),
        LabReportAnalyzer.evaluateExtractedItem(rawName: 'GLU', value: 90),
      ];
      final missing = LabReportAnalyzer.findMissingCoreParameters(partialItems);
      final missingCodes = missing.map((e) => e.code).toSet();

      expect(missingCodes, isNot(contains('HGB')));
      expect(missingCodes, isNot(contains('GLU')));
      expect(missingCodes, containsAll(['WBC', 'PLT', 'HBA1C', 'TSH', 'FERRITIN', 'B12', 'VITD']));
    });
  });

  group('Senior-Friendly Bulleted Report UI, Large Text & Multi-Page Camera Scan', () {
    testWidgets(
      'scans 2 camera pages, merges SI + Turkish tests, and displays elderly-friendly bulleted detail with Large Text & missing tests',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final repo = LabsVitalsRepository();

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LabReportsScreen(
              repository: repo,
              documentPicker: _FakeMultiPageCameraPicker(),
              aiExtractor: _FakeMultiPageAiExtractor(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open Add Report sheet
        await tester.tap(find.text('İlk Tahlil / PDF Raporunu Ekle'));
        await tester.pumpAndSettle();

        // Capture Page 1 via Camera
        await tester.tap(find.byKey(const Key('lab_camera_scan_btn')));
        await tester.pumpAndSettle();

        // Button now offers scanning another page! Capture Page 2
        expect(find.text('Başka Sayfa Çek'), findsOneWidget);
        await tester.tap(find.byKey(const Key('lab_camera_scan_btn')));
        await tester.pumpAndSettle();

        expect(find.textContaining('2 sayfa okundu'), findsOneWidget);

        // Save report -> automatically opens senior-friendly detail sheet
        await tester.tap(find.text('Değerlendir ve Tarihli Kaydet'));
        await tester.pumpAndSettle();

        // Senior-friendly overview + Large Text toggle
        expect(find.text('Özetle Durumunuz'), findsOneWidget);
        expect(find.text('Büyük Yazı'), findsOneWidget);
        await tester.tap(find.byKey(const Key('lab_large_text_toggle')));
        await tester.pumpAndSettle();
        expect(find.text('Büyük Yazı: Açık'), findsOneWidget);

        // Attention-first section with plain-language bullets
        await tester.scrollUntilVisible(
          find.text('Dikkat Etmeniz Gereken Değerler'),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('Dikkat Etmeniz Gereken Değerler'), findsOneWidget);
        expect(find.text('• Ne anlama gelir?'), findsWidgets);
        expect(find.text('• Ne yapmalısınız?'), findsWidgets);

        // Normal section
        await tester.scrollUntilVisible(
          find.text('Normal Çıkan Değerler (İçiniz Rahat Olsun)'),
          220,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('Normal Çıkan Değerler (İçiniz Rahat Olsun)'), findsOneWidget);

        // Explicit Missing Core Tests section ("Raporda yer almıyor")
        await tester.scrollUntilVisible(
          find.text('Bu Raporda Yer Almayan Temel Testler'),
          220,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('Bu Raporda Yer Almayan Temel Testler'), findsOneWidget);
        expect(find.textContaining('Raporda yer almıyor'), findsWidgets);
      },
    );
  });
}
