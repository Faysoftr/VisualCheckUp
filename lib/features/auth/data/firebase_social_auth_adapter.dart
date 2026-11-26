import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:visualcheckup/features/auth/data/auth_service.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';

/// Production native Google & Apple Sign-In adapter backed by Firebase Auth.
///
/// Opens the native Android/iOS Google account chooser (via `google_sign_in`
/// v7) or Sign in with Apple sheet (via `sign_in_with_apple`) and links the
/// credential to Firebase Authentication when Firebase is initialized.
class FirebaseSocialAuthAdapter implements SocialAuthAdapter {
  FirebaseSocialAuthAdapter({this.serverClientId});

  final String? serverClientId;
  bool _googleInitialized = false;

  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: serverClientId,
    );
    _googleInitialized = true;
  }

  @override
  Future<AuthUser?> authenticateWithGoogle() async {
    await _ensureGoogleInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      rethrow;
    }

    final idToken = account.authentication.idToken;
    String? accessToken;
    try {
      final authz = await account.authorizationClient
          .authorizationForScopes(const ['email', 'profile']);
      accessToken = authz?.accessToken;
    } catch (_) {
      // ID token alone is sufficient for Firebase Auth on Android & iOS.
    }

    if (_firebaseReady && idToken != null && idToken.isNotEmpty) {
      final credential = fb.GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      final userCred =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final fbUser = userCred.user;
      if (fbUser != null) {
        return AuthUser(
          id: fbUser.uid,
          displayName: (fbUser.displayName ?? account.displayName ?? account.email)
              .trim(),
          email: fbUser.email ?? account.email,
          provider: AuthProviderType.google,
        );
      }
    }

    return AuthUser(
      id: account.id,
      displayName: (account.displayName ?? account.email).trim(),
      email: account.email,
      provider: AuthProviderType.google,
    );
  }

  @override
  Future<AuthUser?> authenticateWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID appleCred;
    try {
      appleCred = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelledException();
      }
      rethrow;
    }

    final fullName = [appleCred.givenName, appleCred.familyName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();

    if (_firebaseReady &&
        appleCred.identityToken != null &&
        appleCred.identityToken!.isNotEmpty) {
      final oauthCred = fb.OAuthProvider('apple.com').credential(
        idToken: appleCred.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCred.authorizationCode,
      );
      final userCred =
          await fb.FirebaseAuth.instance.signInWithCredential(oauthCred);
      final fbUser = userCred.user;
      if (fbUser != null) {
        final resolvedName = fullName.isNotEmpty
            ? fullName
            : (fbUser.displayName?.trim().isNotEmpty == true
                ? fbUser.displayName!.trim()
                : (fbUser.email ?? 'Apple Kullanıcısı'));
        return AuthUser(
          id: fbUser.uid,
          displayName: resolvedName,
          email: fbUser.email ?? appleCred.email,
          provider: AuthProviderType.apple,
        );
      }
    }

    return AuthUser(
      id: appleCred.userIdentifier ?? 'apple_${DateTime.now().millisecondsSinceEpoch}',
      displayName: fullName.isNotEmpty
          ? fullName
          : (appleCred.email ?? 'Apple Kullanıcısı'),
      email: appleCred.email,
      provider: AuthProviderType.apple,
    );
  }

  @override
  Future<void> signOutProvider() async {
    try {
      if (_googleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {
      // Ignore provider sign-out failures on unsupported platforms.
    }
    try {
      if (_firebaseReady) {
        await fb.FirebaseAuth.instance.signOut();
      }
    } catch (_) {
      // Ignore Firebase sign-out failures.
    }
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
