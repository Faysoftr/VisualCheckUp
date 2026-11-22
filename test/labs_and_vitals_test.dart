import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

void main() {
  group('LabReportAnalyzer — hospital/e-Nabız parsing, evaluation & trends', () {
    test('parses Turkish lab report text with date, decimals, and evaluates statuses', () {
      const sampleText = '''
      Tarih: 14.04.2026
      Hemoglobin (HGB): 10,6 g/dL
      Ferritin: 12 ng/mL
      Açlık Glukoz: 132 mg/dL
      TSH: 5.4 mIU/L
      Vitamin D: 38 ng/mL
      ''';

      final parsed = LabReportAnalyzer.parseReportText(sampleText);

      expect(parsed.detectedDate, DateTime(2026, 4, 14));
      expect(parsed.items.length, 5);

      final byCode = {for (final i in parsed.items) i.code: i};
      expect(byCode['HGB']!.status, LabStatus.low);
      expect(byCode['FERRITIN']!.status, LabStatus.low);
      expect(byCode['GLU']!.status, LabStatus.high);
      expect(byCode['TSH']!.status, LabStatus.high);
      expect(byCode['VITD']!.status, LabStatus.normal);

      final report = LabReportAnalyzer.buildReport(
        title: 'e-Nabız Kan Tahlili',
        reportDate: parsed.detectedDate!,
        source: LabReportSource.pastedText,
        items: parsed.items,
      );
      expect(report.abnormalCount, 4);
      expect(
        LabReportAnalyzer.formatReportForDoctor(report),
        contains('e-Nabız Kan Tahlili'),
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

    test('LabsVitalsRepository persists and clears lab reports, BP, and sugar logs', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = LabsVitalsRepository();

      final parsed = LabReportAnalyzer.parseReportText('Hemoglobin: 13.5\nGlukoz: 92');
      await repo.saveLabReport(
        LabReportAnalyzer.buildReport(
          title: 'Kontrol',
          reportDate: DateTime(2026, 5, 1),
          source: LabReportSource.pastedText,
          items: parsed.items,
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

      expect(await repo.loadLabReports(), hasLength(1));
      expect(await repo.loadBloodPressureReadings(), hasLength(1));
      expect(await repo.loadBloodSugarReadings(), hasLength(1));

      await repo.clearAll();
      expect(await repo.loadLabReports(), isEmpty);
      expect(await repo.loadBloodPressureReadings(), isEmpty);
      expect(await repo.loadBloodSugarReadings(), isEmpty);
    });
  });

  group('Widget flows — Lab Reports & Vitals Tracker from HomeScreen', () {
    testWidgets('parses pasted hospital report text, saves dated report, and renders trend tab', (
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
            id: 'u_lab',
            displayName: 'Can Kaya',
            provider: AuthProviderType.google,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Tahlil & Raporlar'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Tahlil & Raporlar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tahlil & Raporlar'));
      await tester.pumpAndSettle();

      expect(find.text('Tahlil & Hastane Raporları'), findsOneWidget);
      await tester.tap(find.text('Rapor / Kan Testi Ekle'));
      await tester.pumpAndSettle();

      // Paste Turkish blood test lines into the second TextField.
      final textFields = find.byType(TextField);
      await tester.enterText(
        textFields.at(1),
        'Tarih: 10.05.2026\nHemoglobin: 11.0\nGlukoz: 95\nTSH: 4.8',
      );
      await tester.tap(find.text('Metni Oku ve Ayrıştır'));
      await tester.pumpAndSettle();

      expect(find.textContaining('3 tahlil parametresi'), findsOneWidget);

      await tester.ensureVisible(find.text('Değerlendir ve Tarihli Kaydet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Değerlendir ve Tarihli Kaydet'));
      await tester.pumpAndSettle();

      // Detail bottom sheet shows parsed evaluation.
      expect(find.text('Parametre Değerlendirmesi (3)'), findsOneWidget);
      expect(await repo.loadLabReports(), hasLength(1));
    });

    testWidgets('logs Blood Pressure and Blood Sugar readings with trends in VitalsTrackerScreen', (
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
