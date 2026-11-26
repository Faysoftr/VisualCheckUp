import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/ads/ad_ids.dart';
import 'package:visualcheckup/core/ads/app_open_ad_manager.dart';
import 'package:visualcheckup/core/notifications/health_notification_service.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/data/health_report_pdf_service.dart';
import 'package:visualcheckup/features/checkup/domain/follow_up_plan.dart';
import 'package:visualcheckup/features/doctors/data/doctor_document_verification_service.dart';
import 'package:visualcheckup/features/doctors/data/doctor_repository.dart';
import 'package:visualcheckup/features/doctors/presentation/screens/doctor_application_screen.dart';
import 'package:visualcheckup/features/safety/presentation/screens/banned_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AdMob & AppOpenAdManager (Formül Bank Entegrasyonu)', () {
    test('AdMob Unit IDs exactly match Social Formul Bank official values', () {
      expect(AdIds.appId, contains('ca-app-pub-7020995238802429'));
      expect(AdIds.bannerId, equals('ca-app-pub-7020995238802429/8084433449'));
      expect(AdIds.nativeId, equals('ca-app-pub-7020995238802429/8235524990'));
      expect(AdIds.interstitialId, equals('ca-app-pub-7020995238802429/1619947507'));
      expect(AdIds.appOpenId, equals('ca-app-pub-7020995238802429/5110785742'));
    });

    test('AppOpenAdManager respects admin switch, interval cooldown, and PRO/Admin suppression', () async {
      final manager = AppOpenAdManager();
      await manager.setEnabled(false);
      expect(manager.isEnabled, isFalse);

      // 1. When disabled, normal trigger returns false
      expect(manager.showAdIfAvailable(), isFalse);

      // 2. Enable ad
      await manager.setEnabled(true);
      await manager.setIntervalMinutes(15);
      expect(manager.isEnabled, isTrue);
      expect(manager.intervalMinutes, equals(15));

      // 3. Pro and Admin users NEVER see ads
      expect(manager.showAdIfAvailable(isPro: true), isFalse);
      expect(manager.showAdIfAvailable(isAdmin: true), isFalse);
      expect(manager.showAdIfAvailable(isPro: true, isAdmin: true), isFalse);

      // 4. Free user triggers ad successfully
      bool overrideCalled = false;
      manager.onShowAdOverride = () => overrideCalled = true;

      final shown = manager.showAdIfAvailable(isPro: false, isAdmin: false);
      expect(shown, isTrue);
      expect(overrideCalled, isTrue);

      // 5. Immediate second call is blocked by 15-minute cooldown
      final blockedByCooldown = manager.showAdIfAvailable(isPro: false, isAdmin: false);
      expect(blockedByCooldown, isFalse);

      // 6. Ignore cooldown forces preview (Admin test button)
      final forcedTest = manager.showAdIfAvailable(ignoreCooldown: true);
      expect(forcedTest, isTrue);
    });
  });

  group('Yapay Zeka Sahte Doktor Belgesi Tespiti & Doktor Başvurusu', () {
    test('DoctorDocumentVerificationService flags AI synthetic signatures and small corrupted files', () async {
      final service = DoctorDocumentVerificationService.instance;

      // Small file (<15 KB)
      final smallBytes = Uint8List(500);
      final resSmall = await service.verifyDocumentBytes(smallBytes);
      expect(resSmall.isSuspiciousAi, isFalse); // Low score alone doesn't flag

      // Image containing synthetic AI tool header metadata
      final aiSyntheticBytes = Uint8List.fromList(
        'RIFF....WEBPVP8 ... Midjourney Generative Diffusion ComfyUI Model Diploma'
            .codeUnits,
      );
      final resAi = await service.verifyDocumentBytes(
        aiSyntheticBytes,
        fileName: 'midjourney_diploma.jpg',
      );
      expect(resAi.isSuspiciousAi, isTrue);
      expect(resAi.status, equals('suspicious_ai'));
      expect(resAi.confidence, greaterThanOrEqualTo(0.80));
      expect(resAi.notes, contains('DİKKAT: Yapay Zeka / Sahte Belge Şüphesi'));

      // Clean normal document bytes (> 20 KB without AI metadata)
      final cleanBytes = Uint8List(25 * 1024);
      for (int i = 0; i < cleanBytes.length; i++) {
        cleanBytes[i] = (i * 37) % 256;
      }
      final resClean = await service.verifyDocumentBytes(
        cleanBytes,
        fileName: 'tip_fakultesi_diploma.pdf',
      );
      expect(resClean.isSuspiciousAi, isFalse);
      expect(resClean.status, equals('original'));
      expect(resClean.confidence, greaterThanOrEqualTo(0.85));
      expect(resClean.notes, contains('AI Belge Doğrulama: Belge orijinal görünüyor'));
    });

    testWidgets('DoctorApplicationScreen submits application with Play purchase & AI validation',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final doctorRepo = DoctorRepository(useFirebase: false);
      const user = AuthUser(
        id: 'dr_tester_1',
        email: 'doctor@test.com',
        displayName: 'Dr. Selin Aydın',
        provider: AuthProviderType.google,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DoctorApplicationScreen(
            currentUser: user,
            repository: doctorRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure visible and enter license and clinic
      await tester.ensureVisible(find.byKey(const Key('doctor_app_license_field')));
      await tester.enterText(
        find.byKey(const Key('doctor_app_license_field')),
        'DR-998811',
      );
      await tester.enterText(
        find.byKey(const Key('doctor_app_clinic_field')),
        'Ankara Şehir Hastanesi',
      );
      await tester.pumpAndSettle();

      // Scroll to Play purchase button
      await tester.scrollUntilVisible(
        find.byKey(const Key('doctor_play_purchase_button')),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Click Google Play In-App Purchase button
      final playBtn = find.byKey(const Key('doctor_play_purchase_button'));
      expect(playBtn, findsOneWidget);
      await tester.tap(playBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('Google Play ile Satın Alındı'), findsOneWidget);

      // Scroll to submit button and click
      await tester.scrollUntilVisible(
        find.byKey(const Key('doctor_app_submit_button')),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('doctor_app_submit_button')));
      await tester.pumpAndSettle();

      final myApp = await doctorRepo.loadMyApplication('dr_tester_1');
      expect(myApp, isNotNull);
      expect(myApp!.licenseNumber, equals('DR-998811'));
      expect(myApp.isPaid, isTrue);
    });
  });

  group('Ban İtirazı Sistemi (BannedScreen & Admin Review)', () {
    testWidgets('BannedScreen displays reason and submits appeal', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool appealSubmitted = false;
      String? submittedText;

      await tester.pumpWidget(
        MaterialApp(
          home: BannedScreen(
            reason: 'Profil fotoğrafında uygunsuz içerik tespit edildi.',
            onSubmitAppeal: (text) async {
              appealSubmitted = true;
              submittedText = text;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hesabınız Askıya Alındı'), findsOneWidget);
      expect(
        find.text('Profil fotoğrafında uygunsuz içerik tespit edildi.'),
        findsOneWidget,
      );

      // Enter appeal explanation
      await tester.enterText(
        find.byKey(const Key('banned_appeal_text_field')),
        'Yanlış bir algılama oldu, görsel sadece tıbbi laboratuvar tahlil belgesiydi.',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('banned_appeal_submit_button')));
      await tester.tap(find.byKey(const Key('banned_appeal_submit_button')));
      await tester.pumpAndSettle();

      expect(appealSubmitted, isTrue);
      expect(submittedText, contains('tıbbi laboratuvar'));
      expect(find.text('İtirazınız İnceleniyor'), findsOneWidget);
    });
  });

  group('Sağlık Bildirim Servisi & PDF Sağlık Karnesi', () {
    test('HealthNotificationService suppresses notification if user is active in same chat', () async {
      final notif = HealthNotificationService.instance;
      notif.currentlyActiveChatId = 'user1_user2';

      String? triggeredMessage;
      notif.onInAppNotification = (s, m, id) => triggeredMessage = m;

      // Same chat -> suppressed
      await notif.showMessageNotification(
        senderName: 'Dr. Ahmet',
        messageText: 'Tansiyonunuzu ölçtünüz mü?',
        chatId: 'user1_user2',
      );
      expect(triggeredMessage, isNull);

      // Different chat -> triggered
      await notif.showMessageNotification(
        senderName: 'Dr. Zeynep',
        messageText: 'Yeni tahlil sonucunuz yüklendi.',
        chatId: 'user1_user3',
      );
      expect(triggeredMessage, equals('Yeni tahlil sonucunuz yüklendi.'));
    });

    test('HealthReportPdfService builds clinical health summary carnet', () async {
      final service = HealthReportPdfService.instance;
      final tracks = [
        FollowUpTrackStatus(
          track: FollowUpTrack.hydrationDaily,
          enabled: true,
          lastCheckedAt: DateTime.now(),
          isDueNow: true,
          daysRemaining: 0,
        ),
      ];

      final bytes = await service.generatePdfBytes(
        patientName: 'Test Üye',
        tracks: tracks,
        bloodPressureStr: '120/80 mmHg',
        bloodSugarStr: '95 mg/dL',
        medications: ['Metformin 500mg - Sabah', 'D Vitamini 1000 IU'],
        recentFindings: ['Sklera: Normal ve berrak', 'Dil: Hafif paslı görünüm'],
      );

      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      // Valid PDF magic header %PDF
      expect(bytes.take(4), equals([37, 80, 68, 70]));
    });
  });
}
