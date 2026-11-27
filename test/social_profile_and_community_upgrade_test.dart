import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/home_screen.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/data/support_group_repository.dart';
import 'package:visualcheckup/features/community/data/wellness_wall_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_community_hub_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/my_health_profile_screen.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_scheduler.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Widget _wrapApp(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

const _testUser = AuthUser(
  id: 'user_social_upgrade_1',
  displayName: 'Deniz Karahan',
  email: 'deniz@example.com',
  provider: AuthProviderType.google,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'visualcheckup_disclaimer_accepted_v1': true,
    });
  });

  group('Drawer Top Hierarchy & Social Formula Bank Profile/Community Upgrade', () {
    testWidgets(
      'AppDrawer places Profilim at the very top, Sağlık Topluluğu right below it, and opens MyHealthProfileScreen',
      (tester) async {
        final themeController = ThemeController();
        addTearDown(themeController.dispose);
        final historyRepo = HistoryRepository(profileId: 'drawer_social_test');
        await historyRepo.setDisclaimerAccepted();

        await tester.pumpWidget(
          _wrapApp(
            HomeScreen(
              analyzer: ColorHealthAnalyzer(),
              historyRepository: historyRepo,
              alarmScheduler: const NoopMedicationAlarmScheduler(),
              currentUser: _testUser,
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

        final profileTile = find.byKey(const Key('drawer_my_profile_tile'));
        final communityTile = find.byKey(const Key('drawer_community_tile'));
        final donateBtn = find.byKey(const Key('drawer_donate_button'));
        final homeIcon = find.byIcon(Icons.grid_view_rounded);

        expect(profileTile, findsOneWidget);
        expect(communityTile, findsOneWidget);
        expect(donateBtn, findsOneWidget);

        // Verify exact vertical hierarchy: Ana Ekran -> Bağış Yap -> Profilim -> Sağlık Topluluğu
        final homeY = tester.getTopLeft(homeIcon).dy;
        final donateY = tester.getTopLeft(donateBtn).dy;
        final profileY = tester.getTopLeft(profileTile).dy;
        final communityY = tester.getTopLeft(communityTile).dy;

        expect(homeY, lessThan(donateY));
        expect(donateY, lessThan(profileY));
        expect(profileY, lessThan(communityY));

        // Tap Profilim -> opens dedicated MyHealthProfileScreen
        await tester.tap(profileTile);
        await tester.pumpAndSettle();

        expect(find.byType(MyHealthProfileScreen), findsOneWidget);
        expect(
          find.byKey(const Key('my_profile_open_community_btn')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'MyHealthProfileScreen displays Social Showcase with interactive stats, mood picker, and Edit toggle',
      (tester) async {
        final repo = HealthCommunityRepository(useFirebase: false);
        await repo.saveMyProfile(
          HealthCommunityProfile(
            uid: _testUser.id,
            displayName: _testUser.displayName,
            nickname: 'deniz_health',
            countryCode: 'TR',
            city: 'İstanbul',
            bio: 'Her gün 8.000 adım ve sağlıklı beslenme hedefi.',
            dailyFocus: 'Sabah yürüyüşü + bol su',
            healthGoals: const [HealthGoalTag.fitnessWalk],
            chronicConditions: const [ChronicCondition.hypertension],
            updatedAt: DateTime(2026, 11, 25),
          ),
        );

        await tester.pumpWidget(
          _wrapApp(
            MyHealthProfileScreen(
              currentUser: _testUser,
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Showcase card + 3 interactive stats appear immediately (no raw form wall!)
        expect(find.text('Deniz Karahan'), findsOneWidget);
        expect(find.byKey(const Key('comm_my_profile_likers_btn')), findsOneWidget);
        expect(find.byKey(const Key('comm_my_profile_friends_btn')), findsOneWidget);
        expect(find.byKey(const Key('comm_my_profile_listeners_btn')), findsOneWidget);
        expect(find.byKey(const Key('comm_profile_name_field')), findsNothing);

        // Tap mood trigger -> opens bottom sheet modal, selects energetic mood
        final moodTrigger = find.byKey(const Key('comm_mood_pill_trigger'));
        expect(moodTrigger, findsOneWidget);
        await tester.tap(moodTrigger);
        await tester.pumpAndSettle();

        final energeticChip = find.byKey(const Key('comm_mood_chip_energetic'));
        expect(energeticChip, findsOneWidget);
        await tester.tap(energeticChip);
        await tester.pumpAndSettle();

        final updated = await repo.loadMyProfile(_testUser.id);
        expect(updated?.mood, HealthMood.energetic);

        // Verify Hakkımda, Motto, Motivasyon Müziği, and Arkadaşlarım cards are present
        expect(find.byKey(const Key('profile_bio_card')), findsOneWidget);
        expect(find.byKey(const Key('profile_motto_card')), findsOneWidget);

        final musicCard = find.byKey(const Key('profile_motivation_music_card'));
        await tester.scrollUntilVisible(
          musicCard,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(musicCard, findsOneWidget);

        final friendsCard = find.byKey(const Key('profile_friends_card'));
        await tester.scrollUntilVisible(
          friendsCard,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(friendsCard, findsOneWidget);

        // Tap Edit Profile (now at the very bottom) -> switches cleanly into edit form
        final editBtn = find.byKey(const Key('comm_edit_profile_toggle_btn'));
        await tester.scrollUntilVisible(
          editBtn,
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(editBtn);
        await tester.pumpAndSettle();
        await tester.tap(editBtn);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('comm_profile_name_field')), findsOneWidget);
      },
    );

    testWidgets(
      'HealthCommunityHubScreen supports quick Friend connect, Wellness Wall post publish, and Support Group join/chat',
      (tester) async {
        final commRepo = HealthCommunityRepository(useFirebase: false);
        final wallRepo = WellnessWallRepository(useFirebase: false);
        final groupRepo = SupportGroupRepository(useFirebase: false);

        await tester.pumpWidget(
          _wrapApp(
            HealthCommunityHubScreen(
              currentUser: _testUser,
              repository: commRepo,
              wellnessWallRepository: wallRepo,
              supportGroupRepository: groupRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Discover quick Friend button
        final friendBtn = find.byKey(const Key('comm_friend_btn_sample_tr_ayse'));
        await tester.ensureVisible(friendBtn);
        await tester.pumpAndSettle();
        await tester.tap(friendBtn);
        await tester.pumpAndSettle();
        expect(await commRepo.areFriends(_testUser.id, 'sample_tr_ayse'), isTrue);

        // 2. Switch to Wall tab & publish a new post
        await tester.tap(find.text('Duvar'));
        await tester.pumpAndSettle();
        expect(find.text('Deneyim & Soru Duvarı'), findsOneWidget);

        await tester.tap(find.byKey(const Key('comm_wall_new_post_btn')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('comm_wall_title_input')),
          'Sabah yürüyüşü deneyimim',
        );
        await tester.enterText(
          find.byKey(const Key('comm_wall_body_input')),
          'Her gün 30 dk yürüyüş enerji seviyemi çok artırdı.',
        );
        await tester.tap(find.byKey(const Key('comm_wall_publish_btn')));
        await tester.pumpAndSettle();
        expect(find.text('Sabah yürüyüşü deneyimim'), findsOneWidget);

        // 3. Switch to Groups tab -> join group & send message in group chat
        await tester.tap(find.text('Gruplar'));
        await tester.pumpAndSettle();

        final joinBtn = find.byKey(const Key('comm_group_join_grp_tr_diabetes'));
        await tester.ensureVisible(joinBtn);
        await tester.tap(joinBtn);
        await tester.pumpAndSettle();

        final chatBtn = find.byKey(const Key('comm_group_chat_grp_tr_diabetes'));
        await tester.tap(chatBtn);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('comm_group_chat_input')),
          'Herkese sağlıklı günler!',
        );
        await tester.tap(find.byKey(const Key('comm_group_chat_send')));
        await tester.pumpAndSettle();
        expect(find.text('Herkese sağlıklı günler!'), findsOneWidget);
      },
    );

    testWidgets(
      'HomeScreen displays Social Formula Bank showcase cards (Daily Tip, Doctors, New Members, Active Members, Latest Posts)',
      (tester) async {
        final themeController = ThemeController();
        addTearDown(themeController.dispose);
        final historyRepo = HistoryRepository(profileId: 'home_sfb_test');
        await historyRepo.setDisclaimerAccepted();

        await tester.pumpWidget(
          _wrapApp(
            HomeScreen(
              analyzer: ColorHealthAnalyzer(),
              historyRepository: historyRepo,
              alarmScheduler: const NoopMedicationAlarmScheduler(),
              currentUser: _testUser,
              themeController: themeController,
              onSignOut: () {},
              onDeleteAccount: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('home_messages_appbar_button')),
          findsOneWidget,
        );

        final homeScrollable = find.byType(Scrollable).first;
        for (final cardKey in const [
          Key('home_sfb_daily_tip_card'),
          Key('home_sfb_doctors_card'),
          Key('home_sfb_new_members_card'),
          Key('home_sfb_active_members_card'),
          Key('home_sfb_latest_posts_section'),
        ]) {
          await tester.scrollUntilVisible(
            find.byKey(cardKey),
            300,
            scrollable: homeScrollable,
          );
          expect(find.byKey(cardKey), findsOneWidget);
        }
      },
    );

    testWidgets(
      'MyHealthProfileScreen shows ADMIN badge and Quick Management Console for admin accounts',
      (tester) async {
        const adminUser = AuthUser(
          id: 'admin_uid_sfb',
          displayName: 'Fatih Yüksek',
          email: 'f.s.yuksek@gmail.com',
          provider: AuthProviderType.google,
        );
        final repo = HealthCommunityRepository(useFirebase: false);
        await repo.saveMyProfile(
          HealthCommunityProfile(
            uid: adminUser.id,
            displayName: adminUser.displayName,
            nickname: 'faysoft',
            countryCode: 'TR',
            city: 'İstanbul',
            updatedAt: DateTime(2026, 11, 26),
          ),
        );

        var adminOpened = false;
        await tester.pumpWidget(
          _wrapApp(
            MyHealthProfileScreen(
              currentUser: adminUser,
              repository: repo,
              onOpenAdminPanel: () => adminOpened = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('ADMİN'), findsOneWidget);
        // Admin profilinde hızlı yönetim paneli kaldırıldı, yönetim drawer altından yapılır
        expect(
          find.byKey(const Key('profile_admin_console_card')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('profile_bio_card')),
          findsOneWidget,
        );
      },
    );
  });
}
