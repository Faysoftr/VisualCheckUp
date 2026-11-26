import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/diet/data/ai_meal_calorie_analyzer.dart';
import 'package:visualcheckup/features/diet/data/diet_repository.dart';
import 'package:visualcheckup/features/diet/data/diet_template_catalog.dart';
import 'package:visualcheckup/features/diet/domain/diet_models.dart';
import 'package:visualcheckup/features/diet/presentation/screens/diet_hub_screen.dart';
import 'package:visualcheckup/features/diet/presentation/widgets/weight_trend_chart.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

class _FakeAiCalorieAnalyzer implements MealCalorieAnalyzer {
  @override
  bool get usesCloudAi => true;

  @override
  Future<CalorieAnalysisResult> analyzePlate({
    Uint8List? imageBytes,
    String? foodDescription,
    MealSlot mealSlot = MealSlot.lunch,
    String languageCode = 'tr',
  }) async {
    return const CalorieAnalysisResult(
      dishName: 'Izgara Tavuk, Bulgur Pilavı & Salata',
      totalCalories: 540,
      proteinG: 42,
      carbsG: 48,
      fatG: 16,
      fiberG: 8.5,
      items: [
        PlateFoodItem(
          name: 'Izgara Tavuk Göğsü',
          portion: '150 g',
          calories: 250,
          proteinG: 36,
          carbsG: 0,
          fatG: 7,
        ),
        PlateFoodItem(
          name: 'Bulgur Pilavı',
          portion: '4 yemek kaşığı',
          calories: 185,
          proteinG: 4,
          carbsG: 36,
          fatG: 3,
        ),
        PlateFoodItem(
          name: 'Mevsim Salata',
          portion: '1 büyük kase',
          calories: 105,
          proteinG: 2,
          carbsG: 12,
          fatG: 6,
        ),
      ],
      healthScore: 9,
      healthComment: 'Yüksek proteinli ve dengeli bir tabak.',
      analyzedByAi: true,
    );
  }
}

