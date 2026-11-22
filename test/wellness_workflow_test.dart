import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/data/doctor_report_builder.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/follow_up_plan.dart';
import 'package:visualcheckup/features/checkup/domain/quick_color_swatch.dart';

void main() {
  group('DoctorReportBuilder', () {
    test('builds specialty guidance, chronological timeline, questions, and shareable text', () {
      final earlier = AnalysisResult(
        id: 'skin_old',
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.normal,
        summaryTitle: 'Stabil Görünümlü Ben',
        summaryDetail: 'Önceki kontrol olağan.',
        dominantColorValue: 0xFF8C6249,
        observations: const ['Düzgün kenarlı'],
        recommendations: const ['Aylık takip et'],
        warningFlags: const [],
        confidence: 0.85,
        createdAt: DateTime(2026, 3, 10, 10, 0),
      );
      final current = AnalysisResult(
        id: 'skin_new',
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Belirgin Renk/Kenar Değişimi',
        summaryDetail: 'Lezyon kenarında düzensizlik gözlendi.',
        dominantColorValue: 0xFF4A2B1D,
        observations: const ['Renk tonu koyulaşmış'],
        recommendations: const ['Dermatoloji değerlendirmesi alın'],
        warningFlags: const ['ABCDE uyarısı'],
        confidence: 0.88,
        createdAt: DateTime(2026, 5, 1, 14, 30),
        whiteBalanceCalibrated: true,
        baselineComparisonNote: 'Önceki ölçüme göre belirgin koyulaşma',
      );

      final report = DoctorReportBuilder.build(
        currentResult: current,
        allHistory: [current, earlier],
      );

      expect(report.recommendedSpecialty, 'Dermatoloji');
      expect(report.colorHex, '#4A2B1D');
      expect(report.hasTimelineHistory, isTrue);
      expect(report.previousCategoryResults.single.id, 'skin_old');
      expect(report.questionsForDoctor.length, greaterThanOrEqualTo(3));

      final text = report.toShareableText();
      expect(text, contains('VisualCheckUp • Doktora Hazırlık Özeti'));
      expect(text, contains('Dermatoloji'));
      expect(text, contains('Stabil Görünümlü Ben'));
      expect(text, contains('tıbbi teşhis koymaz'));
    });
  });

  group('QuickColorCardCatalog', () {
    test('escalates amber urine to urgent when burning red-flag symptom is selected', () {
      final swatches = QuickColorCardCatalog.swatchesFor(CheckCategory.urine);
      final amber = swatches.firstWhere((s) => s.id == 'urine_amber');

      final result = QuickColorCardCatalog.buildResult(
        category: CheckCategory.urine,
        swatch: amber,
        selectedContextIds: const {'urine_burning'},
      );

      expect(result.riskLevel, RiskLevel.urgent);
      expect(
        result.warningFlags.any((f) => f.contains('Eşlik eden rahatsızlık')),
        isTrue,
      );
    });

    test('adds benign medication note when iron pill context is chosen for black stool', () {
      final swatches = QuickColorCardCatalog.swatchesFor(CheckCategory.stool);
      final black = swatches.firstWhere((s) => s.id == 'stool_black_tar');

      final result = QuickColorCardCatalog.buildResult(
        category: CheckCategory.stool,
        swatch: black,
        selectedContextIds: const {'stool_iron_bismuth'},
      );

      expect(result.riskLevel, RiskLevel.urgent);
      expect(
        result.recommendations.first,
        contains('geçici renk değişimi yapabilir'),
      );
    });
  });

  group('FollowUpEvaluator & HistoryRepository persistence', () {
    test('marks hydration track completed today and persists custom follow-up tracks', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = HistoryRepository();

      final defaults = await repo.loadFollowUpTracks();
      expect(defaults, contains(FollowUpTrack.skinMonthly));
      expect(defaults, contains(FollowUpTrack.hydrationDaily));

      await repo.saveFollowUpTracks(const {
        FollowUpTrack.skinMonthly,
        FollowUpTrack.nailTongueWeekly,
      });
      final reloaded = await repo.loadFollowUpTracks();
      expect(reloaded, contains(FollowUpTrack.nailTongueWeekly));
      expect(reloaded, isNot(contains(FollowUpTrack.hydrationDaily)));

      final now = DateTime(2026, 5, 10, 12, 0);
      final recentUrine = AnalysisResult(
        id: 'u1',
        category: CheckCategory.urine,
        riskLevel: RiskLevel.normal,
        summaryTitle: 'Açık Saman Sarısı',
        summaryDetail: 'İdeal hidrasyon',
        dominantColorValue: 0xFFF3E49A,
        observations: const [],
        recommendations: const [],
        warningFlags: const [],
        confidence: 0.9,
        createdAt: now.subtract(const Duration(hours: 2)),
      );

      final statuses = FollowUpEvaluator.evaluate(
        enabledTracks: const {
          FollowUpTrack.hydrationDaily,
          FollowUpTrack.skinMonthly,
        },
        history: [recentUrine],
        now: now,
      );

      final hydration = statuses.firstWhere(
        (s) => s.track == FollowUpTrack.hydrationDaily,
      );
      final skin = statuses.firstWhere(
        (s) => s.track == FollowUpTrack.skinMonthly,
      );

      expect(hydration.isDueNow, isFalse);
      expect(hydration.statusLabel, 'Bugün tamamlandı');
      expect(skin.isDueNow, isTrue);
      expect(skin.statusLabel, 'İlk kayıt bekleniyor');
    });
  });

  group('End-to-end Quick Color Card -> Result -> Doctor Summary widget flow', () {
    testWidgets('logs urine via camera-free color card and opens DoctorSummarySheet', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'visualcheckup_disclaimer_v1': true,
      });

      final repo = HistoryRepository();

      await tester.pumpWidget(
        VisualCheckUpApp(
          historyRepository: repo,
          initialUser: const AuthUser(
            id: 'test_user',
            displayName: 'Deniz Demir',
            provider: AuthProviderType.google,
            email: 'deniz@gmail.com',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to İdrar Rengi on HomeScreen and tap it.
      await tester.scrollUntilVisible(
        find.text('İdrar Rengi'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('İdrar Rengi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('İdrar Rengi'));
      await tester.pumpAndSettle();

      // 2-option modal sheet appears; pick camera-free Color Card.
      expect(find.text('Kamerasız Renk Kartı (Önerilen)'), findsOneWidget);
      await tester.tap(find.text('Kamerasız Renk Kartı (Önerilen)'));
      await tester.pumpAndSettle();

      // Select Koyu Sarı / Kehribar swatch.
      expect(find.text('İdrar Rengi • Renk Kartı'), findsOneWidget);
      await tester.ensureVisible(find.text('Koyu Sarı / Kehribar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Koyu Sarı / Kehribar'));
      await tester.pumpAndSettle();

      // Save and open ResultScreen.
      final quickCardScrollable = find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Kaydet ve Değerlendirmeyi Gör'),
        250,
        scrollable: quickCardScrollable,
      );
      await tester.ensureVisible(find.text('Kaydet ve Değerlendirmeyi Gör'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kaydet ve Değerlendirmeyi Gör'));
      await tester.pumpAndSettle();

      // ResultScreen displays specialty guidance & Doctor Summary CTA.
      expect(find.text('İdrar Rengi Sonucu'), findsOneWidget);
      expect(find.textContaining('Üroloji veya Dahiliye'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Doktora Göster • Özet Hazırla'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(find.text('Doktora Göster • Özet Hazırla'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Doktora Göster • Özet Hazırla'));
      await tester.pumpAndSettle();

      // DoctorSummarySheet displays questions & copy button.
      expect(find.text('Doktora Göster • Randevu Özeti'), findsOneWidget);
      expect(find.text('Doktorunuza Sorabileceğiniz Sorular'), findsOneWidget);
      expect(await repo.loadHistory(), hasLength(1));
    });
  });
}
