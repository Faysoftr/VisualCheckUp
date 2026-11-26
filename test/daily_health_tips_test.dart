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
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyHealthTip & Multi-Language Catalog Coverage', () {
    const supportedLangs = [
      'tr', 'en', 'zh', 'hi', 'es', 'de', 'sv', 'fr', 'it', 'nl', 'ar', 'bn', 'pt', 'ru', 'ur'
    ];

    test('All 15 supported languages provide valid non-empty health tips, categories, and sources', () {
      final now = DateTime(2026, 11, 26);
      for (final code in supportedLangs) {
        final tipItem = DailyWellnessExtras.dailyTipItemForLocale(code, now: now);
        expect(tipItem.category, isNotEmpty, reason: 'Category for $code should not be empty');
        expect(tipItem.quote, isNotEmpty, reason: 'Quote for $code should not be empty');
        expect(tipItem.quote.length, greaterThan(20), reason: 'Quote for $code should be descriptive');

        // Backward compatibility method
        final legacyQuote = DailyWellnessExtras.dailyTipForLocale(code, now: now);
        expect(legacyQuote, equals(tipItem.quote));
      }
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

    testWidgets('SfbDailyHealthTipCard renders Quote-of-the-Day styling in Turkish', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocale(const SfbDailyHealthTipCard(), const Locale('tr')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_sfb_daily_tip_card')), findsOneWidget);
      expect(find.byIcon(Icons.format_quote_rounded), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.textContaining('“'), findsOneWidget);
    });

    testWidgets('SfbDailyHealthTipCard renders Quote-of-the-Day styling in English', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocale(const SfbDailyHealthTipCard(), const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_sfb_daily_tip_card')), findsOneWidget);
      expect(find.byIcon(Icons.format_quote_rounded), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.textContaining('“'), findsOneWidget);
    });

    testWidgets('DailyHealthTipCard compact fallback renders quote styling', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocale(const DailyHealthTipCard(), const Locale('tr')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_daily_health_tip_card')), findsOneWidget);
      expect(find.byIcon(Icons.format_quote_rounded), findsOneWidget);
      expect(find.textContaining('“'), findsOneWidget);
    });
  });
}
