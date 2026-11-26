import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/home_screen.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_scheduler.dart';
import 'package:visualcheckup/features/support/presentation/widgets/donation_support_dialog.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'visualcheckup_disclaimer_accepted_v1': true,
    });
  });

  group('DonationSupportDialog & Home/Drawer placements', () {
    testWidgets(
      'AppBar donate button sits between menu icon and title and opens popup',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final themeController = ThemeController();
        addTearDown(themeController.dispose);
        final historyRepo = HistoryRepository(profileId: 'donate_test');
        await historyRepo.setDisclaimerAccepted();

        await tester.pumpWidget(
          _wrap(
            HomeScreen(
              analyzer: ColorHealthAnalyzer(),
              historyRepository: historyRepo,
              alarmScheduler: const NoopMedicationAlarmScheduler(),
              currentUser: const AuthUser(
                id: 'u1',
                displayName: 'Test User',
                provider: AuthProviderType.guest,
              ),
              themeController: themeController,
              onSignOut: () {},
              onDeleteAccount: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        final menuPos = tester.getCenter(find.byIcon(Icons.menu_rounded));
        final donateBtn = find.byKey(const Key('home_donate_appbar_button'));
        final donatePos = tester.getCenter(donateBtn);
        final titlePos = tester.getCenter(find.text('VisualCheckUp'));

        expect(donatePos.dx, greaterThan(menuPos.dx));
        expect(donatePos.dx, lessThan(titlePos.dx));

        // Tap AppBar donate button -> popup opens
        await tester.tap(donateBtn);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('donation_support_dialog')), findsOneWidget);
        expect(find.text('\$3.99'), findsOneWidget);
        expect(find.text('\$9.99'), findsOneWidget);
        expect(find.text('\$19.99'), findsOneWidget);
        expect(find.text('\$29.99'), findsOneWidget);
        expect(find.text('\$49.99'), findsOneWidget);

        // Select Coffee ($3.99) and confirm
        await tester.tap(find.byKey(const Key('donate_tier_coffee')));
        await tester.pumpAndSettle();
        expect(find.text('\$3.99 Destek Ol'), findsOneWidget);

        await tester.tap(find.byKey(const Key('donate_confirm_button')));
        await tester.pumpAndSettle();

        expect(find.text('Desteğiniz İçin Teşekkürler!'), findsOneWidget);
        expect(await DonationSupportDialog.isSupporter(), isTrue);
      },
    );

    testWidgets(
      'AppDrawer displays Donate button at top of menu and opens popup',
      (tester) async {
        final themeController = ThemeController();
        addTearDown(themeController.dispose);
        final historyRepo = HistoryRepository(profileId: 'drawer_donate_test');
        await historyRepo.setDisclaimerAccepted();

        await tester.pumpWidget(
          _wrap(
            HomeScreen(
              analyzer: ColorHealthAnalyzer(),
              historyRepository: historyRepo,
              alarmScheduler: const NoopMedicationAlarmScheduler(),
              currentUser: const AuthUser(
                id: 'u1',
                displayName: 'Test User',
                provider: AuthProviderType.guest,
              ),
              themeController: themeController,
              onSignOut: () {},
              onDeleteAccount: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open drawer
        await tester.tap(find.byIcon(Icons.menu_rounded));
        await tester.pumpAndSettle();

        final drawerDonate = find.byKey(const Key('drawer_donate_button'));
        expect(drawerDonate, findsOneWidget);

        // Verify Donate button appears below Home menu tile
        final donateTop = tester.getTopLeft(drawerDonate).dy;
        final homeTop =
            tester.getTopLeft(find.byIcon(Icons.grid_view_rounded)).dy;
        expect(homeTop, lessThan(donateTop));

        // Tap drawer donate button -> opens popup
        await tester.tap(drawerDonate);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('donation_support_dialog')), findsOneWidget);
      },
    );

    testWidgets('DonationSupportDialog localizes in English and Arabic',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Scaffold(body: DonationSupportDialog()),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Support VisualCheckUp'), findsOneWidget);
      expect(find.text('Buy a Coffee'), findsOneWidget);
      expect(find.text('Treat to a Meal'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const Scaffold(body: DonationSupportDialog()),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ادعم VisualCheckUp'), findsOneWidget);
      expect(find.text('كوب قهوة'), findsOneWidget);
    });
  });
}
