import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/auth/data/auth_service.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

class _FakeSocialAuthAdapter implements SocialAuthAdapter {
  bool signedOutCalled = false;

  @override
  Future<AuthUser?> authenticateWithApple() async {
    return const AuthUser(
      id: 'apple_uid_42',
      displayName: 'Zeynep Kaya',
      email: 'zeynep@icloud.com',
      provider: AuthProviderType.apple,
    );
  }

  @override
  Future<AuthUser?> authenticateWithGoogle() async {
    return const AuthUser(
      id: 'google_uid_99',
      displayName: 'Ahmet Yılmaz',
      email: 'ahmet@gmail.com',
      provider: AuthProviderType.google,
    );
  }

  @override
  Future<void> signOutProvider() async {
    signedOutCalled = true;
  }
}

void main() {
  group('LocalAuthService & ThemeController', () {
    test('persists Google and Apple sessions and supports custom adapter', () async {
      SharedPreferences.setMockInitialValues({});
      final adapter = _FakeSocialAuthAdapter();
      final service = LocalAuthService(socialAdapter: adapter);

      expect(await service.loadCurrentUser(), isNull);

      final appleUser = await service.signInWithApple();
      expect(appleUser.provider, AuthProviderType.apple);
      expect(appleUser.displayName, 'Zeynep Kaya');
      expect(appleUser.initials, 'ZK');

      final restored = await service.loadCurrentUser();
      expect(restored?.id, 'apple_uid_42');
      expect(restored?.provider, AuthProviderType.apple);

      await service.signOut();
      expect(adapter.signedOutCalled, isTrue);
      expect(await service.loadCurrentUser(), isNull);

      final googleUser = await service.signInWithGoogle();
      expect(googleUser.provider, AuthProviderType.google);
      expect(googleUser.email, 'ahmet@gmail.com');
    });

    test('ThemeController persists ThemeMode across loads', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = ThemeController();
      await controller.load();
      expect(controller.value, ThemeMode.system);

      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.value, ThemeMode.dark);

      final reloaded = ThemeController();
      await reloaded.load();
      expect(reloaded.value, ThemeMode.dark);

      controller.dispose();
      reloaded.dispose();
    });
  });

  group('LoginScreen & AppDrawer widget flows', () {
    testWidgets('Apple sign-in opens HomeScreen, Drawer switches theme, and Sign Out returns to Login', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('tr')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      SharedPreferences.setMockInitialValues({
        'visualcheckup_disclaimer_v1': true,
      });

      final adapter = _FakeSocialAuthAdapter();
      final authService = LocalAuthService(socialAdapter: adapter);
      final themeController = ThemeController();

      await tester.pumpWidget(
        VisualCheckUpApp(
          authService: authService,
          themeController: themeController,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('login_terms_checkbox')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login_terms_checkbox')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Apple ile Devam Et'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple ile Devam Et'));
      await tester.pumpAndSettle();

      expect(find.text('Merhaba, Zeynep'), findsOneWidget);
      expect(find.text('ZK'), findsOneWidget);

      // Open drawer by tapping the user initials avatar in the AppBar.
      await tester.tap(find.text('ZK'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('drawer_bg_light')), findsOneWidget);
      expect(find.text('Zeynep Kaya'), findsOneWidget);
      expect(find.text('Apple Hesabı'), findsOneWidget);

      // Expand Visual Checks group (starts closed by default)
      final visualAccordion = find.byKey(const Key('drawer_group_visual'));
      await tester.tap(visualAccordion);
      await tester.pumpAndSettle();

      expect(find.text('Göz (Sklera)'), findsAtLeastNWidgets(1));
      expect(find.text('Dil'), findsAtLeastNWidgets(1));
      expect(find.text('Tırnak'), findsAtLeastNWidgets(1));

      // Switch theme mode live from Drawer.
      final drawerScrollable = find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ).first;

      // Expand Tracking accordion group
      final trackingAccordion = find.byKey(const Key('drawer_group_tracking'));
      await tester.scrollUntilVisible(
        trackingAccordion,
        150,
        scrollable: drawerScrollable,
      );
      await tester.tap(trackingAccordion);
      await tester.pumpAndSettle();

      final labReportsFinder = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Tahlil & Hastane Raporları'),
      );
      await tester.scrollUntilVisible(
        labReportsFinder,
        150,
        scrollable: drawerScrollable,
      );
      expect(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Tansiyon & Şeker Takibi'),
        ),
        findsOneWidget,
      );
      expect(labReportsFinder, findsOneWidget);
      final visualRefFinder = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Görsel Referans Rehberi'),
      );
      await tester.scrollUntilVisible(
        visualRefFinder,
        150,
        scrollable: drawerScrollable,
      );
      expect(visualRefFinder, findsOneWidget);

      // Expand Settings accordion group
      final settingsAccordion = find.byKey(const Key('drawer_group_settings'));
      await tester.scrollUntilVisible(
        settingsAccordion,
        150,
        scrollable: drawerScrollable,
      );
      await tester.tap(settingsAccordion);
      await tester.pumpAndSettle();

      final darkThemeFinder = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Koyu'),
      );
      await tester.scrollUntilVisible(
        darkThemeFinder,
        150,
        scrollable: drawerScrollable,
      );
      await tester.ensureVisible(darkThemeFinder);
      await tester.pumpAndSettle();
      await tester.tap(darkThemeFinder);
      await tester.pumpAndSettle();
      expect(themeController.value, ThemeMode.dark);
      expect(find.byKey(const ValueKey<String>('drawer_bg_dark')), findsOneWidget);

      // Sign out returns to LoginScreen.
      await tester.ensureVisible(find.text('Çıkış Yap'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Çıkış Yap'));
      await tester.pumpAndSettle();

      expect(find.text('Apple ile Devam Et'), findsOneWidget);
      expect(find.text('Google ile Devam Et'), findsOneWidget);

      themeController.dispose();
    });

    testWidgets('Google sign-in and Delete Account clears local history and returns to Login', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('tr')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      SharedPreferences.setMockInitialValues({
        'visualcheckup_disclaimer_v1': true,
      });

      final repo = HistoryRepository();
      await repo.saveResult(
        AnalysisResult(
          id: 'res_1',
          category: CheckCategory.nail,
          createdAt: DateTime(2026, 5, 1, 10, 30),
          dominantColorValue: 0xFFE0B8B0,
          riskLevel: RiskLevel.normal,
          summaryTitle: 'Doğal Tırnak Tonu',
          summaryDetail: 'Normal bulgu',
          observations: const ['Dengeli pembe tırnak yatağı'],
          recommendations: const [],
          warningFlags: const [],
          confidence: 0.85,
        ),
      );
      expect((await repo.loadHistory()).length, 1);

      final adapter = _FakeSocialAuthAdapter();
      final authService = LocalAuthService(socialAdapter: adapter);

      await tester.pumpWidget(
        VisualCheckUpApp(
          authService: authService,
          historyRepository: repo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Koşulları Oku'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Koşulları Oku'));
      await tester.pumpAndSettle();
      expect(find.text('Kullanım Koşulları & Tıbbi Uyarı'), findsOneWidget);
      await tester.tap(find.text('Okudum, Onaylıyorum'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Google ile Devam Et'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google ile Devam Et'));
      await tester.pumpAndSettle();

      expect(find.text('Merhaba, Ahmet'), findsOneWidget);

      // Open drawer and tap Delete Account.
      await tester.tap(find.byTooltip('Hesap ve Menü'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Hesabı Sil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hesabı Sil'));
      await tester.pumpAndSettle();

      // Confirm deletion in AlertDialog.
      expect(find.text('Hesabı ve Yerel Verileri Sil'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Hesabı Sil'));
      await tester.pumpAndSettle();

      expect(find.text('Google ile Devam Et'), findsOneWidget);
      expect(await repo.loadHistory(), isEmpty);
      expect(await authService.loadCurrentUser(), isNull);
    });
  });
}
