import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/widgets/profile_wellness_cards.dart';
import 'package:visualcheckup/features/pedometer/data/pedometer_service.dart';
import 'package:visualcheckup/features/pedometer/domain/pedometer_models.dart';
import 'package:visualcheckup/features/pedometer/presentation/screens/step_counter_screen.dart';
import 'package:visualcheckup/features/sobriety/data/sobriety_repository.dart';
import 'package:visualcheckup/features/sobriety/domain/sobriety_models.dart';
import 'package:visualcheckup/features/sobriety/presentation/screens/sobriety_tracker_screen.dart';
import 'package:visualcheckup/features/widgets_hub/presentation/screens/widgets_manager_screen.dart';
import 'package:visualcheckup/features/widgets_hub/presentation/widgets/health_quick_widgets_hub.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Widget _wrapWithMaterial(Widget child) {
  return MaterialApp(
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Motto Card & Profile Wellness Serialization', () {
    test('HealthCommunityProfile serializes motto, sobriety, and step fields', () {
      final now = DateTime(2026, 11, 27, 12, 0);
      final profile = HealthCommunityProfile(
        uid: 'u1',
        displayName: 'Test User',
        bio: 'Sağlık yolculuğum devam ediyor.',
        motto: HealthyLivingMottos.presets.first,
        showMotto: true,
        showBio: true,
        showSobrietyOnProfile: true,
        smokeQuitAt: now.subtract(const Duration(days: 5)),
        todayStepsCount: 7500,
        weekStepsCount: 42000,
        monthStepsCount: 155000,
        showStepsOnProfile: true,
        updatedAt: now,
      );

      final restored = HealthCommunityProfile.fromJson(profile.toJson());
      expect(restored.motto, HealthyLivingMottos.presets.first);
      expect(restored.showMotto, isTrue);
      expect(restored.todayStepsCount, 7500);
      expect(restored.weekStepsCount, 42000);
      expect(restored.monthStepsCount, 155000);
      expect(restored.smokeQuitAt, isNotNull);
    });

    testWidgets('ProfileMottoCard respects showMotto for visitors and allows owner toggle', (tester) async {
      bool? lastVisibility;
      final hiddenProfile = HealthCommunityProfile(
        uid: 'u2',
        displayName: 'Ayşe',
        motto: 'Hareket berekettir!',
        showMotto: false,
        updatedAt: DateTime(2026, 11, 27),
      );

      await tester.pumpWidget(
        _wrapWithMaterial(
          ProfileMottoCard(profile: hiddenProfile, isOwner: false),
        ),
      );
      expect(find.byKey(const Key('profile_motto_card')), findsNothing);

      await tester.pumpWidget(
        _wrapWithMaterial(
          ProfileMottoCard(
            profile: hiddenProfile,
            isOwner: true,
            onToggleVisibility: (v) => lastVisibility = v,
          ),
        ),
      );
      expect(find.byKey(const Key('profile_motto_card')), findsOneWidget);
      expect(find.text('Gizli'), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile_motto_visibility_btn')));
      expect(lastVisibility, isTrue);
    });
  });

  group('Smoking & Alcohol Cessation Tracker (Progressive In-Card Day-by-Day)', () {
    test('Calculates daily/monthly spend, today saved, total saved, life regained & progressive feed', () {
      final now = DateTime(2026, 11, 27, 15, 0);
      final state = SobrietyState(
        smokeQuitAt: now.subtract(const Duration(days: 2)), // Day 3
        alcoholQuitAt: now.subtract(const Duration(days: 2)),
        dailyCigarettes: 20,
        packPriceTry: 80.0,
        dailyAlcoholCostTry: 120.0,
      );

      expect(state.smokeCurrentDayNumber(now), 3);
      expect(state.todayMoneySavedAt(now), closeTo(200.0, 0.01));
      expect(state.totalMoneySavedAt(now), closeTo(400.0, 0.01));

      // Unlocked feed on Day 3 MUST ONLY contain Days 3, 2, 1 (never future days!)
      final feed = SobrietyKnowledgeBase.unlockedDailyFeed(3);
      expect(feed.map((m) => m.dayNumber).toList(), [3, 2, 1]);
      expect(SobrietyKnowledgeBase.unlockedDailyFeed(0), isEmpty);
    });

    testWidgets('SobrietyTrackerScreen reveals ONLY reached days inside card as days pass', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = SobrietyRepository(profileId: 'test_sob');
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SobrietyTrackerScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Before starting: NO day change box is shown, future days are NOT dumped!
      expect(find.byKey(const Key('sobriety_live_day_box_smoking')), findsNothing);
      expect(find.textContaining('Gün 30'), findsNothing);
      expect(find.textContaining('Gün 365'), findsNothing);

      // Start smoking tracker -> ONLY Day 1 appears inside the card!
      await tester.tap(find.byKey(const Key('sobriety_start_smoking_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sobriety_live_day_box_smoking')), findsOneWidget);
      expect(find.text('Gün 1'), findsWidgets);
      expect(find.textContaining('Gün 30'), findsNothing);
      expect(find.textContaining('Kazandınız!'), findsOneWidget);

      // Switch to Harms tab
      await tester.tap(find.byKey(const Key('sobriety_tab_harms')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Akciğerler'), findsOneWidget);
    });
  });

  group('Dual-Mode Step Counter (Continuous + Instant Session + Table)', () {
    test('Continuous mode merges instant walk steps and builds session history table', () async {
      final service = PedometerService(profileId: 'test_steps');
      final t0 = DateTime(2026, 11, 27, 10, 0);

      await service.setContinuousMode(true, now: t0);
      await service.recordSteps(500, now: t0);
      expect(service.state.todayStepsAt(t0), 500);

      await service.startInstantSession(
        mode: WalkActivityMode.mountainHiking,
        now: t0.add(const Duration(minutes: 5)),
      );
      await service.recordSteps(1200, now: t0.add(const Duration(minutes: 20)));

      expect(service.state.activeSession?.steps, 1200);
      expect(service.state.todayStepsAt(t0), 1700);

      final completed = await service.stopInstantSession(
        now: t0.add(const Duration(minutes: 25)),
      );
      expect(completed, isNotNull);
      expect(completed!.steps, 1200);
      expect(service.state.sessions.length, 1);
      expect(service.state.todayStepsAt(t0), 1700);
    });

    testWidgets('StepCounterScreen switches modes, runs instant session, and populates DataTable', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final service = PedometerService(profileId: 'ui_steps');
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StepCounterScreen(service: service),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pedometer_mode_running')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pedometer_continuous_switch')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pedometer_today_box')), findsOneWidget);
      expect(find.byKey(const Key('pedometer_week_box')), findsOneWidget);
      expect(find.byKey(const Key('pedometer_month_box')), findsOneWidget);

      await tester.tap(find.byKey(const Key('pedometer_start_instant_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pedometer_add_100_steps_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pedometer_stop_instant_btn')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Anlık Yürüyüş Kayıtları Tablosu (1)'),
        findsOneWidget,
      );
    });
  });

  group('Closable Widgets Hub & Android Home Screen Widgets Manager', () {
    testWidgets('Allows closing single widgets, closing entire hub, and pinning Android widgets', (tester) async {
      await tester.pumpWidget(
        _wrapWithMaterial(
          SingleChildScrollView(
            child: HealthQuickWidgetsHub(
              pedometerService: PedometerService(profileId: 'hub_ped'),
              sobrietyRepository: SobrietyRepository(profileId: 'hub_sob'),
              onOpenPedometer: () {},
              onOpenSobriety: () {},
              onOpenVitals: () {},
              onOpenAlarms: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quick_widget_pedometer')), findsOneWidget);
      expect(find.byKey(const Key('quick_widget_alarms')), findsOneWidget);

      // 1-tap close single Alarms widget directly from its card
      await tester.tap(find.byKey(const Key('close_widget_alarms_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quick_widget_alarms')), findsNothing);
      expect(find.byKey(const Key('quick_widget_pedometer')), findsOneWidget);

      // 1-tap close the entire widgets hub
      await tester.tap(find.byKey(const Key('close_quick_widgets_hub_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('health_quick_widgets_hub')), findsNothing);

      // Open dedicated WidgetsManagerScreen -> verify Android pin buttons & re-enable hub
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WidgetsManagerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('android_pin_all_btn')), findsOneWidget);
      expect(find.byKey(const Key('android_pin_pedometer_btn')), findsOneWidget);
      expect(find.byKey(const Key('android_pin_sobriety_btn')), findsOneWidget);
      expect(find.byKey(const Key('android_pin_vitals_btn')), findsOneWidget);
      expect(find.byKey(const Key('android_pin_alarms_btn')), findsOneWidget);
    });
  });
}
