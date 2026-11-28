import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/breath_lung/data/breath_lung_repository.dart';
import 'package:visualcheckup/features/breath_lung/domain/breath_lung_models.dart';
import 'package:visualcheckup/features/breath_lung/presentation/screens/breath_lung_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/app_drawer.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';

void main() {
  group('evaluateBreathHoldByAge clinical evaluation function', () {
    test('evaluates 25yo breath hold with age-stratified norms', () {
      // 25yo holding 52s (healthy target for 18-29 is 42-58s, avg 50s)
      final evalHealthy = evaluateBreathHoldByAge(
        age: 25,
        holdSeconds: 52.0,
        mode: BreathTestMode.inspiratoryCapacity,
      );

      expect(evalHealthy.level, LungCapacityLevel.healthyNormal);
      expect(evalHealthy.score, inInclusiveRange(65, 84));
      expect(evalHealthy.deltaFromAverageSec, closeTo(2.0, 0.1));
      expect(evalHealthy.hasClinicalWarning, isFalse);
      expect(evalHealthy.recommendations, isNotEmpty);

      // 25yo holding 18s (below 28s caution threshold, below 20s clinical red flag)
      final evalLow = evaluateBreathHoldByAge(
        age: 25,
        holdSeconds: 18.0,
        mode: BreathTestMode.inspiratoryCapacity,
      );

      expect(evalLow.level, LungCapacityLevel.needsAttention);
      expect(evalLow.score, lessThan(45));
      expect(evalLow.hasClinicalWarning, isTrue);
      expect(evalLow.clinicalWarning, contains('Spirometri'));
    });

    test('age-adjusted threshold: 34 seconds is healthy normal for a 65yo but below average for 25yo', () {
      final evalElderly = evaluateBreathHoldByAge(
        age: 65,
        holdSeconds: 34.0,
      );
      expect(evalElderly.level, LungCapacityLevel.healthyNormal);

      final evalYoung = evaluateBreathHoldByAge(
        age: 25,
        holdSeconds: 34.0,
      );
      expect(evalYoung.level, LungCapacityLevel.belowAverage);
    });

    test('evaluates athletic capacity for 75yo', () {
      final evalSenior = evaluateBreathHoldByAge(
        age: 75,
        holdSeconds: 45.0, // 70+ athletic threshold is >= 40s
      );
      expect(evalSenior.level, LungCapacityLevel.excellentAthletic);
      expect(evalSenior.score, greaterThanOrEqualTo(95));
      expect(evalSenior.deltaFromAverageSec, greaterThan(15.0));
    });

    test('evaluates Buteyko Control Pause (CP) mode', () {
      final cpLow = evaluateBreathHoldByAge(
        age: 30,
        holdSeconds: 11.0,
        mode: BreathTestMode.controlPause,
      );
      expect(cpLow.level, LungCapacityLevel.needsAttention);

      final cpGood = evaluateBreathHoldByAge(
        age: 30,
        holdSeconds: 38.0,
        mode: BreathTestMode.controlPause,
      );
      expect(cpGood.level, LungCapacityLevel.good);
    });

    test('handles extreme inputs safely', () {
      final evalZero = evaluateBreathHoldByAge(age: 4, holdSeconds: -5.0);
      expect(evalZero.score, 0);
      expect(evalZero.age, 8); // clamped minimum

      final evalExcess = evaluateBreathHoldByAge(age: 150, holdSeconds: 500.0);
      expect(evalExcess.age, 105); // clamped maximum
      expect(evalExcess.holdSeconds, 300.0);
      expect(evalExcess.score, 100);
    });
  });

  group('BreathLungRepository and Age calculation', () {
    test('calculates age from dd-MM-yyyy and yyyy-MM-dd birthDate strings', () {
      final now = DateTime.now();

      // Born 20 years ago
      final year20 = now.year - 20;
      final age1 = BreathLungRepository.calculateAgeFromBirthDate('15-06-$year20');
      expect(age1, anyOf(19, 20));

      final age2 = BreathLungRepository.calculateAgeFromBirthDate('$year20/06/15');
      expect(age2, anyOf(19, 20));

      expect(BreathLungRepository.calculateAgeFromBirthDate('invalid-date'), isNull);
    });

    test('saves, loads, and deletes test records', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = BreathLungRepository();

      expect(await repo.loadRecords(), isEmpty);

      final rec1 = BreathHoldRecord(
        id: 'rec_1',
        recordedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        age: 28,
        holdSeconds: 46.2,
        mode: BreathTestMode.inspiratoryCapacity,
        score: 72,
        level: LungCapacityLevel.healthyNormal,
      );

      final rec2 = BreathHoldRecord(
        id: 'rec_2',
        recordedAt: DateTime.now(),
        age: 28,
        holdSeconds: 61.5,
        mode: BreathTestMode.inspiratoryCapacity,
        score: 88,
        level: LungCapacityLevel.good,
      );

      await repo.saveRecord(rec1);
      await repo.saveRecord(rec2);

      final list = await repo.loadRecords();
      expect(list.length, 2);
      expect(list.first.id, 'rec_2'); // newest first
      expect(await repo.getLastAge(), 28);

      await repo.deleteRecord('rec_1');
      final afterDelete = await repo.loadRecords();
      expect(afterDelete.length, 1);
      expect(afterDelete.first.id, 'rec_2');

      // Exercise count tracking
      expect(await repo.getExerciseCompletedCount(), 0);
      await repo.incrementExerciseCompletedCount();
      expect(await repo.getExerciseCompletedCount(), 1);
    });
  });

  group('BreathLungScreen interactive tests', () {
    testWidgets('renders screen, modifies age, and evaluates manual seconds', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});
      final repo = BreathLungRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: BreathLungScreen(
            initialAge: 32,
            repository: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nefes & Akciğer Sağlığı'), findsOneWidget);
      expect(find.text('Hesaplanan Yaşınız: 32'), findsOneWidget);

      // Increment age
      await tester.tap(find.byKey(const Key('age_increment_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Hesaplanan Yaşınız: 33'), findsOneWidget);

      // Manual input flow
      final manualBtn = find.byKey(const Key('breath_test_manual_btn'));
      await tester.ensureVisible(manualBtn);
      await tester.pumpAndSettle();
      await tester.tap(manualBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.enterText(find.byKey(const Key('manual_seconds_input')), '50');
      await tester.tap(find.byKey(const Key('manual_seconds_save_btn')));
      await tester.pumpAndSettle();

      // Check evaluation card is rendered
      expect(find.textContaining('50.0 sn'), findsAtLeastNWidgets(1));
      expect(find.text('Ölçüm Geçmişi'), findsOneWidget);

      // Switch to guided breathing exercises tab
      await tester.tap(find.text('Nefes Egzersizleri'));
      await tester.pumpAndSettle();

      expect(find.text('Büzük Dudak Nefesi'), findsAtLeastNWidgets(1));
      expect(find.text('Kutu Nefesi (4-4-4-4)'), findsOneWidget);

      // Start exercise then stop exercise
      final toggleBtn = find.byKey(const Key('breath_exercise_toggle_btn'));
      expect(find.text('Egzersizi Başlat'), findsOneWidget);
      await tester.tap(toggleBtn);
      await tester.pump(); // start timer

      expect(find.text('Egzersizi Durdur'), findsOneWidget);
      await tester.tap(toggleBtn);
      await tester.pump(); // stop timer

      expect(find.text('Egzersizi Başlat'), findsOneWidget);
    });
  });

  group('AppDrawer Breath & Lung integration', () {
    testWidgets('drawer renders onOpenBreathLung tile and handles tap', (
      tester,
    ) async {
      bool breathLungTapped = false;
      final themeController = ThemeController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              currentUser: const AuthUser(
                id: 'u1',
                displayName: 'Ali Can',
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
              onOpenBreathLung: () {
                breathLungTapped = true;
              },
            ),
            body: const Center(child: Text('Home')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Expand tracking accordion
      final trackingAccordion = find.byKey(const Key('drawer_group_tracking'));
      await tester.tap(trackingAccordion);
      await tester.pumpAndSettle();

      final breathTile = find.byKey(const Key('drawer_item_breath_lung'));
      expect(breathTile, findsOneWidget);

      await tester.tap(breathTile);
      await tester.pumpAndSettle();

      expect(breathLungTapped, isTrue);
      themeController.dispose();
    });
  });
}
