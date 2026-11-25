import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/labs_vitals/data/gemini_lab_report_extractor.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_document_picker.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_pdf_generator.dart';
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

      expect(find.textContaining('2 tahlil değeri tabloya aktarıldı'), findsOneWidget);
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
      await tester.scrollUntilVisible(
        find.text('Anlaşılır Değerlendirme & Yorum'),
        180,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Anlaşılır Değerlendirme & Yorum'), findsOneWidget);
      expect(find.textContaining('Tiroid bezinin'), findsOneWidget);
      expect(await repo.loadLabReports(), hasLength(1));
    });

    testWidgets('logs Blood Pressure and Blood Sugar readings with trends from HomeScreen', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('tr')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
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

    test('parses complete real 2-page e-Nabız report + unknown custom hospital parameters', () {
      const realEnabizText = '''
T.C.SAĞLIK BAKANLIĞI
Sağlık Bilgi Sistemleri Genel Müdürlüğü
Adı/Soyadı: SEÇİL YÜKSEK Cinsiyet: Kadın
Tarih: 07.05.2026 Doğum Tarihi: 27.04.1988
Sağlık Tesisi: T.C. SAĞLIK BAKANLIĞI ÇUBUK HALİL ŞIVGIN DEVLET HASTANESİ
Tarih Tahlil Sonuç Sonuç Birimi Referans Değeri
07.05.2026
10:52
ALT 12 U/L 0 - 35
AST 15 U/L 0 - 35
Demir 127 ug/L 60 - 180
Demir Bağlama 304 µg/dL 155 - 355
Ferritin 34 µg/L 13 - 232
Folat 14,3 µg/L 3,21 - 20
Glukoz 85 mg/dL 74 - 100
HbA1c 4,8 % 4 - 6,5
HDL Kolesterol 49 mg/dL < 50 *
Total Kolesterol 141 mg/dL 0 - 200
Trigliserit 47 mg/dL 0 - 150
Üre 17 mg/dL 17 - 43
Vitamin B12 291 ng/L 220 - 1100
07.05.2026
10:52
TAM KAN (HEMOGRAM)
BAS# 0,02 10^3/mm^3 0,00 - 0,10
BAS% 0,2 % 0 - 1
EOS# 0,06 10^3/mm^3 0,02 - 0,70
EOS% 0,7 % 0,50 - 7
HCT 40,7 % 36 - 48
HGB 13,7 g/dL 11 - 17
LYM# 1,5 10^3/mm^3 0,80 - 4
LYM% 18,4 % 20 - 40
MCH 28,7 pg 27 - 34
MCHC 33,7 mmol/L 32 - 36
MCV 85,6 fL 80 - 100
MON# 0,4 10^3/mm^3 0,12 - 1,20
MON% 5,5 % 3 - 12
MPV 10,8 fL 6,50 - 12
NEU# 6 10^3/mm^3 2 - 7
NEU% 75,2 % 50 - 70
PCT 0,29 %
0,108 - 0,282
PDW 15,7 % 15 - 17
PLT 266 10^3/mm^3 100 - 380
RBC 4,76 10^6/mm^3 3,50 - 5
RDW 13,1 % 11 - 16
WBC 8,03 10^3/mm^3 4 - 10
07.05.2026
10:52
KREATININ
eGFR 111 mL/dk/1.73
m2
60 - 120
Kreatinin 0,68 mg/dL 0,66 - 1,09
07.05.2026
10:52
LDL KOLESTROL
LDL Kolesterol 80 mg/dL 0 - 130
LDL Kolesterol(Hesaplama 83 mg/dL
Homosistein 16,4 µmol/L 5 - 15
enabiz.gov.tr
0 850 240 03 03
Sayfa 1 / 2
''';

      final parsed = LabReportAnalyzer.parseReportText(realEnabizText);
      expect(parsed.detectedDate, DateTime(2026, 5, 7));
      expect(
        parsed.detectedHospital,
        contains('ÇUBUK HALİL ŞIVGIN DEVLET HASTANESİ'),
      );

      final byCode = {for (final i in parsed.items) i.code: i};
      // All 38 e-Nabız rows + 1 custom unknown parameter = 39 parameters!
      expect(parsed.items.length, greaterThanOrEqualTo(37));

      // Check wrapped rows & special flags
      expect(byCode['ALT']?.value, 12);
      expect(byCode['IRON']?.value, 127);
      expect(byCode['TIBC']?.value, 304);
      expect(byCode['FOLATE']?.value, closeTo(14.3, 0.01));
      expect(byCode['HDL']?.value, 49);
      expect(byCode['HDL']?.status, LabStatus.low);
      expect(byCode['LYM_PCT']?.value, closeTo(18.4, 0.01));
      expect(byCode['LYM_PCT']?.status, LabStatus.low);
      expect(byCode['LYM_ABS']?.value, closeTo(1.5, 0.01));
      expect(byCode['NEU_PCT']?.value, closeTo(75.2, 0.01));
      expect(byCode['NEU_PCT']?.status, LabStatus.high);
      expect(byCode['PCT']?.value, closeTo(0.29, 0.001));
      expect(byCode['PCT']?.refMax, closeTo(0.282, 0.001));
      expect(byCode['PCT']?.status, LabStatus.high);
      expect(byCode['EGFR']?.value, 111);
      expect(byCode['EGFR']?.status, LabStatus.normal);
      expect(byCode['CREA']?.value, closeTo(0.68, 0.01));
      expect(byCode['LDL']?.value, 80);

      // Custom unknown parameter not in built-in catalog
      expect(byCode['HOMOSISTEIN']?.value, closeTo(16.4, 0.01));
      expect(byCode['HOMOSISTEIN']?.status, LabStatus.high);
    });

    test('Syncfusion PDF extractor reads real multi-line PDF generated on-device', () async {
      final document = sf.PdfDocument();
      final page = document.pages.add();
      page.graphics.drawString(
        'Tarih: 07.05.2026\nALT 12 U/L 0 - 35\nFerritin 34 ug/L 13 - 232\nHomosistein 16,4 umol/L 5 - 15',
        sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 12),
      );
      final bytes = Uint8List.fromList(await document.save());
      document.dispose();

      final extracted = PdfTextExtractor.extractText(bytes);
      final parsed = LabReportAnalyzer.parseReportText(extracted);
      final codes = parsed.items.map((e) => e.code).toSet();
      expect(codes, containsAll(['ALT', 'FERRITIN', 'HOMOSISTEIN']));
      expect(parsed.detectedDate, DateTime(2026, 5, 7));
    });

    test('GeminiLabReportExtractor.parseAiJson maps any hospital JSON into canonical items', () {
      const sampleJson = '''
{
  "hospitalName": "Özel Sağlık Hastanesi",
  "reportDate": "2026-06-15",
  "items": [
    {"name": "ALT", "value": 18, "unit": "U/L", "refMin": 0, "refMax": 35},
    {"name": "LYM%", "value": 24.5, "unit": "%", "refMin": 20, "refMax": 40},
    {"name": "D-Dimer", "value": 620, "unit": "ng/mL", "refMin": 0, "refMax": 500}
  ]
}
''';
      final result = GeminiLabReportExtractor.parseAiJson(sampleJson);
      expect(result.hospitalName, 'Özel Sağlık Hastanesi');
      expect(result.detectedDate, DateTime(2026, 6, 15));
      expect(result.items, hasLength(3));
      final byCode = {for (final i in result.items) i.code: i};
      expect(byCode['ALT']?.status, LabStatus.normal);
      expect(byCode['LYM_PCT']?.status, LabStatus.normal);
      expect(byCode['D_DIMER']?.status, LabStatus.high);
    });

    test('reassembles vertical cell-per-line PDF text and never mistakes units for parameter names', () {
      const verticalEnabiz = '''
Tarih: 07.05.2026
Doğum Tarihi: 27.04.1988
Demir
127
ug/L
60 - 180
Demir Bağlama
304
µg/dL
155 - 355
Folat
14,3
µg/L
3,21 - 20
HCT
40,7
%
36 - 48
HGB
13,7
g/dL
11 - 17
WBC
8,03
10^3/mm^3
4 - 10
''';
      final parsed = LabReportAnalyzer.parseReportText(verticalEnabiz);
      expect(parsed.detectedDate, DateTime(2026, 5, 7));
      final byCode = {for (final i in parsed.items) i.code: i};
      expect(byCode.keys, containsAll(['IRON', 'TIBC', 'FOLATE', 'HCT', 'HGB', 'WBC']));
      expect(byCode['IRON']?.value, 127);
      expect(byCode['TIBC']?.value, 304);
      expect(byCode['FOLATE']?.value, closeTo(14.3, 0.01));
      expect(byCode['HGB']?.value, closeTo(13.7, 0.01));
      expect(byCode['HCT']?.value, closeTo(40.7, 0.01));
      // Ensure NO unit token leaked in as a parameter name
      for (final item in parsed.items) {
        expect(item.name.toLowerCase(), isNot(contains('mg/dl')));
        expect(item.name.toLowerCase(), isNot(contains('ug/l')));
        expect(item.name.toLowerCase(), isNot(contains('10^3')));
      }
    });

    test('evaluates multi-parameter clinical patterns (HGB + Demir anemia, NEU% + LYM%, HDL + PCT)', () {
      // 1. Iron deficiency anemia pattern: HGB low + Demir low + Ferritin low
      final anemiaItems = [
        LabReportAnalyzer.evaluateExtractedItem(
          rawName: 'HGB',
          value: 10.2,
          unit: 'g/dL',
          refMin: 11,
          refMax: 17,
        ),
        LabReportAnalyzer.evaluateExtractedItem(
          rawName: 'Demir',
          value: 35,
          unit: 'ug/L',
          refMin: 60,
          refMax: 180,
        ),
        LabReportAnalyzer.evaluateExtractedItem(
          rawName: 'Ferritin',
          value: 9,
          unit: 'µg/L',
          refMin: 13,
          refMax: 232,
        ),
      ];
      final anemiaReport = LabReportAnalyzer.buildReport(
        title: 'Anemi Kontrol',
        reportDate: DateTime(2026, 5, 7),
        source: LabReportSource.pdfUpload,
        items: anemiaItems,
      );
      expect(
        anemiaReport.contextualInterpretation,
        contains('Demir Eksikliği Anemisi Eğilimi'),
      );

      // 2. Real e-Nabız combination: NEU% high + LYM% low + WBC normal + PCT high + PLT normal + HDL low
      final enabizItems = [
        LabReportAnalyzer.evaluateExtractedItem(rawName: 'NEU%', value: 75.2, unit: '%', refMin: 50, refMax: 70),
        LabReportAnalyzer.evaluateExtractedItem(rawName: 'LYM%', value: 18.4, unit: '%', refMin: 20, refMax: 40),
        LabReportAnalyzer.evaluateExtractedItem(rawName: 'WBC', value: 8.03, unit: '10^3/mm^3', refMin: 4, refMax: 10),
        LabReportAnalyzer.evaluateExtractedItem(rawName: 'PCT', value: 0.29, unit: '%', refMin: 0.108, refMax: 0.282),
        LabReportAnalyzer.evaluateExtractedItem(rawName: 'PLT', value: 266, unit: '10^3/mm^3', refMin: 100, refMax: 380),
        LabReportAnalyzer.evaluateExtractedItem(rawName: 'HDL Kolesterol', value: 49, unit: 'mg/dL', refMax: 50),
        LabReportAnalyzer.evaluateExtractedItem(rawName: 'LDL Kolesterol', value: 80, unit: 'mg/dL', refMin: 0, refMax: 130),
      ];
      final enabizReport = LabReportAnalyzer.buildReport(
        title: 'e-Nabız Raporu',
        reportDate: DateTime(2026, 5, 7),
        source: LabReportSource.pdfUpload,
        items: enabizItems,
      );
      expect(enabizReport.contextualInterpretation, contains('Nötrofil % Yüksek / Lenfosit % Düşük'));
      expect(enabizReport.contextualInterpretation, contains('PCT Hafif Yüksek, Trombosit (PLT) Normal'));
      expect(enabizReport.contextualInterpretation, contains('Koruyucu HDL Kolesterol Sınırda Düşük'));
    });

    test('reconstructs geometric multi-column PDF tables accurately via Syncfusion', () async {
      final document = sf.PdfDocument();
      final page = document.pages.add();
      final font = sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 11);

      void drawRow(double y, String name, String val, String unit, String ref) {
        page.graphics.drawString(name, font, bounds: Rect.fromLTWH(20, y, 140, 16));
        page.graphics.drawString(val, font, bounds: Rect.fromLTWH(180, y, 60, 16));
        page.graphics.drawString(unit, font, bounds: Rect.fromLTWH(260, y, 80, 16));
        page.graphics.drawString(ref, font, bounds: Rect.fromLTWH(360, y, 100, 16));
      }

      page.graphics.drawString('Tarih: 07.05.2026', font, bounds: const Rect.fromLTWH(20, 10, 200, 16));
      drawRow(40, 'Demir', '127', 'ug/L', '60 - 180');
      drawRow(60, 'Demir Baglama', '304', 'ug/dL', '155 - 355');
      drawRow(80, 'Folat', '14,3', 'ug/L', '3,21 - 20');
      drawRow(100, 'HGB', '13,7', 'g/dL', '11 - 17');
      drawRow(120, 'HCT', '40,7', '%', '36 - 48');

      final bytes = Uint8List.fromList(await document.save());
      document.dispose();

      final extracted = PdfTextExtractor.extractText(bytes);
      final parsed = LabReportAnalyzer.parseReportText(extracted);
      final codes = parsed.items.map((e) => e.code).toSet();
      expect(codes, containsAll(['IRON', 'TIBC', 'FOLATE', 'HGB', 'HCT']));
      expect(parsed.detectedDate, DateTime(2026, 5, 7));
    });

    test('LabReportPdfGenerator creates valid doctor summary PDF with comparison table', () async {
      final prevReport = LabReportAnalyzer.buildReport(
        title: 'Önceki Tahlil',
        reportDate: DateTime(2026, 2, 10),
        source: LabReportSource.pdfUpload,
        items: [
          LabReportAnalyzer.evaluateExtractedItem(rawName: 'HGB', value: 11.2, unit: 'g/dL', refMin: 11, refMax: 17),
          LabReportAnalyzer.evaluateExtractedItem(rawName: 'Demir', value: 52, unit: 'ug/L', refMin: 60, refMax: 180),
        ],
      );
      final currentReport = LabReportAnalyzer.buildReport(
        title: 'Çubuk Devlet Hastanesi',
        reportDate: DateTime(2026, 5, 7),
        source: LabReportSource.pdfUpload,
        items: [
          LabReportAnalyzer.evaluateExtractedItem(rawName: 'HGB', value: 13.7, unit: 'g/dL', refMin: 11, refMax: 17),
          LabReportAnalyzer.evaluateExtractedItem(rawName: 'Demir', value: 127, unit: 'ug/L', refMin: 60, refMax: 180),
          LabReportAnalyzer.evaluateExtractedItem(rawName: 'HDL Kolesterol', value: 49, unit: 'mg/dL', refMax: 50),
        ],
      );

      final pdfBytes = await LabReportPdfGenerator.generateSummaryPdf(
        report: currentReport,
        previousReport: prevReport,
      );
      expect(pdfBytes.length, greaterThan(1000));
      expect(utf8.decode(pdfBytes.take(5).toList()), '%PDF-');

      final extracted = PdfTextExtractor.extractText(pdfBytes);
      expect(extracted, contains('VisualCheckUp'));
      expect(extracted, contains('07.05.2026'));
      expect(extracted, contains('13.7'));
      expect(extracted, contains('127'));
    });
  });
}