Uint8List _samplePlateJpeg() {
  final image = img.Image(width: 80, height: 80);
  // Half green salad, half warm golden/brown food
  for (int y = 0; y < 80; y++) {
    for (int x = 0; x < 80; x++) {
      if (x < 40) {
        image.setPixelRgb(x, y, 50, 160, 60);
      } else {
        image.setPixelRgb(x, y, 195, 145, 70);
      }
    }
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}

Widget _wrapWithApp(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Diet models, catalog & repository', () {
    test('catalog includes 6 ready-made diets with complete daily menus', () {
      expect(DietTemplateCatalog.templates.length, 6);
      for (final tpl in DietTemplateCatalog.templates) {
        expect(tpl.days, isNotEmpty);
        expect(tpl.rules, isNotEmpty);
        expect(tpl.dailyTargetCalories, greaterThan(1000));
        for (final day in tpl.days) {
          expect(day.meals, isNotEmpty);
        }
      }
    });

    test('ActiveDietPlan computes date progress and rotates menus cleanly', () {
      final med = DietTemplateCatalog.findById('tpl_mediterranean')!;
      final start = DateTime(2026, 11, 1);
      final end = DateTime(2026, 11, 21);
      final plan = ActiveDietPlan(
        id: 'p1',
        templateId: med.id,
        title: med.title,
        goalType: med.goalType,
        startDate: start,
        endDate: end,
        dailyTargetCalories: med.dailyTargetCalories,
        startWeightKg: 82.0,
        targetWeightKg: 76.0,
        days: med.days,
        createdAt: start,
      );

      expect(plan.totalDays, 21);
      expect(plan.currentDayNumber(DateTime(2026, 11, 5)), 5);
      expect(plan.remainingDays(DateTime(2026, 11, 5)), 16);
      expect(plan.planForDate(DateTime(2026, 11, 1)).dayIndex, 1);
      expect(plan.planForDate(DateTime(2026, 11, 2)).dayIndex, 2);
      expect(plan.planForDate(DateTime(2026, 11, 4)).dayIndex, 1); // wraps

      final roundTrip = ActiveDietPlan.fromJson(plan.toJson());
      expect(roundTrip.title, med.title);
      expect(roundTrip.startWeightKg, 82.0);
      expect(roundTrip.targetWeightKg, 76.0);
    });

    test('DietRepository persists compliance, weight logs, and isolates profiles',
        () async {
      final repoA = DietRepository(profileId: 'alice');
      final repoB = DietRepository(profileId: 'bob');
      final tpl = DietTemplateCatalog.templates.first;
      final now = DateTime(2026, 11, 25);
      final plan = ActiveDietPlan(
        id: 'plan_a',
        templateId: tpl.id,
        title: tpl.title,
        goalType: tpl.goalType,
        startDate: now,
        endDate: now.add(const Duration(days: 20)),
        dailyTargetCalories: 1650,
        days: tpl.days,
        createdAt: now,
      );

      await repoA.saveActivePlan(plan);
      expect((await repoA.loadActivePlan())?.id, 'plan_a');
      expect(await repoB.loadActivePlan(), isNull);

      await repoA.setMealCompliance(
        planId: 'plan_a',
        date: now,
        slot: MealSlot.breakfast,
        status: MealComplianceStatus.followed,
      );
      await repoA.setMealCompliance(
        planId: 'plan_a',
        date: now,
        slot: MealSlot.lunch,
        status: MealComplianceStatus.notFollowed,
      );

      final summary = await repoA.getComplianceSummary('plan_a');
      expect(summary.followedCount, 1);
      expect(summary.notFollowedCount, 1);
      expect(summary.compliancePercent, 50);

      await repoA.addWeightEntry(
        DietWeightEntry(id: 'w1', weightKg: 80.5, date: now),
      );
      expect((await repoA.loadWeightEntries()).first.weightKg, 80.5);
      expect(await repoB.loadWeightEntries(), isEmpty);
    });
  });

  group('AI & Local Plate Calorie Analyzer', () {
    test('GeminiMealCalorieAnalyzer.parseAiJson parses structured dish JSON',
        () {
      const sampleJson = '''
```json
{
  "dishName": "Fırında Somon & Salata",
  "totalCalories": 490,
  "proteinG": 38.0,
  "carbsG": 14.0,
  "fatG": 31.0,
  "fiberG": 5.5,
  "healthScore": 9,
  "healthComment": "Omega-3 açısından zengin dengeli öğün.",
  "items": [
    {"name": "Somon", "portion": "150 g", "calories": 360, "proteinG": 35, "carbsG": 0, "fatG": 24},
    {"name": "Roka Salata", "portion": "1 kase", "calories": 130, "proteinG": 3, "carbsG": 14, "fatG": 7}
  ]
}
```
''';
      final result = GeminiMealCalorieAnalyzer.parseAiJson(sampleJson);
      expect(result.dishName, 'Fırında Somon & Salata');
      expect(result.totalCalories, 490);
      expect(result.proteinG, 38.0);
      expect(result.items.length, 2);
      expect(result.analyzedByAi, isTrue);

      final half = result.scaled(0.5);
      expect(half.totalCalories, 245);
      expect(half.proteinG, 19.0);
    });

    test('LocalMealCalorieEstimator sums Turkish meals and estimates photos',
        () async {
      const estimator = LocalMealCalorieEstimator();
      final textRes = await estimator.analyzePlate(
        foodDescription: 'Izgara tavuk, bulgur pilavı, mevsim salata, ayran',
      );
      expect(textRes.items.length, greaterThanOrEqualTo(4));
      expect(textRes.totalCalories, greaterThan(500));
      expect(textRes.proteinG, greaterThan(45));

      final photoRes = await estimator.analyzePlate(
        imageBytes: _samplePlateJpeg(),
        mealSlot: MealSlot.lunch,
      );
      expect(photoRes.totalCalories, inInclusiveRange(250, 750));
      expect(photoRes.items, isNotEmpty);
      final photoSum =
          photoRes.items.fold<int>(0, (sum, item) => sum + item.calories);
      expect(photoRes.totalCalories, equals(photoSum));
    });

    test(
        'LocalMealCalorieEstimator breaks composite dishes into ingredients and sums to exact total',
        () async {
      const estimator = LocalMealCalorieEstimator();
      final menemenRes = await estimator.analyzePlate(
        foodDescription: 'Menemen',
      );
      expect(menemenRes.items, isNotEmpty);
      final sumItemCal =
          menemenRes.items.fold<int>(0, (sum, i) => sum + i.calories);
      expect(menemenRes.totalCalories, equals(sumItemCal));
      expect(menemenRes.items.any((i) => i.name.contains('Yumurta')), isTrue);

      final karniRes = await estimator.analyzePlate(
        foodDescription: 'Karnıyarık',
      );
      expect(karniRes.items, isNotEmpty);
      final sumKarni =
          karniRes.items.fold<int>(0, (sum, i) => sum + i.calories);
      expect(karniRes.totalCalories, equals(sumKarni));
    });
  });

  group('DietHubScreen widget flows', () {
    testWidgets(
      'starts ready-made diet, logs Uydum/Uymadım compliance, and tracks weight',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repo = DietRepository(profileId: 'flow_diet');

        await tester.pumpWidget(
          _wrapWithApp(
            DietHubScreen(
              repository: repo,
              initialTabIndex: 1, // Hazır Diyetler
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Akdeniz Diyeti'), findsOneWidget);

        // Start Mediterranean diet
        await tester.tap(find.byKey(const Key('start_diet_tpl_mediterranean')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('start_diet_weight_field')),
          '84.0',
        );
        await tester.enterText(
          find.byKey(const Key('start_diet_target_weight_field')),
          '78.0',
        );
        await tester.tap(find.byKey(const Key('confirm_start_diet_button')));
        await tester.pumpAndSettle();

        // Switched to Active Diet tab automatically
        expect(find.text('Akdeniz Diyeti'), findsOneWidget);
        expect(find.text('Uydum'), findsWidgets);

        // Mark Breakfast as Followed ("Uydum") and Lunch as Missed ("Uymadım")
        final activeListScrollable = find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first;
        final followBreakfast = find.byKey(const Key('meal_follow_breakfast'));
        await tester.scrollUntilVisible(
          followBreakfast,
          200,
          scrollable: activeListScrollable,
        );
        await tester.ensureVisible(followBreakfast);
        await tester.pumpAndSettle();
        await tester.tap(followBreakfast);
        await tester.pumpAndSettle();

        final missLunch = find.byKey(const Key('meal_miss_lunch'));
        await tester.scrollUntilVisible(
          missLunch,
          200,
          scrollable: activeListScrollable,
        );
        await tester.ensureVisible(missLunch);
        await tester.pumpAndSettle();
        await tester.tap(missLunch);
        await tester.pumpAndSettle();

        // Scroll back to top to see updated compliance chip
        await tester.drag(find.byType(ListView).first, const Offset(0, 800));
        await tester.pumpAndSettle();
        expect(find.text('Uyum: %50'), findsOneWidget);

        // Switch to Weight tab and add a new weight entry
        await tester.tap(find.text('Kilo Takibi'));
        await tester.pumpAndSettle();

        expect(find.byType(WeightTrendChart), findsOneWidget);
        await tester.tap(find.byKey(const Key('diet_add_weight_button')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('diet_weight_input')), '82.5');
        await tester.tap(find.byKey(const Key('diet_weight_save_button')));
        await tester.pumpAndSettle();

        expect(find.text('82.5 kg'), findsWidgets);
        expect(find.text('-1.5 kg'), findsOneWidget);
      },
    );

    testWidgets(
      'calculates plate calories via AI photo independently without any diet',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repo = DietRepository(profileId: 'flow_ai_cal');

        await tester.pumpWidget(
          _wrapWithApp(
            DietHubScreen(
              repository: repo,
              calorieAnalyzer: _FakeAiCalorieAnalyzer(),
              platePhotoPicker: (_) async => _samplePlateJpeg(),
              initialTabIndex: 3, // AI Kalori (independent of any diet!)
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(await repo.loadActivePlan(), isNull);

        // Snap plate photo
        await tester.tap(find.byKey(const Key('diet_snap_plate_camera_button')));
        await tester.pumpAndSettle();

        final calScrollable = find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first;
        final resultCard = find.byKey(const Key('diet_calorie_result_card'));
        await tester.scrollUntilVisible(
          resultCard,
          250,
          scrollable: calScrollable,
        );
        expect(resultCard, findsOneWidget);
        expect(
          find.text('Izgara Tavuk, Bulgur Pilavı & Salata'),
          findsOneWidget,
        );
        expect(find.text('540 kcal'), findsOneWidget);
        expect(find.text('Gemini AI Görsel Analiz'), findsOneWidget);
        expect(
          find.byKey(const Key('diet_meal_ingredients_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('diet_total_calories_summary')),
          findsOneWidget,
        );
        expect(find.text('Toplam: 540 kcal'), findsOneWidget);

        // Save to today's log
        final saveLogBtn = find.byKey(const Key('diet_save_meal_log_button'));
        await tester.scrollUntilVisible(
          saveLogBtn,
          250,
          scrollable: calScrollable,
        );
        await tester.ensureVisible(saveLogBtn);
        await tester.pumpAndSettle();
        await tester.tap(saveLogBtn);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pumpAndSettle();

        // Scroll back to top to see Today's total updated
        await tester.drag(find.byType(ListView).first, const Offset(0, 900));
        await tester.pumpAndSettle();

        expect(find.text('540 / 2000 kcal'), findsOneWidget);
        expect((await repo.loadCalorieScans()).length, 1);
      },
    );

    testWidgets('renders localized strings in English and Arabic',
        (tester) async {
      final repo = DietRepository(profileId: 'flow_l10n');

      await tester.pumpWidget(
        _wrapWithApp(
          DietHubScreen(repository: repo, initialTabIndex: 0),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Diet & AI Calorie Tracker'), findsOneWidget);
      expect(find.text('Browse Ready-Made Diets'), findsOneWidget);

      await tester.pumpWidget(
        _wrapWithApp(
          DietHubScreen(repository: repo, initialTabIndex: 0),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('الرجيم وحساب السعرات بالذكاء الاصطناعي'), findsOneWidget);
    });

    testWidgets(
      'creates a custom user-entered diet plan, activates it, and saves reusable template',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repo = DietRepository(profileId: 'custom_diet_test');

        await tester.pumpWidget(
          _wrapWithApp(
            DietHubScreen(repository: repo, initialTabIndex: 1),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('diet_create_custom_button')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('custom_diet_name_field')),
          'Diyetisyen Listem',
        );

        final breakfastField =
            find.byKey(const Key('custom_meal_breakfast_field'));
        await tester.ensureVisible(breakfastField);
        await tester.enterText(
          breakfastField,
          '2 haşlanmış yumurta ve yeşillik',
        );

        final dinnerField = find.byKey(const Key('custom_meal_dinner_field'));
        await tester.ensureVisible(dinnerField);
        await tester.enterText(dinnerField, 'Mercimek çorbası ve yoğurt');
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_custom_diet_button')));
        await tester.pumpAndSettle();

        // Active diet is now our custom diet with our entered meals!
        expect(find.text('Diyetisyen Listem'), findsOneWidget);
        expect(find.text('2 haşlanmış yumurta ve yeşillik'), findsOneWidget);

        final customTemplates = await repo.loadCustomTemplates();
        expect(customTemplates.length, 1);
        expect(customTemplates.first.title, 'Diyetisyen Listem');
        expect(customTemplates.first.isCustom, isTrue);
      },
    );
  });
}
