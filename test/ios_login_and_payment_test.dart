import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/iap/in_app_purchase_service.dart';
import 'package:visualcheckup/features/auth/data/auth_service.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/doctors/data/doctor_repository.dart';
import 'package:visualcheckup/features/doctors/presentation/screens/doctor_application_screen.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';
import 'package:visualcheckup/features/subscription/domain/subscription_models.dart';
import 'package:visualcheckup/features/subscription/presentation/screens/pro_paywall_screen.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('iOS Entitlements, Info.plist & Xcode Build Configuration', () {
    test('Runner.entitlements contains Sign in with Apple capability', () {
      final file = File('ios/Runner/Runner.entitlements');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('com.apple.developer.applesignin'));
      expect(content, contains('<string>Default</string>'));
    });

    test('Info.plist contains CFBundleURLTypes for iOS Google Sign In callback', () {
      final file = File('ios/Runner/Info.plist');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('CFBundleURLTypes'));
      expect(content, contains('com.googleusercontent.apps.913513035294-j8khu3gljmh61fe5kbup2b1jkbt2u9ab'));
    });

    test('project.pbxproj configures CODE_SIGN_ENTITLEMENTS for Debug, Release, Profile', () {
      final file = File('ios/Runner.xcodeproj/project.pbxproj');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;'));
      expect(content, contains('IPHONEOS_DEPLOYMENT_TARGET = 15.0;'));
    });

    test('Podfile targets iOS 15.0 and enables modular headers', () {
      final file = File('ios/Podfile');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains("platform :ios, '15.0'"));
      expect(content, contains('use_modular_headers!'));
      expect(content, contains('PERMISSION_CAMERA=1'));
      expect(content, contains('PERMISSION_PHOTOS=1'));
    });
  });

  group('iOS Sign in with Apple & Google Sign In Flow', () {
    test('LocalAuthService completes Sign in with Apple and persists user session', () async {
      final auth = LocalAuthService();
      final user = await auth.signInWithApple();

      expect(user.provider, equals(AuthProviderType.apple));
      expect(user.displayName, equals('Apple Kullanıcısı'));

      final loaded = await auth.loadCurrentUser();
      expect(loaded, isNotNull);
      expect(loaded!.provider, equals(AuthProviderType.apple));
    });

    test('LocalAuthService completes Google Sign In and persists user session', () async {
      final auth = LocalAuthService();
      final user = await auth.signInWithGoogle();

      expect(user.provider, equals(AuthProviderType.google));
      expect(user.displayName, equals('Google Kullanıcısı'));

      final loaded = await auth.loadCurrentUser();
      expect(loaded, isNotNull);
      expect(loaded!.provider, equals(AuthProviderType.google));
    });
  });

  group('iOS In-App Purchase Service & Pro Paywall Compliance', () {
    test('HealthInAppPurchaseService initializes product IDs and activates fallback locally', () async {
      final iap = HealthInAppPurchaseService.instance;
      final subRepo = SubscriptionRepository(useFirebase: false);
      final docRepo = DoctorRepository(useFirebase: false);

      await iap.initialize(subRepo: subRepo, docRepo: docRepo);

      expect(HealthInAppPurchaseService.allProductIds, contains('visualcheckup_pro_monthly'));
      expect(HealthInAppPurchaseService.allProductIds, contains('visualcheckup_pro_yearly'));
      expect(HealthInAppPurchaseService.allProductIds, contains('visualcheckup_doctor_standard'));

      // Test buying subscription with fallback
      final bought = await iap.buySubscription(HealthInAppPurchaseService.proYearly, userId: 'test_ios_user');
      expect(bought, isTrue);

      final state = await subRepo.loadSubscription(uid: 'test_ios_user');
      expect(state.isPro, isTrue);
      expect(state.tier, equals(SubscriptionTier.proYearly));
    });

    testWidgets('ProPaywallScreen displays restore button, EULA terms & privacy links (Apple Guideline 3.1.2)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final subRepo = SubscriptionRepository(useFirebase: false);

      await tester.pumpWidget(
        _wrap(
          ProPaywallScreen(
            repository: subRepo,
            userId: 'user_paywall_ios',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Plan options
      expect(find.text('Yıllık Plan'), findsOneWidget);
      expect(find.text('Aylık Plan'), findsOneWidget);

      // Check Restore Button (Guideline 3.1.1)
      expect(find.byKey(const Key('pro_restore_button')), findsOneWidget);

      // Check Privacy & EULA Links (Guideline 3.1.2)
      expect(find.byKey(const Key('pro_privacy_policy_link')), findsOneWidget);
      expect(find.byKey(const Key('pro_terms_eula_link')), findsOneWidget);

      // Check Auto-Renew Terms Disclaimer
      expect(find.textContaining('Apple Kimliği (App Store) veya Google Play'), findsOneWidget);

      // Tap Subscribe Button
      await tester.tap(find.byKey(const Key('pro_subscribe_button')));
      await tester.pumpAndSettle();

      final updated = await subRepo.loadSubscription(uid: 'user_paywall_ios');
      expect(updated.isPro, isTrue);
    });

    testWidgets('DoctorApplicationScreen processes in-app purchase for verified doctor listing', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final doctorRepo = DoctorRepository(useFirebase: false);
      const user = AuthUser(
        id: 'dr_ios_tester',
        email: 'doctor_ios@test.com',
        displayName: 'Dr. Mehmet Kaya',
        provider: AuthProviderType.apple,
      );

      await tester.pumpWidget(
        _wrap(
          DoctorApplicationScreen(
            currentUser: user,
            repository: doctorRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('doctor_play_purchase_button')));
      await tester.tap(find.byKey(const Key('doctor_play_purchase_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Satın Alındı'), findsOneWidget);
    });
  });
}
