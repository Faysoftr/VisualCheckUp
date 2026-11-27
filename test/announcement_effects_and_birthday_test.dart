import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/theme/visual_announcement_effect_service.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/admin/presentation/widgets/global_announcement_and_promo_banners.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/disclaimer_dialog.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_profile_detail_screen.dart';
import 'package:visualcheckup/features/wellness_extras/daily_health_tip_and_birthday.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('tr'),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VisualAnnouncementEffectService & GlobalAnnouncementBanner', () {
    testWidgets('VisualAnnouncementEffectService inserts and completes overlay effect', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                VisualAnnouncementEffectService.showEffect(
                  ctx,
                  type: 'duyuru',
                  shape: 'kalp',
                  duration: const Duration(milliseconds: 300),
                );
              },
              child: const Text('Show Effect'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Effect'));
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    });

    testWidgets('GlobalAnnouncementBanner displays announcement and triggers celebration', (tester) async {
      final repo = AdminRepository();
      await repo.saveAnnouncement(
        GlobalAnnouncement(
          id: 'ann_test_1',
          title: 'Yeni Sağlık Güncellemesi',
          message: 'Tüm modüller aktif edildi!',
          type: AnnouncementType.healthTip,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        _wrap(
          GlobalAnnouncementBanner(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Yeni Sağlık Güncellemesi'), findsOneWidget);
      expect(find.text('Tüm modüller aktif edildi!'), findsOneWidget);
      expect(find.textContaining('DUYURU'), findsOneWidget);

      final sparkleBtn = find.byIcon(Icons.auto_awesome_rounded);
      expect(sparkleBtn, findsOneWidget);

      await tester.tap(sparkleBtn);
      await tester.pump();
      expect(find.byType(CustomPaint), findsWidgets);
      await tester.pumpAndSettle();
    });

    testWidgets('GlobalAnnouncement supports customColor and renders with custom accent', (tester) async {
      final ann = GlobalAnnouncement(
        id: 'ann_color_1',
        title: 'Özel Renkli Duyuru',
        message: 'Neon Pembe Renk!',
        type: AnnouncementType.info,
        colorHex: '#FF1E56',
        isActive: true,
        createdAt: DateTime.now(),
      );
      expect(ann.customColor, const Color(0xFFFF1E56));

      final repo = AdminRepository();
      await repo.saveAnnouncement(ann);

      await tester.pumpWidget(
        _wrap(
          GlobalAnnouncementBanner(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Özel Renkli Duyuru'), findsOneWidget);
      expect(find.text('Neon Pembe Renk!'), findsOneWidget);
    });
  });

  group('Birthday Celebration System (Personal & Community)', () {
    testWidgets('BirthdayCelebrationCard triggers when today matches saved birthday', (tester) async {
      final now = DateTime.now();
      await DailyWellnessExtras.saveBirthday(month: now.month, day: now.day);

      await tester.pumpWidget(
        _wrap(
          const BirthdayCelebrationCard(
            displayName: 'Zeynep Kaya',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_birthday_celebration_card')), findsOneWidget);
      expect(find.text('Kutla 🎉'), findsOneWidget);

      // Tap Kutla to re-trigger celebration
      await tester.tap(find.text('Kutla 🎉'));
      await tester.pump();
      expect(find.byType(CustomPaint), findsWidgets);
      await tester.pumpAndSettle();
    });

    testWidgets('CommunityBirthdayShowcaseCard shows today birthday members and handles Kutla wish flow', (tester) async {
      final now = DateTime.now();
      final sampleMembers = [
        HealthCommunityProfile(
          uid: 'member_bday_1',
          displayName: 'Ayşe Demir',
          nickname: 'ayse_saglik',
          city: 'İzmir',
          countryCode: 'TR',
          birthMonth: now.month,
          birthDay: now.day,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          CommunityBirthdayShowcaseCard(
            profiles: sampleMembers,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_community_birthdays_section')), findsOneWidget);
      expect(find.text('Bugün Doğum Günü Olan Üyelerimiz'), findsOneWidget);
      expect(find.text('Ayşe Demir'), findsOneWidget);

      final kutlaBtn = find.text('Kutla 🎉');
      expect(kutlaBtn, findsOneWidget);

      // Tap Kutla
      await tester.tap(kutlaBtn);
      await tester.pumpAndSettle();

      // Check wish sheet popped up
      expect(find.text('Ayşe Demir için Doğum Günü Notu'), findsOneWidget);
      expect(find.text('Kutlamayı İlet 💌'), findsOneWidget);

      // Tap send wish
      await tester.tap(find.text('Kutlamayı İlet 💌'));
      await tester.pumpAndSettle();

      // Button is now marked as Kutlandı
      expect(find.text('✓ Kutlandı'), findsOneWidget);
    });

    testWidgets('HealthProfileDetailScreen shows birthday banner if member birthday is today', (tester) async {
      final now = DateTime.now();
      final bdayMember = HealthCommunityProfile(
        uid: 'member_bday_2',
        displayName: 'Lukas Weber',
        city: 'München',
        countryCode: 'DE',
        birthMonth: now.month,
        birthDay: now.day,
        updatedAt: now,
      );

      await tester.pumpWidget(
        _wrap(
          HealthProfileDetailScreen(
            profile: bdayMember,
            myUid: 'my_uid_1',
            myDisplayName: 'Test User',
            repository: HealthCommunityRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_detail_birthday_banner')), findsOneWidget);
      expect(find.text('Bugün Lukas Weber\'in Doğum Günü! 🎉'), findsOneWidget);
    });
  });

  group('Admin Visibility & Mandatory Onboarding Legal Disclaimer', () {
    test('AdminUtils strictly checks admin email f.s.yuksek@gmail.com', () {
      expect(AdminUtils.adminEmail, 'f.s.yuksek@gmail.com');
      expect(AdminUtils.isAdmin(email: 'f.s.yuksek@gmail.com'), isTrue);
      expect(AdminUtils.isAdmin(email: 'F.S.YUKSEK@GMAIL.COM'), isTrue);
      expect(AdminUtils.isAdmin(email: 'other@example.com'), isFalse);
      expect(AdminUtils.isAdmin(email: null), isFalse);
    });

    testWidgets('DisclaimerDialog displays 4 pillars and enforces mandatory consent', (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                dialogResult = await DisclaimerDialog.show(ctx, initiallyAgreed: false);
              },
              child: const Text('Open Disclaimer'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Open Disclaimer'));
      await tester.pumpAndSettle();

      // Verify header and 4 core legal pillars
      expect(find.text('Tıbbi Bilgilendirme & Kullanım'), findsOneWidget);
      expect(find.text('Gizlilik, Güvenlik ve Yasal Sorumluluk'), findsOneWidget);
      expect(find.text('1. Tıbbi Sorumluluk Reddi'), findsOneWidget);
      expect(find.text('2. Gizlilik & KVKK / GDPR (Cihaz İçi Saklama)'), findsOneWidget);
      expect(find.text('3. Güvenlik & Veri Kontrolü'), findsOneWidget);
      expect(find.text('4. Kullanım Şartları ve Üye Sorumluluğu'), findsOneWidget);

      // Verify Accept button is disabled initially
      final acceptBtn = tester.widget<FilledButton>(find.byKey(const Key('disclaimer_accept_button')));
      expect(acceptBtn.onPressed, isNull);

      // Toggle consent checkbox
      await tester.tap(find.byKey(const Key('disclaimer_consent_checkbox')));
      await tester.pumpAndSettle();

      // Accept button is now enabled
      final acceptBtnEnabled = tester.widget<FilledButton>(find.byKey(const Key('disclaimer_accept_button')));
      expect(acceptBtnEnabled.onPressed, isNotNull);

      // Tap Accept
      await tester.tap(find.byKey(const Key('disclaimer_accept_button')));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });

    testWidgets('DisclaimerDialog reject button returns false', (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                dialogResult = await DisclaimerDialog.show(ctx, initiallyAgreed: false);
              },
              child: const Text('Open Disclaimer'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Disclaimer'));
      await tester.pumpAndSettle();

      // Tap Reject / Cancel button
      await tester.tap(find.byKey(const Key('disclaimer_reject_button')));
      await tester.pumpAndSettle();

      expect(dialogResult, isFalse);
    });
  });
}

