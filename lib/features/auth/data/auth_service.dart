import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';

/// Optional adapter interface for plugging in real `google_sign_in`,
/// `sign_in_with_apple`, and `firebase_auth` credentials once Firebase and
/// Apple Developer OAuth keys are configured.
abstract class SocialAuthAdapter {
  Future<AuthUser?> authenticateWithGoogle();
  Future<AuthUser?> authenticateWithApple();
  Future<void> signOutProvider();
}

abstract class AuthService {
  Future<AuthUser?> loadCurrentUser();
  Future<AuthUser> signInWithGoogle();
  Future<AuthUser> signInWithApple();
  Future<AuthUser> continueAsGuest();
  Future<void> signOut();
  Future<void> deleteAccount();
}

/// Persists the active user session locally and delegates to [socialAdapter]
/// when real Google / Apple OAuth SDKs are connected.
class LocalAuthService implements AuthService {
  const LocalAuthService({this.socialAdapter});

  static const String _authUserKey = 'visualcheckup_auth_user_v1';

  final SocialAuthAdapter? socialAdapter;

  @override
  Future<AuthUser?> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_authUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    final adapter = socialAdapter;
    final user = (adapter != null
            ? await adapter.authenticateWithGoogle()
            : null) ??
        const AuthUser(
          id: 'google_local_demo',
          displayName: 'Google Kullanıcısı',
          email: 'kullanici@gmail.com',
          provider: AuthProviderType.google,
        );
    await _persistUser(user);
    return user;
  }

  @override
  Future<AuthUser> signInWithApple() async {
    final adapter = socialAdapter;
    final user = (adapter != null
            ? await adapter.authenticateWithApple()
            : null) ??
        const AuthUser(
          id: 'apple_local_demo',
          displayName: 'Apple Kullanıcısı',
          email: 'kullanici@icloud.com',
          provider: AuthProviderType.apple,
        );
    await _persistUser(user);
    return user;
  }

  @override
  Future<AuthUser> continueAsGuest() async {
    const guest = AuthUser(
      id: 'guest_local',
      displayName: 'Misafir Kullanıcı',
      provider: AuthProviderType.guest,
    );
    await _persistUser(guest);
    return guest;
  }

  @override
  Future<void> signOut() async {
    await socialAdapter?.signOutProvider();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authUserKey);
  }

  @override
  Future<void> deleteAccount() async {
    await socialAdapter?.signOutProvider();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authUserKey);
  }

  Future<void> _persistUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authUserKey, jsonEncode(user.toJson()));
  }
}
