import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:visualcheckup/features/admin/presentation/widgets/global_announcement_and_promo_banners.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/app_drawer.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_community_hub_screen.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Widget _wrapApp(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

const _regularUser = AuthUser(
  id: 'user_tr_regular',
  displayName: 'Mehmet Kaya',
  email: 'mehmet@example.com',
  provider: AuthProviderType.google,
);

const _adminUser = AuthUser(
  id: 'user_admin_1',
  displayName: 'Faysoftr Admin',
  email: 'f.s.yuksek@gmail.com',
  provider: AuthProviderType.google,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AdminUtils & Chronic Conditions Domain', () {
    test('AdminUtils recognizes configured admin email and flags only', () {
      expect(AdminUtils.isAdmin(email: 'f.s.yuksek@gmail.com'), isTrue);
      expect(AdminUtils.isAdmin(email: '  F.S.YUKSEK@GMAIL.COM  '), isTrue);
      expect(AdminUtils.isAdmin(email: 'user@example.com'), isFalse);
      expect(AdminUtils.isAdmin(email: null, uid: 'u1'), isFalse);
      expect(
        AdminUtils.isAdmin(
          email: 'user@example.com',
          userData: const {'isAdmin': true},
        ),
        isTrue,
      );
      expect(
        AdminUtils.isAdmin(
          email: 'user@example.com',
          userData: const {'role': 'admin'},
        ),
        isTrue,
      );
    });

    test('HealthCommunityProfile chronic conditions, online status & matching', () {
      final now = DateTime(2026, 11, 25, 14, 0);
      final me = HealthCommunityProfile(
        uid: 'me',
        displayName: 'Selin',
        chronicConditions: const [
          ChronicCondition.hypertension,
          ChronicCondition.migraine,
        ],
        customChronicCondition: 'Fibromiyalji',
        showChronicConditions: true,
        isOnline: true,
        showOnlineStatus: true,
        lastActiveAt: now,
        updatedAt: now,
      );

      final peerSameEnum = HealthCommunityProfile(
        uid: 'p1',
        displayName: 'Lukas',
        chronicConditions: const [ChronicCondition.hypertension],
        isOnline: true,
        showOnlineStatus: true,
        lastActiveAt: now.subtract(const Duration(minutes: 2)),
        updatedAt: now,
      );

      final peerHiddenCondition = peerSameEnum.copyWith(
        uid: 'p2',
        showChronicConditions: false,
      );

      final peerSameCustom = HealthCommunityProfile(
        uid: 'p3',
        displayName: 'Aylin',
        customChronicCondition: 'fibromiyalji',
        isOnline: false,
        lastActiveAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now,
      );

      final peerHiddenOnline = peerSameEnum.copyWith(
        uid: 'p4',
        showOnlineStatus: false,
      );

      expect(me.sharesConditionWith(peerSameEnum), isTrue);
      expect(me.sharesConditionWith(peerHiddenCondition), isFalse);
      expect(me.sharesConditionWith(peerSameCustom), isTrue);
      expect(peerSameEnum.isVisibleOnlineAt(now), isTrue);
      expect(peerSameCustom.isVisibleOnlineAt(now), isFalse);
      expect(peerHiddenOnline.isVisibleOnlineAt(now), isFalse);

      // JSON round-trip preserves chronic & moderation fields
      final roundTrip = HealthCommunityProfile.fromJson(me.toJson());
      expect(roundTrip.chronicConditions, me.chronicConditions);
      expect(roundTrip.customChronicCondition, 'Fibromiyalji');
      expect(roundTrip.isOnline, isTrue);
      expect(roundTrip.showChronicConditions, isTrue);
    });

    test('discoverProfiles supports onlineOnly, conditionFilter, sameConditionAsMe, and excludes suspended users', () async {
      final now = DateTime.now();
      final repo = HealthCommunityRepository(
        useFirebase: false,
        clock: () => now,
      );

      // Save my profile with Type 2 Diabetes
      await repo.saveMyProfile(
        HealthCommunityProfile(
          uid: 'me_user',
          displayName: 'Ahmet',
          chronicConditions: const [ChronicCondition.type2Diabetes],
          isOnline: true,
          lastActiveAt: now,
          updatedAt: now,
        ),
      );

      final onlinePeers = await repo.discoverProfiles(
        myUid: 'me_user',
        onlineOnly: true,
      );
      expect(onlinePeers, isNotEmpty);
      expect(onlinePeers.every((p) => p.isVisibleOnlineAt(now)), isTrue);

      final sameConditionPeers = await repo.discoverProfiles(
        myUid: 'me_user',
        sameConditionAsMe: true,
      );
      expect(sameConditionPeers, isNotEmpty);
      expect(
        sameConditionPeers.every(
          (p) => p.chronicConditions.contains(ChronicCondition.type2Diabetes),
        ),
        isTrue,
      );

      final thyroidPeers = await repo.discoverProfiles(
        myUid: 'me_user',
        conditionFilter: ChronicCondition.thyroidHashimoto,
      );
      expect(thyroidPeers, isNotEmpty);
      expect(
        thyroidPeers.every(
          (p) =>
              p.chronicConditions.contains(ChronicCondition.thyroidHashimoto),
        ),
        isTrue,
      );

      // Admin suspends one of the thyroid peers -> disappears from Discover
      final suspendedUid = thyroidPeers.first.uid;
      await repo.setProfileSuspended(suspendedUid, true);
      final afterSuspend = await repo.discoverProfiles(
        myUid: 'me_user',
        conditionFilter: ChronicCondition.thyroidHashimoto,
      );
      expect(afterSuspend.any((p) => p.uid == suspendedUid), isFalse);
    });
  });

  group('AdminRepository & Banners', () {
    test('CRUD for announcements, promotions, reports, and live stats computation', () async {
      final commRepo = HealthCommunityRepository(useFirebase: false);
      final adminRepo = AdminRepository(
        useFirebase: false,
        communityRepository: commRepo,
      );

      final ann = await adminRepo.saveAnnouncement(
        GlobalAnnouncement(
          id: 'ann_1',
          title: 'Yeni Kronik Hastalık Eşleşmesi',
          message: 'Artık aynı hastalığa sahip kişileri bulabilirsiniz.',
          type: AnnouncementType.healthTip,
          isActive: true,
          createdAt: DateTime(2026, 11, 25),
        ),
      );
      expect((await adminRepo.loadAnnouncements(activeOnly: true)).length, 1);

      await adminRepo.saveAnnouncement(ann.copyWith(isActive: false));
      expect(await adminRepo.loadAnnouncements(activeOnly: true), isEmpty);

      await adminRepo.savePromotion(
        HealthPromotion(
          id: 'promo_1',
          title: 'Ücretsiz Tansiyon Günlüğü',
          subtitle: 'Sabah-akşam tansiyonunuzu düzenli kaydedin.',
          placement: PromotionPlacement.homeTop,
          isActive: true,
          createdAt: DateTime(2026, 11, 25),
        ),
      );
      final homePromos = await adminRepo.loadPromotions(
        activeOnly: true,
        placement: PromotionPlacement.homeTop,
      );
      expect(homePromos.length, 1);
      expect(
        await adminRepo.loadPromotions(
          activeOnly: true,
          placement: PromotionPlacement.communityTop,
        ),
        isEmpty,
      );

      // Submit a community report -> shows up in AdminRepository.loadReports
      await commRepo.submitReport(
        reporterUid: 'user_1',
        targetType: 'profile',
        targetId: 'sample_tr_ayse',
        reason: CommunityReportReason.spam,
        note: 'Test report',
      );
      final reports = await adminRepo.loadReports();
      expect(reports.length, 1);
      expect(reports.first.status, 'pending');

      await adminRepo.updateReportStatus(
        reportId: reports.first.id,
        status: 'resolved',
      );
      final resolvedReports = await adminRepo.loadReports();
      expect(resolvedReports.first.status, 'resolved');

      final stats = await adminRepo.computeStats();
      expect(stats.totalMembers, greaterThan(0));
      expect(stats.onlineMembers, greaterThan(0));
      expect(stats.conditionCounts, isNotEmpty);
      expect(stats.activePromotions, 1);
      expect(stats.pendingReports, 0);
    });
  });

  group('Admin Panel, Banners & Community Filters Widget Tests', () {
    testWidgets('AdminPanelScreen creates announcement & promo, verifies/suspends user, and banners display them', (tester) async {
      final commRepo = HealthCommunityRepository(useFirebase: false);
      final adminRepo = AdminRepository(
        useFirebase: false,
        communityRepository: commRepo,
      );
      await commRepo.submitReport(
        reporterUid: 'u_reporter',
        targetType: 'profile',
        targetId: 'sample_tr_ayse',
        reason: CommunityReportReason.inappropriate,
        note: 'Uygunsuz içerik testi',
      );

      await tester.pumpWidget(
        _wrapApp(
          AdminPanelScreen(
            repository: adminRepo,
            uploadService: MockCommunityImageUploadService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Statistics tab shows chronic condition distribution
      expect(find.text('Admin Kontrol Paneli'), findsOneWidget);
      final statsScrollable = find
          .descendant(
            of: find.byKey(const Key('admin_stats_list')),
            matching: find.byType(Scrollable),
          )
          .first;
      final conditionHeader = find.text('Kronik Hastalık Dağılımı');
      await tester.scrollUntilVisible(
        conditionHeader,
        240,
        scrollable: statsScrollable,
      );
      expect(conditionHeader, findsOneWidget);

      // 2. Announcements tab -> create new announcement
      await tester.ensureVisible(find.text('Duyurular'));
      await tester.tap(find.text('Duyurular'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('admin_add_announcement_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('admin_announcement_title_field')),
        'Kış Sağlığı Duyurusu',
      );
      await tester.enterText(
        find.byKey(const Key('admin_announcement_message_field')),
        'D vitamini ve su tüketiminizi ihmal etmeyin.',
      );
      await tester.tap(find.byKey(const Key('admin_announcement_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Kış Sağlığı Duyurusu'), findsOneWidget);

      // 3. Promotions tab -> create new banner ad
      await tester.ensureVisible(find.text('Reklamlar'));
      await tester.tap(find.text('Reklamlar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('admin_add_promo_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('admin_promo_title_field')),
        'Sağlık Kampanyası',
      );
      await tester.enterText(
        find.byKey(const Key('admin_promo_subtitle_field')),
        'Düzenli ilaç hatırlatmalarını açın.',
      );
      await tester.tap(find.byKey(const Key('admin_promo_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Sağlık Kampanyası'), findsOneWidget);

      // 4. Users tab -> verify & suspend a member
      final usersTab = find.textContaining('Kullanıcılar');
      await tester.ensureVisible(usersTab);
      await tester.tap(usersTab);
      await tester.pumpAndSettle();
      final verifyBtn = find.byKey(const Key('admin_verify_sample_tr_ayse'));
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pumpAndSettle();
      final verifiedProfile = await commRepo.getProfile('sample_tr_ayse');
      expect(verifiedProfile!.isVerified, isTrue);

      final suspendBtn = find.byKey(const Key('admin_suspend_sample_tr_ayse'));
      await tester.ensureVisible(suspendBtn);
      await tester.tap(suspendBtn);
      await tester.pumpAndSettle();
      final suspendedProfile = await commRepo.getProfile('sample_tr_ayse');
      expect(suspendedProfile!.isSuspended, isTrue);

      // 5. Reports tab -> resolve pending report
      final reportsTab = find.textContaining('Şikayetler');
      await tester.ensureVisible(reportsTab);
      await tester.tap(reportsTab);
      await tester.pumpAndSettle();
      final reports = await adminRepo.loadReports();
      final resolveBtn = find.byKey(Key('admin_resolve_${reports.first.id}'));
      await tester.ensureVisible(resolveBtn);
      await tester.tap(resolveBtn);
      await tester.pumpAndSettle();
      final updatedReports = await adminRepo.loadReports();
      expect(updatedReports.first.status, 'resolved');

      // 6. Verify GlobalAnnouncementBanner & HealthPromotionBanner render the saved items
      await tester.pumpWidget(
        _wrapApp(
          Scaffold(
            body: Column(
              children: [
                GlobalAnnouncementBanner(repository: adminRepo),
                HealthPromotionBanner(
                  placement: PromotionPlacement.homeTop,
                  repository: adminRepo,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kış Sağlığı Duyurusu'), findsOneWidget);
      expect(find.text('Sağlık Kampanyası'), findsOneWidget);
    });

    testWidgets('HealthCommunityHubScreen saves chronic conditions and filters by Online Now & Same Condition', (tester) async {
      final commRepo = HealthCommunityRepository(useFirebase: false);
      final adminRepo = AdminRepository(
        useFirebase: false,
        communityRepository: commRepo,
      );

      await tester.pumpWidget(
        _wrapApp(
          HealthCommunityHubScreen(
            currentUser: _regularUser,
            repository: commRepo,
            adminRepository: adminRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to My Profile, opt-in, select Hypertension chronic condition & save
      await tester.tap(find.text('Profilim'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('comm_opt_in_button')));
      await tester.pumpAndSettle();

      final listFinder = find.byKey(const Key('comm_my_profile_list'));
      final listScrollable = find
          .descendant(
            of: listFinder,
            matching: find.byType(Scrollable),
          )
          .first;
      final hypChip =
          find.byKey(const Key('comm_profile_condition_hypertension'));
      await tester.scrollUntilVisible(
        hypChip,
        240,
        scrollable: listScrollable,
      );
      await tester.tap(hypChip);
      await tester.pumpAndSettle();

      final saveBtn = find.byKey(const Key('comm_save_profile_button'));
      await tester.scrollUntilVisible(
        saveBtn,
        300,
        scrollable: listScrollable,
      );
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final saved = await commRepo.loadMyProfile(_regularUser.id);
      expect(
        saved!.chronicConditions.contains(ChronicCondition.hypertension),
        isTrue,
      );

      // Back to Discover -> filter by Same Condition & Online Now
      await tester.tap(find.text('Keşfet'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('comm_filter_same_condition')));
      await tester.pumpAndSettle();
      // Sample profile sample_de_lukas has hypertension
      expect(
        find.byKey(const Key('comm_profile_card_sample_de_lukas')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('comm_filter_online_only')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('comm_profile_card_sample_de_lukas')),
        findsOneWidget,
      );
    });

    testWidgets('AppDrawer shows Admin Control Panel tile only when onOpenAdminPanel is provided', (tester) async {
      final themeController = ThemeController();

      await tester.pumpWidget(
        _wrapApp(
          Scaffold(
            body: AppDrawer(
              currentUser: _adminUser,
              themeController: themeController,
              onOpenSkinModule: () {},
              onOpenHistory: () {},
              onOpenReferenceGuide: () {},
              onOpenAiSettings: () {},
              onOpenDisclaimer: () {},
              onSignOut: () {},
              onDeleteAccount: () {},
              onOpenAdminPanel: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final adminTile = find.byKey(const Key('drawer_admin_panel_tile'));
      await tester.scrollUntilVisible(
        adminTile,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(adminTile, findsOneWidget);

      await tester.pumpWidget(
        _wrapApp(
          Scaffold(
            body: AppDrawer(
              currentUser: _regularUser,
              themeController: themeController,
              onOpenSkinModule: () {},
              onOpenHistory: () {},
              onOpenReferenceGuide: () {},
              onOpenAiSettings: () {},
              onOpenDisclaimer: () {},
              onSignOut: () {},
              onDeleteAccount: () {},
              onOpenAdminPanel: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('drawer_admin_panel_tile')), findsNothing);
    });
  });
}
