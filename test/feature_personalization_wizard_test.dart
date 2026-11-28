import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/preferences/feature_preferences_controller.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_scheduler.dart';
import 'package:visualcheckup/features/settings/presentation/screens/settings_screen.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

void main() {
  group('Feature Personalization Wizard, Bottom Bar & Clean Drawer', () {
    testWidgets(
      'Startup wizard opens automatically on entry, saves chosen features, filters Home & Drawer, and navigates Bottom Bar',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.localesTestValue = const [Locale('tr')];
        addTearDown(tester.platformDispatcher.clearLocalesTestValue);

        SharedPreferences.setMockInitialValues({
          'visualcheckup_disclaimer_v1': true,
        });

        final featurePrefs = FeaturePreferencesController();

        await tester.pumpWidget(
          VisualCheckUpApp(
            showSplash: false,
            autoShowFeatureWizard: true,
            featurePreferencesController: featurePrefs,
            alarmScheduler: const NoopMedicationAlarmScheduler(),
            initialUser: const AuthUser(
              id: 'u_wiz_1',
              displayName: 'Ayşe Yılmaz',
              provider: AuthProviderType.google,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Startup Feature Selection Wizard appears automatically!
        expect(
          find.byKey(const Key('feature_selection_wizard_sheet')),
          findsOneWidget,
        );
        expect(find.text('Uygulamanızı Kişiselleştirin'), findsOneWidget);

        // Select "Klinik & İlaç" preset (enables only Clinical & Meds tools; hides Sobriety, Pedometer, etc.)
        await tester.tap(find.byKey(const Key('wizard_preset_clinical')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('wizard_save_btn')));
        await tester.pumpAndSettle();

        // Wizard closes & saves preferences
        expect(
          find.byKey(const Key('feature_selection_wizard_sheet')),
          findsNothing,
        );
        expect(featurePrefs.isWizardCompleted, isTrue);
        expect(
          featurePrefs.isEnabled(PersonalHealthFeature.labReports),
          isTrue,
        );
        expect(
          featurePrefs.isEnabled(PersonalHealthFeature.sobriety),
          isFalse,
        );

        // 2. Bottom Navigation Bar has 4 clear tabs
        expect(find.byKey(const Key('home_bottom_nav_bar')), findsOneWidget);

        // Switch to Tab 1: Takip Merkezi
        await tester.tap(find.byKey(const Key('bottom_nav_tracking')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('tracking_tab_customize_btn')), findsOneWidget);
        expect(find.textContaining('Tahlil'), findsAtLeastNWidgets(1));
        expect(find.text('Sigara & Alkol Bırakma'), findsNothing);

        // 3. Open Drawer and use instant module search box
        final scaffoldState =
            tester.state<ScaffoldState>(find.byType(Scaffold).first);
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();

        final searchField = find.byKey(const Key('drawer_search_field'));
        expect(searchField, findsOneWidget);
        await tester.enterText(searchField, 'Varis');
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(Drawer),
            matching: find.text('Damar & Varis Analizi'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'SettingsScreen displays Feature Selection Wizard card and allows re-selecting modules anytime',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        SharedPreferences.setMockInitialValues({});
        final featurePrefs = FeaturePreferencesController(
          initialFeatures: PersonalHealthFeatureX.clinicalPreset,
        );
        final themeController = ThemeController();
        final localeController = LocaleController(const Locale('tr'));
        addTearDown(themeController.dispose);
        addTearDown(localeController.dispose);

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('tr'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: SettingsScreen(
              themeController: themeController,
              localeController: localeController,
              historyRepository: HistoryRepository(profileId: 'test_settings_wiz'),
              featurePreferencesController: featurePrefs,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('settings_feature_wizard_card')),
          findsOneWidget,
        );
        expect(find.text('4/12'), findsOneWidget);

        await tester.tap(find.byKey(const Key('settings_open_wizard_btn')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('feature_selection_wizard_sheet')),
          findsOneWidget,
        );

        // Enable all features from Settings wizard
        await tester.tap(find.byKey(const Key('wizard_preset_all')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('wizard_save_btn')));
        await tester.pumpAndSettle();

        expect(find.text('12/12'), findsOneWidget);
        expect(featurePrefs.value.length, 12);
      },
    );

    testWidgets(
      'Wizard renders spaciously with zero overflow on standard compact phone screen (360x740)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        SharedPreferences.setMockInitialValues({});
        final featurePrefs = FeaturePreferencesController();
        final themeController = ThemeController();
        final localeController = LocaleController(const Locale('tr'));
        addTearDown(themeController.dispose);
        addTearDown(localeController.dispose);

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('tr'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: SettingsScreen(
              themeController: themeController,
              localeController: localeController,
              historyRepository: HistoryRepository(profileId: 'compact_wiz'),
              featurePreferencesController: featurePrefs,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('settings_open_wizard_btn')));
        await tester.pumpAndSettle();

        // Scrollable list occupies >75% of the sheet height on 360x740 phone!
        final listBox = tester.renderObject<RenderBox>(
          find.descendant(
            of: find.byKey(const Key('feature_selection_wizard_sheet')),
            matching: find.byType(ListView),
          ),
        );
        expect(listBox.size.height, greaterThan(540));

        await tester.tap(find.byKey(const Key('wizard_save_btn')));
        await tester.pumpAndSettle();
      },
    );
  });
}
