import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/diet/data/ai_meal_calorie_analyzer.dart';
import 'package:visualcheckup/features/diet/data/diet_repository.dart';
import 'package:visualcheckup/features/diet/domain/diet_models.dart';
import 'package:visualcheckup/features/diet/presentation/screens/diet_hub_screen.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';
import 'package:visualcheckup/features/subscription/domain/subscription_models.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

class _FakeAnalyzer implements MealCalorieAnalyzer {
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
      dishName: 'Izgara Köfte & Salata',
      totalCalories: 450,
      proteinG: 30,
      carbsG: 15,
      fatG: 20,
      fiberG: 5,
      items: [],
      healthScore: 8,
      healthComment: 'Dengeli öğün',
      analyzedByAi: true,
    );
  }
}

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('tr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Domain & Repository Quota Calculation', () {
    test('Daily Plate Calorie limits: Free=2, Pro=20, Admin=unlimited', () {
      final repo = SubscriptionRepository();
      const freeSub = UserSubscriptionState(tier: SubscriptionTier.free);
      final proSub = UserSubscriptionState(
        tier: SubscriptionTier.proMonthly,
        activatedAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 29)),
      );

      expect(repo.dailyPlateCalorieLimit(subscription: freeSub), 2);
      expect(repo.dailyPlateCalorieLimit(subscription: proSub), 20);
      expect(
        repo.dailyPlateCalorieLimit(subscription: freeSub, isAdmin: true),
        999999,
      );
    });

    test('canScanPlateCalorie enforces 2/day for free and 20/day for pro', () {
      final repo = SubscriptionRepository();
      const freeSub = UserSubscriptionState(tier: SubscriptionTier.free);
      final now = DateTime.now();

      final zeroScans = <CalorieScanEntry>[];
      expect(
        repo.canScanPlateCalorie(scans: zeroScans, subscription: freeSub),
        isTrue,
      );
      expect(
        repo.remainingPlateCalorieScansToday(
          scans: zeroScans,
          subscription: freeSub,
        ),
        2,
      );

      final oneScan = [
        CalorieScanEntry(
          id: 's1',
          createdAt: now,
          dateKey: ActiveDietPlan.dateKeyFor(now),
          mealSlot: MealSlot.lunch,
          dishName: 'Salata',
          totalCalories: 150,
          proteinG: 2,
          carbsG: 10,
          fatG: 5,
          fiberG: 3,
          items: const [],
          healthScore: 9,
          healthComment: 'Hafif',
          analyzedByAi: true,
        ),
      ];
      expect(
        repo.canScanPlateCalorie(scans: oneScan, subscription: freeSub),
        isTrue,
      );
      expect(
        repo.remainingPlateCalorieScansToday(
          scans: oneScan,
          subscription: freeSub,
        ),
        1,
      );

      final twoScans = [
        ...oneScan,
        CalorieScanEntry(
          id: 's2',
          createdAt: now,
          dateKey: ActiveDietPlan.dateKeyFor(now),
          mealSlot: MealSlot.dinner,
          dishName: 'Çorba',
          totalCalories: 200,
          proteinG: 5,
          carbsG: 25,
          fatG: 4,
          fiberG: 2,
          items: const [],
          healthScore: 8,
          healthComment: 'Sıcak',
          analyzedByAi: true,
        ),
      ];
      // Free user has reached 2 scans today!
      expect(
        repo.canScanPlateCalorie(scans: twoScans, subscription: freeSub),
        isFalse,
      );
      expect(
        repo.remainingPlateCalorieScansToday(
          scans: twoScans,
          subscription: freeSub,
        ),
        0,
      );

      // Pro user is allowed up to 20 scans
      final proSub = UserSubscriptionState(
        tier: SubscriptionTier.proMonthly,
        activatedAt: now.subtract(const Duration(days: 1)),
        expiresAt: now.add(const Duration(days: 29)),
      );
      expect(
        repo.canScanPlateCalorie(scans: twoScans, subscription: proSub),
        isTrue,
      );
      expect(
        repo.remainingPlateCalorieScansToday(
          scans: twoScans,
          subscription: proSub,
        ),
        18,
      );

      // Admin is unlimited
      expect(
        repo.canScanPlateCalorie(
          scans: twoScans,
          subscription: freeSub,
          isAdmin: true,
        ),
        isTrue,
      );
      expect(
        repo.remainingPlateCalorieScansToday(
          scans: twoScans,
          subscription: freeSub,
          isAdmin: true,
        ),
        -1,
      );
    });

    test('Daily Message Quota: Free=10, Pro=500, Admin=999999', () {
      final repo = SubscriptionRepository();
      const freeSub = UserSubscriptionState(tier: SubscriptionTier.free);
      final proSub = UserSubscriptionState(
        tier: SubscriptionTier.proMonthly,
        activatedAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 29)),
      );

      expect(repo.dailyDirectMessageLimit(subscription: freeSub), 10);
      expect(repo.dailyDirectMessageLimit(subscription: proSub), 500);
      expect(
        repo.dailyDirectMessageLimit(subscription: freeSub, isAdmin: true),
        999999,
      );
    });
  });

  group('DietHubScreen Plate Calorie Quota Enforcement & Upsell Sheet', () {
    testWidgets(
      'Free user with 2 scans today sees quota badge and gets blocked with Pro upsell sheet',
      (tester) async {
        final dietRepo = DietRepository(profileId: 'free_quota_test');
        final now = DateTime.now();

        // Seed 2 scans for today
        await dietRepo.saveCalorieScan(
          CalorieScanEntry(
            id: 'scan_1',
            createdAt: now,
            dateKey: ActiveDietPlan.dateKeyFor(now),
            mealSlot: MealSlot.breakfast,
            dishName: 'Yumurta',
            totalCalories: 150,
            proteinG: 12,
            carbsG: 1,
            fatG: 10,
            fiberG: 0,
            items: const [],
            healthScore: 9,
            healthComment: 'Proteinli',
            analyzedByAi: true,
          ),
        );
        await dietRepo.saveCalorieScan(
          CalorieScanEntry(
            id: 'scan_2',
            createdAt: now,
            dateKey: ActiveDietPlan.dateKeyFor(now),
            mealSlot: MealSlot.lunch,
            dishName: 'Tavuk Salata',
            totalCalories: 350,
            proteinG: 35,
            carbsG: 10,
            fatG: 12,
            fiberG: 4,
            items: const [],
            healthScore: 9,
            healthComment: 'Dengeli',
            analyzedByAi: true,
          ),
        );

        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _wrap(
            DietHubScreen(
              repository: dietRepo,
              calorieAnalyzer: _FakeAnalyzer(),
              userEmail: 'normal_user@example.com',
              initialTabIndex: 3, // AI Calories Tab
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check Quota Badge
        expect(
          find.byKey(const Key('diet_plate_calorie_quota_badge')),
          findsOneWidget,
        );
        expect(find.textContaining('Kalan Hak: 0 / 2'), findsOneWidget);
        expect(find.textContaining('Bugün 2 yapıldı'), findsOneWidget);
        expect(
          find.byKey(const Key('diet_quota_upgrade_chip')),
          findsOneWidget,
        );

        // Try scanning from text input
        final inputField = find.byKey(const Key('diet_food_desc_field'));
        await tester.ensureVisible(inputField);
        await tester.pumpAndSettle();
        await tester.enterText(inputField, 'Mercimek Çorbası');

        final calcBtn = find.byKey(const Key('diet_calculate_text_button'));
        await tester.ensureVisible(calcBtn);
        await tester.pumpAndSettle();
        await tester.tap(calcBtn);
        await tester.pumpAndSettle();

        // Quota sheet appears!
        expect(find.text('Günlük Tabak Kalori Limiti Doldu'), findsOneWidget);
        expect(
          find.textContaining('günde en fazla 2 tabak kalori analizi'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('diet_upgrade_pro_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets('Admin user sees unlimited crown badge and is never blocked',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final dietRepo = DietRepository(profileId: 'admin_quota_test');
        final now = DateTime.now();

        // Seed 5 scans (far above 2)
        for (var i = 1; i <= 5; i++) {
          await dietRepo.saveCalorieScan(
            CalorieScanEntry(
              id: 'scan_$i',
              createdAt: now,
              dateKey: ActiveDietPlan.dateKeyFor(now),
              mealSlot: MealSlot.breakfast,
              dishName: 'Öğün $i',
              totalCalories: 200,
              proteinG: 10,
              carbsG: 10,
              fatG: 5,
              fiberG: 2,
              items: const [],
              healthScore: 9,
              healthComment: 'Öğün',
              analyzedByAi: true,
            ),
          );
        }

        await tester.pumpWidget(
          _wrap(
            DietHubScreen(
              repository: dietRepo,
              calorieAnalyzer: _FakeAnalyzer(),
              userEmail: AdminUtils.adminEmail, // Admin!
              initialTabIndex: 3,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Yönetici Hesabı: Sınırsız AI Tabak Kalori Analizi 👑'),
          findsOneWidget,
        );

        // Admin scans 6th meal smoothly without blocker sheet
        final inputField = find.byKey(const Key('diet_food_desc_field'));
        await tester.ensureVisible(inputField);
        await tester.pumpAndSettle();
        await tester.enterText(inputField, 'Admin Özel Öğün');

        final calcBtn = find.byKey(const Key('diet_calculate_text_button'));
        await tester.ensureVisible(calcBtn);
        await tester.pumpAndSettle();
        await tester.tap(calcBtn);
        await tester.pumpAndSettle();

        expect(find.text('Günlük Tabak Kalori Limiti Doldu'), findsNothing);
        expect(find.text('Izgara Köfte & Salata'), findsOneWidget);
      },
    );
  });

  group('HealthChatScreen & Community Direct Message Quota', () {
    test(
      'Community repository enforces 10 messages for free, 500 for pro, unlimited for admin',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final commRepo = HealthCommunityRepository(
          useFirebase: false,
          rateLimitSeconds: 0,
        );

        final receiver = HealthCommunityProfile(
          uid: 'rec_1',
          displayName: 'Ali Kaya',
          nickname: 'ali_k',
          updatedAt: DateTime.now(),
        );

        const senderUid = 'free_sender_1';
        final now = DateTime.now();
        final todayKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        // Set sent count to 10 today
        await prefs.setString(
          'visualcheckup_comm_rate_v1_$senderUid',
          '{"lastMs": ${now.millisecondsSinceEpoch}, "date": "$todayKey", "count": 10}',
        );

        // 11th message as free user
        final freeStatus = await commRepo.sendMessage(
          senderUid: senderUid,
          senderDisplayName: 'Ayşe Free',
          senderEmail: 'ayse@free.com',
          receiver: receiver,
          text: '11. mesaj',
        );
        expect(freeStatus, SendMessageStatus.dailyLimitExceeded);

        // Same sent count (10) as admin user -> allowed!
        final adminStatus = await commRepo.sendMessage(
          senderUid: senderUid,
          senderDisplayName: 'Admin User',
          senderEmail: AdminUtils.adminEmail,
          receiver: receiver,
          text: 'Admin mesajı',
        );
        expect(adminStatus, SendMessageStatus.sent);
      },
    );

    testWidgets(
      'HealthChatScreen shows upgrade bottom sheet when daily message limit is exceeded',
      (tester) async {
        final prefs = await SharedPreferences.getInstance();
        final commRepo = HealthCommunityRepository(
          useFirebase: false,
          rateLimitSeconds: 0,
        );

        final receiver = HealthCommunityProfile(
          uid: 'rec_2',
          displayName: 'Mehmet Öz',
          nickname: 'mehmet_o',
          updatedAt: DateTime.now(),
        );

        const senderUid = 'free_sender_2';
        final now = DateTime.now();
        final todayKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        // Pre-fill 10 messages for today
        await prefs.setString(
          'visualcheckup_comm_rate_v1_$senderUid',
          '{"lastMs": ${now.millisecondsSinceEpoch}, "date": "$todayKey", "count": 10}',
        );

        await tester.pumpWidget(
          _wrap(
            HealthChatScreen(
              myUid: senderUid,
              myDisplayName: 'Zeynep Kaya',
              myEmail: 'zeynep@example.com',
              peer: receiver,
              repository: commRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter message and send
        await tester.enterText(
          find.byKey(const Key('comm_chat_input_field')),
          '11. mesajı deniyorum',
        );
        await tester.tap(find.byKey(const Key('comm_chat_send_button')));
        await tester.pumpAndSettle();

        // Quota sheet appears!
        expect(find.text('Günlük Mesaj Limiti Doldu 💬'), findsOneWidget);
        expect(
          find.textContaining('Ücretsiz üyelikte günde en fazla 10 mesaj'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('comm_chat_upgrade_pro_button')),
          findsOneWidget,
        );
      },
    );
  });
}
