import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/screens/lab_reports_screen.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/screens/vitals_tracker_screen.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

void main() {
  group('LocaleController, SettingsScreen & 15-language support', () {
    test('all 15 ARB files have identical complete key sets and non-empty translations', () {
      const codes = [
        'en', 'tr', 'ar', 'bn', 'de', 'es', 'fr', 'hi', 'it', 'nl', 'pt', 'ru',
        'sv', 'ur', 'zh',
      ];
      final templateJson =
          jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
              as Map<String, dynamic>;
      final templateKeys = templateJson.keys
          .where((k) => !k.startsWith('@'))
          .toSet();

      expect(templateKeys.length, greaterThan(250));

      for (final code in codes) {
        final file = File('lib/l10n/app_$code.arb');
        expect(file.existsSync(), isTrue, reason: 'Missing ARB for $code');
        final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final keys = data.keys.where((k) => !k.startsWith('@')).toSet();

        final missing = templateKeys.difference(keys);
        final extra = keys.difference(templateKeys);
        expect(
          missing,
          isEmpty,
          reason: 'app_$code.arb is missing keys: $missing',
        );
        expect(
          extra,
          isEmpty,
          reason: 'app_$code.arb has unexpected keys: $extra',
        );

        for (final key in templateKeys) {
          final val = data[key];
          expect(
            val is String && val.trim().isNotEmpty,
            isTrue,
            reason: 'app_$code.arb has empty translation for "$key"',
          );
        }
      }
    });

    test('defaults to system locale (null), supports 15 languages, and persists overrides', () async {
      SharedPreferences.setMockInitialValues({});

      expect(LocaleController.supportedLanguages.length, 15);
      expect(AppLocalizations.supportedLocales.length, 15);

      final codes =
          LocaleController.supportedLanguages.map((l) => l.code).toSet();
      expect(
        codes,
        containsAll([
          'tr', 'en', 'zh', 'hi', 'es', 'de', 'sv', 'fr', 'it', 'nl', 'ar',
          'bn', 'pt', 'ru', 'ur',
        ]),
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
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
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

      final settingsAccordion = find.byKey(const Key('drawer_group_settings'));
      await tester.scrollUntilVisible(
        settingsAccordion,
        150,
        scrollable: drawerScrollable,
      );
      await tester.tap(settingsAccordion);
      await tester.pumpAndSettle();

      final settingsTile = find.text('Settings (Permissions & Language)');
      await tester.scrollUntilVisible(
        settingsTile,
        200,
        scrollable: drawerScrollable,
      );
      await tester.ensureVisible(settingsTile);
      await tester.pumpAndSettle();
      await tester.tap(settingsTile);
      await tester.pumpAndSettle();

      // SettingsScreen renders fully in English (including Cloud Backup section!)
      expect(find.text('App Permissions'), findsOneWidget);
      expect(find.text('Camera Permission'), findsOneWidget);
      expect(find.text('Gallery & Photos Permission'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Cloud Backup (Optional • Firebase)'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Cloud Backup (Optional • Firebase)'), findsOneWidget);
      expect(find.textContaining('Bulut Yedekleme'), findsNothing);

      // Switch live to Arabic (RTL) and confirm Arabic text & RTL direction
      await localeController.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('أذونات التطبيق'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('أذونات التطبيق'), findsOneWidget);
      final directionality = Directionality.of(
        tester.element(find.text('أذونات التطبيق')),
      );
      expect(directionality, TextDirection.rtl);

      localeController.dispose();
    });

    testWidgets('Recent Checks and HistoryScreen translate stored Turkish checks into active language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.platformDispatcher.localeTestValue = const Locale('en');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      SharedPreferences.setMockInitialValues({
        'visualcheckup_disclaimer_v1': true,
      });

      final historyRepo = HistoryRepository();
      // Pre-populate a legacy Turkish check persisted by the on-device analyzer
      await historyRepo.saveResult(
        AnalysisResult(
          id: 'tr_legacy_1',
          category: CheckCategory.eye,
          createdAt: DateTime(2026, 5, 20, 14, 30),
          dominantColorValue: 0xFFF5ECE6,
          riskLevel: RiskLevel.normal,
          summaryTitle: 'Göz akında belirgin sarılık veya kızarıklık saptanmadı',
          summaryDetail: 'Olağan görünüm.',
          observations: const ['Olağan sklera tonu'],
          recommendations: const ['Takibe devam edin'],
          warningFlags: const [],
          confidence: 0.88,
        ),
      );

      final localeController = LocaleController();
      await localeController.setLocale(const Locale('en'));

      await tester.pumpWidget(
        VisualCheckUpApp(
          historyRepository: historyRepo,
          localeController: localeController,
          initialUser: const AuthUser(
            id: 'guest_en',
            displayName: 'Guest',
            provider: AuthProviderType.guest,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Guest badge on hero card should be English, not Turkish "Misafir"
      expect(find.text('Guest'), findsOneWidget);
      expect(find.text('Misafir'), findsNothing);

      // Scroll down to Recent Checks and verify zero Turkish leakage
      final recentItem = find.text('Eye (Sclera) • Normal Appearance');
      await tester.scrollUntilVisible(
        recentItem,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Recent Checks'), findsOneWidget);
      expect(recentItem, findsOneWidget);
      expect(
        find.text('Göz akında belirgin sarılık veya kızarıklık saptanmadı'),
        findsNothing,
      );

      // Open HistoryScreen via "See All" and confirm English UI + localized title
      await tester.tap(find.text('See All'));
      await tester.pumpAndSettle();

      expect(find.text('Checkup History'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Eye (Sclera) • Normal Appearance'), findsOneWidget);
      expect(find.text('Kontrol Geçmişi'), findsNothing);
      expect(find.text('Tümü'), findsNothing);

      localeController.dispose();
    });

    testWidgets('VitalsTrackerScreen and LabReportsScreen render fully in English and Spanish', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repo = LabsVitalsRepository();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VitalsTrackerScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Blood Pressure & Sugar'), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);
      expect(find.text('Blood Sugar'), findsOneWidget);
      expect(find.text('Add Blood Pressure'), findsOneWidget);
      expect(find.textContaining('Tansiyon'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LabReportsScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Análisis e informes'), findsOneWidget);
      expect(find.text('Mis informes'), findsOneWidget);
      expect(find.text('Tendencias'), findsOneWidget);
      expect(find.textContaining('Raporlarım'), findsNothing);
    });
  });
}
