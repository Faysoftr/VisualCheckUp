import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_document_picker.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/screens/lab_reports_screen.dart';

Uint8List _buildSyntheticFlatePdf(List<String> lines) {
  final contentStream = StringBuffer('BT\n/F1 12 Tf\n');
  for (final line in lines) {
    final escaped = line.replaceAll('(', r'\(').replaceAll(')', r'\)');
    contentStream.writeln('($escaped) Tj');
  }
  contentStream.writeln('ET');

  final compressed = zlib.encode(utf8.encode(contentStream.toString()));
  final bytes = BytesBuilder();
  bytes.add(latin1.encode('%PDF-1.4\n1 0 obj\n<< /Filter /FlateDecode /Length ${compressed.length} >>\nstream\n'));
  bytes.add(compressed);
  bytes.add(latin1.encode('\nendstream\nendobj\n%%EOF'));
  return bytes.toBytes();
}

class _FakeLabDocumentPicker implements LabDocumentPicker {
  const _FakeLabDocumentPicker(this.doc);

  final PickedLabDocument doc;

  @override
  Future<PickedLabDocument?> pickPdfOrImage() async => doc;

  @override
  Future<PickedLabDocument?> pickCameraPhoto() async => doc;
}

void main() {
  group('LabReportAnalyzer & PdfTextExtractor', () {
    test('extracts lab parameters and date from a FlateDecode PDF on-device', () {
      final pdfBytes = _buildSyntheticFlatePdf(const [
        'Tarih: 18.05.2026',
        'Hemoglobin (HGB): 10.4 g/dL',
        'Ferritin: 11 ng/mL',
        'TSH: 6.2 mIU/L',
      ]);

      final extracted = PdfTextExtractor.extractText(pdfBytes);
      expect(extracted, contains('Hemoglobin'));

      final parsed = LabReportAnalyzer.parseReportText(extracted);
      expect(parsed.detectedDate, DateTime(2026, 5, 18));
      expect(parsed.items, hasLength(3));
      final byCode = {for (final i in parsed.items) i.code: i};
      expect(byCode['HGB']!.status, LabStatus.low);
      expect(byCode['FERRITIN']!.status, LabStatus.low);
      expect(byCode['TSH']!.status, LabStatus.high);
    });

    test('explains hospital diagnosis + user complaint alongside blood test results and supports blank diagnosis', () {
      const sampleText = '''
      Tarih: 14.04.2026
      Hemoglobin (HGB): 10,6 g/dL
      Ferritin: 12 ng/mL
      Açlık Glukoz: 132 mg/dL
      TSH: 5.4 mIU/L
      Vitamin D: 38 ng/mL
      ''';

      final parsed = LabReportAnalyzer.parseReportText(sampleText);

      // 1) With hospital diagnosis + user complaint
      final contextualReport = LabReportAnalyzer.buildReport(
        title: 'e-Nabız Kan Tahlili',
        reportDate: parsed.detectedDate!,
        source: LabReportSource.pdfUpload,
        items: parsed.items,
        hospitalDiagnosis: 'Hipotiroidi ve Demir eksikliği anemisi',
        userComplaintNote: 'Sürekli halsizim ve saçlarım dökülüyor',
        attachmentFileName: 'tahlil_nisan.pdf',
        attachmentMimeType: 'application/pdf',
      );

      expect(contextualReport.hospitalDiagnosis, contains('Hipotiroidi'));
      expect(contextualReport.userComplaintNote, contains('halsizim'));
      expect(
        contextualReport.contextualInterpretation,
        contains('Tiroid bezinin'),
      );
      expect(
        contextualReport.contextualInterpretation,
        contains('kırmızı kan hücrelerinin'),
      );
      expect(
        contextualReport.contextualInterpretation,
        contains('halsizlik / yorgunluk'),
      );
      expect(contextualReport.followUpQuestions, isNotEmpty);

      final shareText = LabReportAnalyzer.formatReportForDoctor(contextualReport);
      expect(shareText, contains('tahlil_nisan.pdf'));
      expect(shareText, contains('Hipotiroidi'));

      final aiPrompt = LabReportAnalyzer.buildContextualAiPrompt(
        items: parsed.items,
        hospitalDiagnosis: 'Hipotiroidi',
        userComplaintNote: 'Çok yorgunum',
        attachmentFileName: 'tahlil_nisan.pdf',
      );
      expect(aiPrompt, contains('Hipotiroidi'));
      expect(aiPrompt, contains('Çok yorgunum'));
      expect(aiPrompt, contains('TSH=5.4'));

      // 2) With BLANK diagnosis and BLANK user complaint
      final standaloneReport = LabReportAnalyzer.buildReport(
        title: 'Sadece Kan Testi',
        reportDate: parsed.detectedDate!,
        source: LabReportSource.pastedText,
        items: parsed.items,
        hospitalDiagnosis: '   ',
        userComplaintNote: '',
      );

      expect(standaloneReport.hospitalDiagnosis, isNull);
      expect(standaloneReport.userComplaintNote, isNull);
      expect(
        standaloneReport.contextualInterpretation,
        contains('Yalnızca kan sonuçlarına göre'),
      );
    });

    test('computes chronological parameter trends and deltas across dated reports', () {
      final hgbSpec = LabReportAnalyzer.specByCode('HGB')!;
      final r1 = LabReportAnalyzer.buildReport(
        title: 'Ocak Tahlili',
        reportDate: DateTime(2026, 1, 10),
        source: LabReportSource.manual,
        items: [
          LabReportAnalyzer.evaluateKnownParameter(spec: hgbSpec, value: 10.8),
        ],
      );
      final r2 = LabReportAnalyzer.buildReport(
        title: 'Nisan Tahlili',
        reportDate: DateTime(2026, 4, 10),
        source: LabReportSource.manual,
        items: [
          LabReportAnalyzer.evaluateKnownParameter(spec: hgbSpec, value: 12.6),
        ],
      );

      final trends = LabReportAnalyzer.computeParameterTrends([r2, r1]);
      expect(trends, hasLength(1));
      final hgbTrend = trends.first;
      expect(hgbTrend.points.first.value, 10.8);
      expect(hgbTrend.latest.value, 12.6);
      expect(hgbTrend.delta, closeTo(1.8, 0.01));
      expect(hgbTrend.deltaSummary, '+1.8 g/dL');
    });
  });

  group('BloodPressureReading & BloodSugarReading classification & storage', () {
    test('classifies BP and fasting/post-meal blood sugar ranges accurately', () {
      final idealBp = BloodPressureReading(
        id: 'bp1',
        recordedAt: DateTime(2026, 5, 1, 9, 0),
        systolic: 116,
        diastolic: 74,
        pulse: 68,
      );
      expect(idealBp.category, BloodPressureCategory.normal);

      final crisisBp = BloodPressureReading(
        id: 'bp2',
        recordedAt: DateTime(2026, 5, 1, 18, 0),
        systolic: 186,
        diastolic: 115,
      );
      expect(crisisBp.category, BloodPressureCategory.crisis);

      final hypoSugar = BloodSugarReading(
        id: 's1',
        recordedAt: DateTime(2026, 5, 1, 8, 0),
        valueMgDl: 62,
        measurementType: SugarMeasurementType.fasting,
      );
      expect(hypoSugar.category, BloodSugarCategory.hypoglycemia);

      final normalPostMeal = BloodSugarReading(
        id: 's2',
        recordedAt: DateTime(2026, 5, 1, 14, 0),
        valueMgDl: 128,
        measurementType: SugarMeasurementType.postMeal,
      );
      expect(normalPostMeal.category, BloodSugarCategory.normal);

      final highFasting = BloodSugarReading(
        id: 's3',
        recordedAt: DateTime(2026, 5, 2, 8, 0),
        valueMgDl: 142,
        measurementType: SugarMeasurementType.fasting,
      );
      expect(highFasting.category, BloodSugarCategory.high);
    });

    test('LabsVitalsRepository persists and clears lab reports (with diagnosis/attachment), BP, and sugar logs', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = LabsVitalsRepository();

      final parsed = LabReportAnalyzer.parseReportText('Hemoglobin: 13.5\nGlukoz: 92');
      await repo.saveLabReport(
        LabReportAnalyzer.buildReport(
          title: 'Kontrol',
          reportDate: DateTime(2026, 5, 1),
          source: LabReportSource.pdfUpload,
          items: parsed.items,
          hospitalDiagnosis: 'Grade 1 hepatosteatoz',
          userComplaintNote: 'Kontrol amaçlı',
          attachmentFileName: 'rapor.pdf',
          attachmentMimeType: 'application/pdf',
        ),
      );
      await repo.saveBloodPressure(
        BloodPressureReading(
          id: 'bp_test',
          recordedAt: DateTime(2026, 5, 1, 10, 0),
          systolic: 124,
          diastolic: 79,
          pulse: 72,
        ),
      );
      await repo.saveBloodSugar(
        BloodSugarReading(
          id: 'sugar_test',
          recordedAt: DateTime(2026, 5, 1, 8, 30),
          valueMgDl: 94,
          measurementType: SugarMeasurementType.fasting,
        ),
      );

      final savedLabs = await repo.loadLabReports();
      expect(savedLabs, hasLength(1));
      expect(savedLabs.first.hospitalDiagnosis, 'Grade 1 hepatosteatoz');
      expect(savedLabs.first.attachmentFileName, 'rapor.pdf');
      expect(await repo.loadBloodPressureReadings(), hasLength(1));
      expect(await repo.loadBloodSugarReadings(), hasLength(1));

      await repo.clearAll();
      expect(await repo.loadLabReports(), isEmpty);
      expect(await repo.loadBloodPressureReadings(), isEmpty);
      expect(await repo.loadBloodSugarReadings(), isEmpty);
    });
  });

  group('Widget flows — PDF/JPG Lab Upload, Diagnosis Interpretation & Vitals Tracker', () {
    testWidgets('uploads PDF, auto-reads blood values, interprets optional hospital diagnosis & complaint', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repo = LabsVitalsRepository();
      final fakePdfBytes = _buildSyntheticFlatePdf(const [
        'Tarih: 18.05.2026',
        'Hemoglobin: 10.5 g/dL',
        'TSH: 5.8 mIU/L',
      ]);
      final picker = _FakeLabDocumentPicker(
        PickedLabDocument(
          fileName: 'enabiz_tahlil.pdf',
          mimeType: 'application/pdf',
          bytes: fakePdfBytes,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LabReportsScreen(
            repository: repo,
            documentPicker: picker,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rapor / Kan Testi Ekle'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('PDF veya JPG Yükle'));
      await tester.pumpAndSettle();

      expect(find.textContaining('2 tahlil parametresi otomatik ayrıştırıldı'), findsOneWidget);
      expect(find.text('PDF • enabiz_tahlil.pdf'), findsOneWidget);

      // Enter optional hospital diagnosis and optional user complaint.
      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Hastane / Doktor Teşhisi (Boş Bırakılabilir)',
        ),
        'Hipotiroidi',
      );
      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Şikayetiniz / Kendi Metniniz (Boş Bırakılabilir)',
        ),
        'Çok halsizim ve üşüyorum',
      );

      await tester.tap(find.text('Değerlendir ve Tarihli Kaydet'));
      await tester.pumpAndSettle();

      // Detail sheet shows PDF attachment, diagnosis, and plain-Turkish interpretation.
      expect(find.text('enabiz_tahlil.pdf'), findsOneWidget);
      expect(find.text('Girilen Hastane / Doktor Teşhisi'), findsOneWidget);
      expect(find.text('Anlaşılır Değerlendirme & Yorum'), findsOneWidget);
      expect(find.textContaining('Tiroid bezinin'), findsOneWidget);
      expect(await repo.loadLabReports(), hasLength(1));
    });

    testWidgets('logs Blood Pressure and Blood Sugar readings with trends from HomeScreen', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'visualcheckup_disclaimer_v1': true,
      });
      final repo = LabsVitalsRepository();

      await tester.pumpWidget(
        VisualCheckUpApp(
          labsVitalsRepository: repo,
          initialUser: const AuthUser(
            id: 'u_vitals',
            displayName: 'Mert Aydın',
            provider: AuthProviderType.apple,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Tansiyon & Şeker'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Tansiyon & Şeker'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tansiyon & Şeker'));
      await tester.pumpAndSettle();

      // Add a BP reading
      await tester.tap(find.text('Tansiyon Ekle'));
      await tester.pumpAndSettle();
      final bpFields = find.byType(TextField);
      await tester.enterText(bpFields.at(0), '128');
      await tester.enterText(bpFields.at(1), '82');
      await tester.enterText(bpFields.at(2), '74');
      await tester.ensureVisible(find.text('Tansiyonu Kaydet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tansiyonu Kaydet'));
      await tester.pumpAndSettle();

      expect(find.text('128/82 mmHg'), findsOneWidget);
      expect(await repo.loadBloodPressureReadings(), hasLength(1));

      // Switch to Blood Sugar tab and add a reading
      await tester.tap(find.text('Kan Şekeri'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Şeker Ekle'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '112');
      await tester.ensureVisible(find.text('Kan Şekerini Kaydet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kan Şekerini Kaydet'));
      await tester.pumpAndSettle();

      expect(find.text('112 mg/dL'), findsOneWidget);
      expect(await repo.loadBloodSugarReadings(), hasLength(1));
    });
  });
}
