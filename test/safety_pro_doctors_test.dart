import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/safety/content_safety_service.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:visualcheckup/features/admin/presentation/widgets/global_announcement_and_promo_banners.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/doctors/data/doctor_repository.dart';
import 'package:visualcheckup/features/doctors/domain/doctor_models.dart';
import 'package:visualcheckup/features/doctors/presentation/screens/doctor_application_screen.dart';
import 'package:visualcheckup/features/doctors/presentation/screens/doctor_search_screen.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/screens/lab_reports_screen.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';
import 'package:visualcheckup/features/subscription/domain/subscription_models.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Widget _wrapApp(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

Uint8List _validJpegBytes() {
  final image = img.Image(width: 64, height: 64);
  img.fill(image, color: img.ColorRgb8(11, 110, 110));
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}

const _patientUser = AuthUser(
  id: 'patient_1',
  displayName: 'Ayşe Yılmaz',
  email: 'ayse@example.com',
  provider: AuthProviderType.google,
);

const _doctorApplicant = AuthUser(
  id: 'doc_applicant_1',
  displayName: 'Kerem Özkan',
  email: 'kerem.md@example.com',
  provider: AuthProviderType.google,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ContentSafetyService (Profanity, Insults, Spam & Image Validation)', () {
    test('blocks multi-language profanity, obfuscated insults, hate speech & spam while allowing clean health text', () {
      expect(
        ContentSafetyService.checkText(
          'Sabah yürüyüşü ve şekersiz yeşil çay çok iyi geldi!',
        ).isSafe,
        isTrue,
      );
      expect(
        ContentSafetyService.checkText('s.1.k.t.i.r git buradan').isSafe,
        isFalse,
      );
      expect(
        ContentSafetyService.checkText('Du bist ein Arschloch').isSafe,
        isFalse,
      );
      expect(
        ContentSafetyService.checkText('jävla idiot').isSafe,
        isFalse,
      );
      expect(
        ContentSafetyService.checkText('eres un gilipollas').isSafe,
        isFalse,
      );
      expect(
        ContentSafetyService.checkText('deneme bonusu kazan').isSafe,
        isFalse,
      );
      expect(
        ContentSafetyService.checkText(
          'Ara beni 0532 123 45 67',
          checkPhones: true,
        ).violation,
        ContentSafetyViolation.phoneNumberLeak,
      );
    });

    test('validates real image magic bytes & dimensions and rejects spoofed files', () {
      expect(ContentSafetyService.validateImageBytes(_validJpegBytes()).isSafe, isTrue);
      expect(
        ContentSafetyService.validateImageBytes(
          Uint8List.fromList('not an image file at all'.codeUnits),
        ).isSafe,
        isFalse,
      );
    });

    test('HealthCommunityRepository.sendMessage rejects profane text with unsafeContent', () async {
      final repo = HealthCommunityRepository(useFirebase: false);
      final peer = (await repo.getProfile('sample_tr_ayse'))!;
      final status = await repo.sendMessage(
        senderUid: _patientUser.id,
        senderDisplayName: _patientUser.displayName,
        receiver: peer,
        text: 'salak mısın sen',
      );
      expect(status, SendMessageStatus.unsafeContent);
    });
  });

  group('VisualCheckUp Pro Subscription & Lab Report Free Limit', () {
    test('enforces 3/month free lab report limit and unlocks unlimited when Pro is activated', () async {
      final now = DateTime(2026, 11, 25);
      final subRepo = SubscriptionRepository(useFirebase: false, clock: () => now);
      final freeSub = await subRepo.loadSubscription(uid: _patientUser.id);
      expect(freeSub.isPro, isFalse);

      // Localized global pricing verification (distinct monthly & yearly tiers)
      expect(SubscriptionTier.proMonthly.localizedPrice('en'), '\$4.99');
      expect(SubscriptionTier.proYearly.localizedPrice('en'), '\$34.99');
      expect(SubscriptionTier.proMonthly.localizedPrice('tr'), '₺149,99');
      expect(SubscriptionTier.proYearly.localizedPrice('tr'), '₺999,99');
      expect(SubscriptionTier.proMonthly.localizedPrice('de'), '€4,99');
      expect(SubscriptionTier.proYearly.localizedPrice('sv'), '389 kr');

      LabReportRecord makeReport(int i) => LabReportRecord(
            id: 'r_$i',
            title: 'Kan Tahlili $i',
            reportDate: now,
            source: LabReportSource.manual,
            items: const [],
            overallSummary: 'Normal',
            suggestedSpecialty: 'Dahiliye',
          );

      final twoReports = [makeReport(1), makeReport(2)];
      expect(
        subRepo.canAddLabReport(
          existingReports: twoReports,
          subscription: freeSub,
        ),
        isTrue,
      );
      expect(
        subRepo.remainingFreeLabReports(
          existingReports: twoReports,
          subscription: freeSub,
        ),
        1,
      );

      final threeReports = [makeReport(1), makeReport(2), makeReport(3)];
      expect(
        subRepo.canAddLabReport(
          existingReports: threeReports,
          subscription: freeSub,
        ),
        isFalse,
      );

      final proSub = await subRepo.activatePlan(
        uid: _patientUser.id,
        tier: SubscriptionTier.proYearly,
      );
      expect(proSub.isPro, isTrue);
      expect(
        subRepo.canAddLabReport(
          existingReports: threeReports,
          subscription: proSub,
        ),
        isTrue,
      );
      expect(
        subRepo.remainingFreeLabReports(
          existingReports: threeReports,
          subscription: proSub,
        ),
        -1,
      );
    });

    testWidgets('LabReportsScreen opens ProPaywallScreen when 3/month free limit is reached and activates Pro', (tester) async {
      final labRepo = LabsVitalsRepository();
      final subRepo = SubscriptionRepository(useFirebase: false);
      final now = DateTime.now();

      for (int i = 1; i <= 3; i++) {
        await labRepo.saveLabReport(
          LabReportRecord(
            id: 'lab_$i',
            title: 'Tahlil $i',
            reportDate: now,
            source: LabReportSource.manual,
            items: const [],
            overallSummary: 'Özet',
            suggestedSpecialty: 'Dahiliye',
          ),
        );
      }

      await tester.pumpWidget(
        _wrapApp(
          LabReportsScreen(
            repository: labRepo,
            subscriptionRepository: subRepo,
            userId: _patientUser.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Quota banner shows 0 / 3
      expect(find.textContaining('0 / 3'), findsOneWidget);

      // Tapping FAB when limit reached opens ProPaywallScreen
      await tester.tap(find.byKey(const Key('lab_add_report_fab')));
      await tester.pumpAndSettle();

      final subBtn = find.byKey(const Key('pro_subscribe_button'));
      await tester.scrollUntilVisible(
        subBtn,
        260,
        scrollable: find.byType(Scrollable).last,
      );
      expect(subBtn, findsOneWidget);

      // Activate Pro -> returns to LabReportsScreen with Unlimited Pro banner
      await tester.ensureVisible(subBtn);
      await tester.pumpAndSettle();
      await tester.tap(subBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('Sınırsız'), findsOneWidget);

      // Verify HealthPromotionBanner hides ads for Pro users
      final adminRepo = AdminRepository(useFirebase: false);
      await adminRepo.savePromotion(
        HealthPromotion(
          id: 'p_ad_1',
          title: 'Gizlenmesi Gereken Reklam',
          placement: PromotionPlacement.homeTop,
          isActive: true,
          createdAt: now,
        ),
      );
      // Activate default local subscription as well so banner checks it
      await subRepo.activatePlan(tier: SubscriptionTier.proMonthly);
      await tester.pumpWidget(
        _wrapApp(
          Scaffold(
            body: HealthPromotionBanner(
              placement: PromotionPlacement.homeTop,
              repository: adminRepo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Gizlenmesi Gereken Reklam'), findsNothing);
    });
  });

  group('Verified Doctors Directory, Country Search, Application & Admin Approval', () {
    testWidgets('DoctorSearchScreen filters by country (DE/SE/TR) and sends patient follow-up request', (tester) async {
      final docRepo = DoctorRepository(useFirebase: false);

      await tester.pumpWidget(
        _wrapApp(
          DoctorSearchScreen(
            currentUser: _patientUser,
            repository: docRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Filter by Sweden (SE) -> finds Dr. Erik Lindqvist
      await tester.tap(find.byKey(const Key('doctor_country_chip_SE')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('doctor_card_doc_se_erik')), findsOneWidget);
      expect(find.byKey(const Key('doctor_card_doc_tr_selim')), findsNothing);

      // Request patient follow-up
      await tester.tap(find.byKey(const Key('doctor_followup_btn_doc_se_erik')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('doctor_followup_note_field')),
        'Tip 2 diyabet takibi için görüşmek istiyorum.',
      );
      await tester.tap(find.byKey(const Key('doctor_followup_submit_btn')));
      await tester.pumpAndSettle();

      final requests = await docRepo.loadFollowUpRequests(
        doctorUid: 'doc_se_erik',
      );
      expect(requests.length, 1);
      expect(requests.first.patientUid, _patientUser.id);
    });

    testWidgets('DoctorApplicationScreen submits application and AdminPanelScreen approves it into country search', (tester) async {
      final docRepo = DoctorRepository(useFirebase: false);
      final adminRepo = AdminRepository(useFirebase: false);

      // 1. Doctor submits application
      await tester.pumpWidget(
        _wrapApp(
          DoctorApplicationScreen(
            currentUser: _doctorApplicant,
            repository: docRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final listScrollable = find
          .descendant(
            of: find.byKey(const Key('doctor_app_form_list')),
            matching: find.byType(Scrollable),
          )
          .first;

      await tester.enterText(
        find.byKey(const Key('doctor_app_clinic_field')),
        'Ege Kardiyoloji Kliniği',
      );
      await tester.enterText(
        find.byKey(const Key('doctor_app_license_field')),
        'TR-MD-998877',
      );
      final submitBtn = find.byKey(const Key('doctor_app_submit_button'));
      await tester.scrollUntilVisible(
        submitBtn,
        300,
        scrollable: listScrollable,
      );
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      final pending = await docRepo.loadApplicationsForAdmin();
      expect(pending.length, 1);
      expect(pending.first.status, DoctorApplicationStatus.pending);

      // 2. Admin approves doctor in AdminPanelScreen -> Doctors tab
      await tester.pumpWidget(
        _wrapApp(
          AdminPanelScreen(
            repository: adminRepo,
            doctorRepository: docRepo,
            initialTabIndex: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final approveBtn =
          find.byKey(Key('admin_approve_doc_${_doctorApplicant.id}'));
      await tester.ensureVisible(approveBtn);
      await tester.pumpAndSettle();
      await tester.tap(approveBtn);
      await tester.pumpAndSettle();

      // 3. Approved doctor immediately appears in Country Doctor Search (TR)
      final trDoctors = await docRepo.searchDoctors(countryCode: 'TR');
      expect(
        trDoctors.any((d) => d.uid == _doctorApplicant.id && d.isVerified),
        isTrue,
      );
    });
  });
}
