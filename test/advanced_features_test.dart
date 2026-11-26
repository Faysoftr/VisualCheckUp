import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/notifications/reminder_service.dart';
import 'package:visualcheckup/core/profile/family_profile_controller.dart';
import 'package:visualcheckup/features/checkup/data/cross_module_correlator.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_document_picker.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_pdf_generator.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

void main() {
  group('Cross-Module Lab + Visual Intelligence, Family Profiles & Holistic PDF', () {
    test('CrossModuleHealthCorrelator links low Ferritin/HGB with brittle/pale nail', () {
      final labReport = LabReportAnalyzer.buildReport(
        title: 'Kan Tahlili',
        reportDate: DateTime(2026, 5, 7),
        source: LabReportSource.pdfUpload,
        items: [
          LabReportAnalyzer.evaluateExtractedItem(
            rawName: 'HGB',
            value: 10.4,
            unit: 'g/dL',
            refMin: 11,
            refMax: 17,
          ),
          LabReportAnalyzer.evaluateExtractedItem(
            rawName: 'Ferritin',
            value: 8,
            unit: 'µg/L',
            refMin: 13,
            refMax: 232,
          ),
        ],
      );

      final nailResult = AnalysisResult(
        id: 'nail_1',
        category: CheckCategory.nail,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Tırnakta Kırılma / Soyulma / Yüzey Pürüzlülüğü',
        summaryDetail: 'Tırnak ucunda kırılma ve soyulma gözlendi.',
        dominantColorValue: 0xFFD49A9A,
        observations: const ['Kırılma ve solukluk'],
        recommendations: const [],
        warningFlags: const [],
        confidence: 0.72,
        createdAt: DateTime(2026, 5, 10),
      );

      final insights = CrossModuleHealthCorrelator.correlate(
        visualResult: nailResult,
        labReports: [labReport],
      );
      expect(insights, isNotEmpty);
      expect(insights.first.title, contains('Demir / Vitamin'));
      expect(insights.first.detail, contains('HGB'));
      expect(insights.first.detail, contains('FERRITIN'));
    });

    test('FamilyProfileController persists and isolates per-profile repositories', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = FamilyProfileController();
      await controller.load();
      expect(controller.value.isSelf, isTrue);

      final mom = await controller.addProfile(name: 'Annem', relation: 'Anne');
      expect(controller.value.id, mom.id);
      expect(controller.profiles, hasLength(2));

      final selfRepo = LabsVitalsRepository(profileId: 'self');
      final momRepo = LabsVitalsRepository(profileId: mom.id);

      await momRepo.saveBloodPressure(
        BloodPressureReading(
          id: 'bp_mom',
          recordedAt: DateTime(2026, 5, 10),
          systolic: 142,
          diastolic: 88,
        ),
      );
      expect(await momRepo.loadBloodPressureReadings(), hasLength(1));
      expect(await selfRepo.loadBloodPressureReadings(), isEmpty);
    });

    test('ReminderPreferencesService saves and loads daily reminder schedule', () async {
      SharedPreferences.setMockInitialValues({});
      const service = ReminderPreferencesService();
      await service.save(const ReminderConfig(enabled: true, hour: 8, minute: 15));
      final loaded = await service.load();
      expect(loaded.enabled, isTrue);
      expect(loaded.formattedTime, '08:15');
    });

    test('LabReportPdfGenerator.generateHolisticDoctorPdf builds unified multi-module PDF', () async {
      final bytes = await LabReportPdfGenerator.generateHolisticDoctorPdf(
        profileName: 'Annem',
        bpReadings: [
          BloodPressureReading(
            id: 'bp1',
            recordedAt: DateTime(2026, 5, 10, 9, 0),
            systolic: 136,
            diastolic: 84,
            pulse: 72,
          ),
        ],
        sugarReadings: [
          BloodSugarReading(
            id: 's1',
            recordedAt: DateTime(2026, 5, 10, 8, 30),
            valueMgDl: 108,
            measurementType: SugarMeasurementType.fasting,
          ),
        ],
        visualChecks: [
          AnalysisResult(
            id: 'eye_1',
            category: CheckCategory.eye,
            riskLevel: RiskLevel.normal,
            summaryTitle: 'Göz Akı Tonu Olağan Görünüyor',
            summaryDetail: 'Olağan.',
            dominantColorValue: 0xFFEEEEEE,
            observations: const [],
            recommendations: const [],
            warningFlags: const [],
            confidence: 0.8,
            createdAt: DateTime(2026, 5, 10),
          ),
        ],
      );

      expect(bytes.length, greaterThan(1000));
      expect(utf8.decode(bytes.take(5).toList()), '%PDF-');
      final text = PdfTextExtractor.extractText(bytes);
      expect(text, contains('Annem'));
      expect(text, contains('136/84'));
      expect(text, contains('108'));
    });
  });
}
