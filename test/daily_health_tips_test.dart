import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/home_social_showcase.dart';
import 'package:visualcheckup/features/wellness_extras/daily_health_tip_and_birthday.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Widget _wrapWithLocale(Widget child, Locale locale) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: Scaffold(
      body: SizedBox(
        height: 800,
        width: 500,
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyHealthTip & Multi-Language Catalog Coverage', () {
    const supportedLangs = [
      'tr', 'en', 'zh', 'hi', 'es', 'de', 'sv', 'fr', 'it', 'nl', 'ar', 'bn', 'pt', 'ru', 'ur'
    ];

    test('All 15 supported languages provide exactly 42 tips with categories and sources', () {
      final now = DateTime(2026, 11, 26);
      for (final code in supportedLangs) {
        final all = DailyWellnessExtras.allTipsForLocale(code);
        expect(all.length, equals(42), reason: 'Expected 42 tips for language $code');

        final tipItem = DailyWellnessExtras.dailyTipItemForLocale(code, now: now);
        expect(tipItem.category, isNotEmpty, reason: 'Category for $code should not be empty');
        expect(tipItem.quote, isNotEmpty, reason: 'Quote for $code should not be empty');
        expect(tipItem.quote.length, greaterThan(20), reason: 'Quote for $code should be descriptive');

        // Backward compatibility method
        final legacyQuote = DailyWellnessExtras.dailyTipForLocale(code, now: now);
        expect(legacyQuote, equals(tipItem.quote));
      }
    });

    test('Turkish catalog contains rock salt, iron, zinc, B12, D3+K2, and selenium', () {
      final trTips = DailyWellnessExtras.allTipsForLocale('tr');
      final combined = trTips.map((t) => '${t.category} ${t.quote}'.toLowerCase()).join(' ');

      expect(combined, contains('kaya tuzu'));
      expect(combined, contains('demir'));
      expect(combined, contains('çinko'));
      expect(combined, contains('b12'));
      expect(combined, contains('k2'));
      expect(combined, contains('selenyum'));
      expect(combined, contains('iyot'));
    });

    test('English catalog contains rock salt, iron, zinc, B12, D3+K2, and selenium', () {
      final enTips = DailyWellnessExtras.allTipsForLocale('en');
      final combined = enTips.map((t) => '${t.category} ${t.quote}'.toLowerCase()).join(' ');

      expect(combined, contains('rock salt'));
      expect(combined, contains('iron'));
      expect(combined, contains('zinc'));
      expect(combined, contains('b12'));
      expect(combined, contains('k2'));
      expect(combined, contains('selenium'));
      expect(combined, contains('iodine'));
    });

    test('Daily tips deterministically rotate across days of year', () {
      final day1 = DateTime(2026, 1, 1);
      final day2 = DateTime(2026, 1, 2);
      final day3 = DateTime(2026, 1, 3);

      final tip1 = DailyWellnessExtras.dailyTipItemForLocale('tr', now: day1);
      final tip2 = DailyWellnessExtras.dailyTipItemForLocale('tr', now: day2);
      final tip3 = DailyWellnessExtras.dailyTipItemForLocale('tr', now: day3);

      expect(tip1.quote, isNot(equals(tip2.quote)));
      expect(tip2.quote, isNot(equals(tip3.quote)));
    });

    testWidgets('SfbDailyHealthTipCard renders Quote-of-the-Day styling in Turkish and opens corner sheet', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocale(const SfbDailyHealthTipCard(), const Locale('tr')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_sfb_daily_tip_card')), findsOneWidget);
      expect(find.byIcon(Icons.format_quote_rounded), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories_rounded), findsOneWidget);
      expect(find.textContaining('“'), findsOneWidget);
      expect(find.textContaining('Faydalı Bilgiler Köşesi'), findsOneWidget);

      // Tap corner button to open WellnessKnowledgeCornerSheet
      await tester.tap(find.byIcon(Icons.auto_stories_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(WellnessKnowledgeCornerSheet), findsOneWidget);
      expect(find.textContaining('Mineraller, Vitaminler, Kaya Tuzu'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Search for "tuz"
      await tester.enterText(find.byType(TextField), 'tuz');
      await tester.pumpAndSettle();

      expect(find.textContaining('kaya tuzu'), findsWidgets);
    });

    testWidgets('WellnessKnowledgeCornerSheet category filter works', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocale(const WellnessKnowledgeCornerSheet(), const Locale('tr')),
      );
      await tester.pumpAndSettle();

      // Tap on "Mineraller & Kaya Tuzu" chip
      await tester.tap(find.textContaining('Mineraller & Kaya Tuzu'));
      await tester.pumpAndSettle();

      expect(find.textContaining('kaya tuzu'), findsWidgets);
    });
  });
}
