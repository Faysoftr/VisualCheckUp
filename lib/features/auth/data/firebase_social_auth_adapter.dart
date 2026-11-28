import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:visualcheckup/features/auth/data/auth_service.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';

/// Production native Google & Apple Sign-In adapter backed by Firebase Auth.
/// Also fetches user birthday/age & gender from Google People API (ported from
/// Social Formül Bank) when granted by the account.
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

  Future<({String? birthDate, String? gender})> _fetchGoogleDemographics(
    String accessToken,
  ) async {
    try {
      final resp = await http
          .get(
            Uri.parse(
              'https://people.googleapis.com/v1/people/me?personFields=birthdays,genders',
            ),
            headers: {'Authorization': 'Bearer $accessToken'},
          )
          .timeout(const Duration(seconds: 4));

      if (resp.statusCode != 200) {
        return (birthDate: null, gender: null);
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      String? formattedBirth;
      final birthdays = data['birthdays'] as List<dynamic>?;
      if (birthdays != null && birthdays.isNotEmpty) {
        for (final entry in birthdays) {
          if (entry is Map && entry['date'] is Map) {
            final d = entry['date'] as Map;
            final day = (d['day'] as num?)?.toInt();
            final month = (d['month'] as num?)?.toInt();
            final year = (d['year'] as num?)?.toInt();
            if (day != null && month != null && year != null) {
              formattedBirth =
                  '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
              // Also sync birthday celebration local prefs if not set yet
              try {
                final prefs = await SharedPreferences.getInstance();
                if (!prefs.containsKey('vcu_user_birth_month')) {
                  await prefs.setInt('vcu_user_birth_month', month);
                  await prefs.setInt('vcu_user_birth_day', day);
                }
              } catch (_) {}
              break;
            }
          }
        }
      }

      String? normalizedGender;
      final genders = data['genders'] as List<dynamic>?;
      if (genders != null && genders.isNotEmpty) {
        final rawVal =
            ((genders.first as Map)['value'] ?? '').toString().toLowerCase();
        if (rawVal == 'male') {
          normalizedGender = 'Male';
        } else if (rawVal == 'female') {
          normalizedGender = 'Female';
        }
      }

      return (birthDate: formattedBirth, gender: normalizedGender);
    } catch (_) {
      return (birthDate: null, gender: null);
    }
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
    final scopes = (!kIsWeb && Platform.isIOS)
        ? const ['email', 'profile']
        : const [
            'email',
            'profile',
            'https://www.googleapis.com/auth/user.birthday.read',
          ];

    try {
      final authz =
          await account.authorizationClient.authorizationForScopes(scopes);
      accessToken = authz?.accessToken;
    } catch (_) {
      try {
        final fallbackAuthz = await account.authorizationClient
            .authorizationForScopes(const ['email', 'profile']);
        accessToken = fallbackAuthz?.accessToken;
      } catch (_) {}
    }

    String? googleBirthDate;
    String? googleGender;
    if (accessToken != null && accessToken.isNotEmpty) {
      final demo = await _fetchGoogleDemographics(accessToken);
      googleBirthDate = demo.birthDate;
      googleGender = demo.gender;
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
          displayName:
              (fbUser.displayName ?? account.displayName ?? account.email)
                  .trim(),
          email: fbUser.email ?? account.email,
          photoUrl: fbUser.photoURL ?? account.photoUrl,
          birthDate: googleBirthDate,
          gender: googleGender,
          provider: AuthProviderType.google,
        );
      }
    }

    return AuthUser(
      id: account.id,
      displayName: (account.displayName ?? account.email).trim(),
      email: account.email,
      photoUrl: account.photoUrl,
      birthDate: googleBirthDate,
      gender: googleGender,
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
      id: appleCred.userIdentifier ??
          'apple_${DateTime.now().millisecondsSinceEpoch}',
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
    } catch (_) {}
    try {
      if (_firebaseReady) {
        await fb.FirebaseAuth.instance.signOut();
      }
    } catch (_) {}
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
