import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

void main() {
  group('LocaleController, SettingsScreen & 11-language support', () {
    test('defaults to system locale (null), supports 11 languages, and persists overrides', () async {
      SharedPreferences.setMockInitialValues({});

      expect(LocaleController.supportedLanguages.length, 11);
      expect(AppLocalizations.supportedLocales.length, 11);

      final codes =
          LocaleController.supportedLanguages.map((l) => l.code).toSet();
      expect(
        codes,
        containsAll(['tr', 'en', 'zh', 'hi', 'es', 'fr', 'ar', 'bn', 'pt', 'ru', 'ur']),
      );

      // Default is null -> follows phone system language automatically
      final controller = LocaleController();
      expect(controller.value, isNull);

      await controller.setLocale(const Locale('ar'));
      expect(controller.value, const Locale('ar'));

      final reloaded = LocaleController();
      await reloaded.load();
      expect(reloaded.value, const Locale('ar'));

      await reloaded.setLocale(null);
      final reloadedSystem = LocaleController();
      await reloadedSystem.load();
      expect(reloadedSystem.value, isNull);

      controller.dispose();
      reloaded.dispose();
      reloadedSystem.dispose();
    });

    test('AiVisionPromptBuilder injects active response language code', () {
      final req = AiVisionPromptBuilder.build(
        category: CheckCategory.tongue,
        imageBytes: Uint8List.fromList([1, 2, 3]),
        languageCode: 'es',
      );
      expect(req.userPrompt, contains('Yanıt dili (ISO-639-1): es'));
    });

    testWidgets('follows phone system language automatically and opens Settings with permissions & language', (
      tester,
    ) async {
      tester.platformDispatcher.localeTestValue = const Locale('en');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      SharedPreferences.setMockInitialValues({
        'visualcheckup_disclaimer_v1': true,
      });

      final localeController = LocaleController(); // null => system locale

      await tester.pumpWidget(
        VisualCheckUpApp(
          localeController: localeController,
          initialUser: const AuthUser(
            id: 'u_i18n',
            displayName: 'Alex Smith',
            provider: AuthProviderType.google,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Automatically picks English from phone locale (including Follow-Up track!)
      expect(find.text('Hello, Alex'), findsOneWidget);
      expect(find.text('Personal Follow-Up Plan'), findsOneWidget);
      expect(find.text('Weekly Eye (Sclera) Check'), findsOneWidget);

      // Open drawer -> Settings (English!)
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final drawerScrollable = find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ).first;
      await tester.scrollUntilVisible(
        find.text('Settings (Permissions & Language)'),
        200,
        scrollable: drawerScrollable,
      );
      await tester.tap(find.text('Settings (Permissions & Language)'));
      await tester.pumpAndSettle();

      // SettingsScreen renders fully in English
      expect(find.text('App Permissions'), findsOneWidget);
      expect(find.text('Camera Permission'), findsOneWidget);
      expect(find.text('Gallery & Photos Permission'), findsOneWidget);

      // Switch live to Arabic (RTL) and confirm Arabic text & RTL direction
      await localeController.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();
      expect(find.text('أذونات التطبيق'), findsOneWidget);
      final directionality = Directionality.of(
        tester.element(find.text('أذونات التطبيق')),
      );
      expect(directionality, TextDirection.rtl);

      localeController.dispose();
    });
  });
}
