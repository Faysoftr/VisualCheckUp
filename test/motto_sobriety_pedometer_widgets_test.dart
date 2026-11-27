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

      // Visitor cannot see hidden motto
      await tester.pumpWidget(
        _wrapWithMaterial(
          ProfileMottoCard(profile: hiddenProfile, isOwner: false),
        ),
      );
      expect(find.byKey(const Key('profile_motto_card')), findsNothing);

      // Owner sees it with 'Gizli' badge and can toggle visibility
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

  group('Smoking & Alcohol Cessation Tracker (Money, Longevity & Day-by-Day)', () {
    test('Calculates daily/monthly spend, today saved, total saved, and life regained accurately', () {
      final now = DateTime(2026, 11, 27, 15, 0);
      final state = SobrietyState(
        smokeQuitAt: now.subtract(const Duration(days: 3)),
        alcoholQuitAt: now.subtract(const Duration(days: 3)),
        dailyCigarettes: 20,
        packPriceTry: 80.0, // 80/day, 2400/month
        dailyAlcoholCostTry: 120.0, // 120/day, 3600/month
      );

      expect(state.dailySmokeSpendTry, 80.0);
      expect(state.monthlySmokeSpendTry, 2400.0);
      expect(state.monthlyAlcoholSpendTry, 3600.0);
      // Started 3 days ago -> full daily rate saved today = 80 + 120 = 200 TL
      expect(state.todayMoneySavedAt(now), closeTo(200.0, 0.01));
      // 3 full days total = 600 TL
      expect(state.totalMoneySavedAt(now), closeTo(600.0, 0.01));
      // Unsmoked cigarettes = 60 -> 60 * 11 = 660 min + 3 * 45 = 135 min = 795 min
      expect(state.unsmokedCigarettesAt(now), 60);
      expect(state.lifeRegainedAt(now).inMinutes, 795);
    });

    testWidgets('SobrietyTrackerScreen starts tracker, shows today savings & day-by-day changes', (tester) async {
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

      expect(find.byKey(const Key('sobriety_hero_card')), findsOneWidget);
      expect(find.text('Gün 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sobriety_start_smoking_btn')));
      await tester.pumpAndSettle();

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

      // Start Mountain Hiking instant session while Continuous Mode is ON
      await service.startInstantSession(
        mode: WalkActivityMode.mountainHiking,
        now: t0.add(const Duration(minutes: 5)),
      );
      await service.recordSteps(1200, now: t0.add(const Duration(minutes: 20)));

      // Instant session has 1200 steps AND Continuous Mode seamlessly has 500 + 1200 = 1700!
      expect(service.state.activeSession?.steps, 1200);
      expect(service.state.todayStepsAt(t0), 1700);
      expect(service.state.thisWeekStepsAt(t0), 1700);
      expect(service.state.thisMonthStepsAt(t0), 1700);

      final completed = await service.stopInstantSession(
        now: t0.add(const Duration(minutes: 25)),
      );
      expect(completed, isNotNull);
      expect(completed!.steps, 1200);
      expect(completed.mode, WalkActivityMode.mountainHiking);
      expect(service.state.sessions.length, 1);
      // Continuous total remains 1700
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

      // Select Running mode
      await tester.tap(find.byKey(const Key('pedometer_mode_running')));
      await tester.pumpAndSettle();

      // Enable Continuous Mode
      await tester.tap(find.byKey(const Key('pedometer_continuous_switch')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pedometer_today_box')), findsOneWidget);
      expect(find.byKey(const Key('pedometer_week_box')), findsOneWidget);
      expect(find.byKey(const Key('pedometer_month_box')), findsOneWidget);

      // Start Instant Session, add +100 steps, and Stop
      await tester.tap(find.byKey(const Key('pedometer_start_instant_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pedometer_add_100_steps_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pedometer_stop_instant_btn')));
      await tester.pumpAndSettle();

      // Verify stacked history table now has 1 recorded session
      expect(
        find.textContaining('Anlık Yürüyüş Kayıtları Tablosu (1)'),
        findsOneWidget,
      );
    });
  });

  group('Customizable Quick Health Widgets Hub', () {
    testWidgets('Renders all 4 quick widgets and allows toggling in customization sheet', (tester) async {
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
      expect(find.byKey(const Key('quick_widget_sobriety')), findsOneWidget);
      expect(find.byKey(const Key('quick_widget_vitals')), findsOneWidget);
      expect(find.byKey(const Key('quick_widget_alarms')), findsOneWidget);

      // Open Customize Sheet and uncheck alarms widget
      await tester.tap(find.byKey(const Key('customize_quick_widgets_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('widget_toggle_alarms')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_quick_widgets_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quick_widget_alarms')), findsNothing);
      expect(find.byKey(const Key('quick_widget_pedometer')), findsOneWidget);
    });
  });
}
