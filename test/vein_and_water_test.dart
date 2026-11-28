import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/app_drawer.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/vein_varicose/data/vein_repository.dart';
import 'package:visualcheckup/features/vein_varicose/data/vein_visual_analyzer.dart';
import 'package:visualcheckup/features/vein_varicose/domain/vein_models.dart';
import 'package:visualcheckup/features/vein_varicose/presentation/screens/vein_analysis_screen.dart';
import 'package:visualcheckup/features/water_tracker/data/water_repository.dart';
import 'package:visualcheckup/features/water_tracker/domain/water_models.dart';
import 'package:visualcheckup/features/water_tracker/presentation/screens/water_tracker_screen.dart';

void main() {
  group('Vein & Varicose Clinical Evaluation', () {
    test('evaluates CEAP C1 mild telangiectasia and C2 varicose veins with stockings recommendation', () {
      final evalC1 = evaluateVeinHealth(
        stage: CeapStage.c1,
        symptoms: const VeinSymptomAssessment(
          hasHeavyLegsEvening: true,
        ),
      );
      expect(evalC1.stage, CeapStage.c1);
      expect(evalC1.riskLevel, contains('Erken Evre'));
      expect(evalC1.recommendations, isNotEmpty);
      expect(evalC1.isDvtWarning, isFalse);

      final evalC2 = evaluateVeinHealth(
        stage: CeapStage.c2,
        symptoms: const VeinSymptomAssessment(
          hasAnkleSwelling: true,
          standsOrSitsLongHours: true,
        ),
      );
      expect(evalC2.stage, CeapStage.c2);
      expect(evalC2.riskLevel, contains('Orta Düzey'));
      expect(evalC2.recommendations.any((r) => r.contains('Varis Çorabı')), isTrue);
    });

    test('triggers emergency red flag notice when sudden pain/swelling (DVT risk) is reported', () {
      final evalDvt = evaluateVeinHealth(
        stage: CeapStage.c3,
        symptoms: const VeinSymptomAssessment(
          hasSuddenPainOrAsymmetricSwelling: true,
        ),
      );
      expect(evalDvt.isDvtWarning, isTrue);
      expect(evalDvt.dvtEmergencyNotice, contains('ACİL TIBBİ UYARI'));
      expect(evalDvt.dvtEmergencyNotice, contains('Derin Ven Trombozu'));
    });

    test('persists vein check records in VeinRepository', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = VeinRepository();
      expect(await repo.loadRecords(), isEmpty);

      final rec = VeinCheckRecord(
        id: 'vein_1',
        recordedAt: DateTime.now(),
        stage: CeapStage.c2,
        symptomScore: 45,
      );
      await repo.saveRecord(rec);

      final list = await repo.loadRecords();
      expect(list.length, 1);
      expect(list.first.stage, CeapStage.c2);

      await repo.deleteRecord('vein_1');
      expect(await repo.loadRecords(), isEmpty);
    });
  });

  group('Water Tracker Domain & Repository', () {
    test('calculates recommended target from weight', () {
      final normal = DailyWaterSummary.calculateRecommendedTarget(weightKg: 70);
      expect(normal, 70 * 33);

      final active = DailyWaterSummary.calculateRecommendedTarget(weightKg: 70, isActive: true);
      expect(active, (70 * 33) + 500);

      final defaultTarget = DailyWaterSummary.calculateRecommendedTarget(weightKg: null);
      expect(defaultTarget, 2500);
    });

    test('logs water consumption, calculates progress, and resets today', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = WaterRepository();

      await repo.setDailyTarget(2000);
      expect(await repo.getDailyTarget(), 2000);

      var summary = await repo.getTodaySummary();
      expect(summary.consumedMl, 0);
      expect(summary.progressPercent, 0);
      expect(summary.remainingMl, 2000);

      await repo.logWater(500);
      await repo.logWater(300);

      summary = await repo.getTodaySummary();
      expect(summary.consumedMl, 800);
      expect(summary.progressPercent, 40);
      expect(summary.remainingMl, 1200);
      expect(summary.entries.length, 2);

      await repo.resetToday();
      summary = await repo.getTodaySummary();
      expect(summary.consumedMl, 0);
      expect(summary.entries, isEmpty);
    });
  });

  group('VeinAnalysisScreen Widget Tests', () {
    testWidgets('renders CEAP selection, selects stage, submits evaluation, and views exercises', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});
      final repo = VeinRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: VeinAnalysisScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Damar & Varis Taraması'), findsOneWidget);
      expect(find.textContaining('C1 — Kılcal / Örümcek Damarlar'), findsOneWidget);

      // Select C2
      await tester.tap(find.byKey(const Key('ceap_stage_c2')));
      await tester.pumpAndSettle();

      // Submit evaluation
      final submitBtn = find.byKey(const Key('vein_submit_btn'));
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Report card should appear
      expect(find.textContaining('Damar Sağlığı & Önlem Önerileri:'), findsOneWidget);

      // Switch to exercises tab
      await tester.tap(find.text('Koruyucu Egzersizler'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Baldır Kası Pompası'), findsOneWidget);
      expect(find.textContaining('Bacak Elevasyonu'), findsOneWidget);
    });

    testWidgets('camera scan analyzes leg photo, displays visual metrics, and updates CEAP stage', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});
      final repo = VeinRepository();

      // Build synthetic leg skin image with prominent bluish-teal vein streaks
      final synthetic = img.Image(width: 120, height: 120);
      for (int y = 0; y < 120; y++) {
        for (int x = 0; x < 120; x++) {
          final isVeinBand = (x >= 35 && x <= 48) || (x >= 72 && x <= 84);
          if (isVeinBand && y >= 20 && y <= 100) {
            synthetic.setPixelRgb(x, y, 75, 118, 148);
          } else {
            synthetic.setPixelRgb(x, y, 224, 188, 168);
          }
        }
      }
      final pngBytes = img.encodePng(synthetic);

      await tester.pumpWidget(
        MaterialApp(
          home: VeinAnalysisScreen(
            repository: repo,
            visualAnalyzer: VeinVisualAnalyzer(aiClient: null),
            imageBytesPickerOverride: (ImageSource source) async {
              expect(source, ImageSource.camera);
              return pngBytes;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('vein_camera_scan_card')), findsOneWidget);
      await tester.tap(find.byKey(const Key('vein_camera_capture_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('vein_visual_scan_result_card')), findsOneWidget);
      expect(find.textContaining('Önerilen Evre: C2'), findsOneWidget);
      expect(find.textContaining('Orta Düzey Venöz Yetmezlik Riski'), findsOneWidget);
    });
  });

  group('WaterTrackerScreen Widget Tests', () {
    testWidgets('renders water screen, adds 200ml and custom water intake', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});
      final repo = WaterRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: WaterTrackerScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Su Takibi & Hidrasyon'), findsOneWidget);
      expect(find.text('0'), findsOneWidget); // 0 ml initially

      // Quick add +200 ml
      await tester.tap(find.byKey(const Key('water_add_200')));
      await tester.pumpAndSettle();

      expect(find.text('200'), findsOneWidget);
      expect(find.text('+200 ml'), findsAtLeastNWidgets(1));

      // Custom amount dialog
      await tester.tap(find.byKey(const Key('water_add_custom')));
      await tester.pumpAndSettle();

      expect(find.text('Özel Su Miktarı Ekle'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('custom_water_input')), '350');
      await tester.tap(find.byKey(const Key('custom_water_save_btn')));
      await tester.pumpAndSettle();

      expect(find.text('550'), findsOneWidget); // 200 + 350
    });
  });

  group('AppDrawer Vein and Water Navigation', () {
    testWidgets('drawer renders water tracker and vein analysis tiles and handles taps', (
      tester,
    ) async {
      bool veinTapped = false;
      bool waterTapped = false;
      final themeController = ThemeController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              currentUser: const AuthUser(
                id: 'u1',
                displayName: 'Murat Can',
                provider: AuthProviderType.google,
              ),
              themeController: themeController,
              onOpenSkinModule: () {},
              onOpenHistory: () {},
              onOpenReferenceGuide: () {},
              onOpenAiSettings: () {},
              onOpenDisclaimer: () {},
              onSignOut: () {},
              onDeleteAccount: () {},
              onOpenVeinAnalysis: () => veinTapped = true,
              onOpenWaterTracker: () => waterTapped = true,
            ),
            body: const Center(child: Text('Home')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // 1. Vein Analysis is inside Visual Checks accordion (Görsel Kontroller)
      final visualAccordion = find.byKey(const Key('drawer_group_visual'));
      await tester.ensureVisible(visualAccordion);
      await tester.pumpAndSettle();
      await tester.tap(visualAccordion);
      await tester.pumpAndSettle();

      final veinTile = find.byKey(const Key('drawer_item_vein_analysis'));
      expect(veinTile, findsOneWidget);
      await tester.ensureVisible(veinTile);
      await tester.pumpAndSettle();
      await tester.tap(veinTile);
      await tester.pumpAndSettle();
      expect(veinTapped, isTrue);

      // 2. Re-open drawer and verify Water Tracker inside Tracking accordion
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final trackingAccordion = find.byKey(const Key('drawer_group_tracking'));
      await tester.ensureVisible(trackingAccordion);
      await tester.pumpAndSettle();
      await tester.tap(trackingAccordion);
      await tester.pumpAndSettle();

      final waterTile = find.byKey(const Key('drawer_item_water_tracker'));
      expect(waterTile, findsOneWidget);
      await tester.ensureVisible(waterTile);
      await tester.pumpAndSettle();
      await tester.tap(waterTile);
      await tester.pumpAndSettle();
      expect(waterTapped, isTrue);

      themeController.dispose();
    });
  });
}
