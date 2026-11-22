enum AuthProviderType {
  guest,
  google,
  apple,
}

extension AuthProviderTypeX on AuthProviderType {
  String get label {
    switch (this) {
      case AuthProviderType.guest:
        return 'Misafir';
      case AuthProviderType.google:
        return 'Google';
      case AuthProviderType.apple:
        return 'Apple';
    }
  }

  static AuthProviderType fromName(String name) {
    return AuthProviderType.values.firstWhere(
      (p) => p.name == name,
      orElse: () => AuthProviderType.guest,
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.displayName,
    required this.provider,
    this.email,
    this.photoUrl,
  });

  final String id;
  final String displayName;
  final AuthProviderType provider;
  final String? email;
  final String? photoUrl;

  bool get isGuest => provider == AuthProviderType.guest;

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'V';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'provider': provider.name,
        if (email != null) 'email': email,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      provider: AuthProviderTypeX.fromName(json['provider'] as String),
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
