import 'package:flutter/material.dart';

/// Curated health & wellness focus tags used for opt-in worldwide discovery.
/// Private lab reports, camera scans, and medication photos are NEVER shared.
enum HealthGoalTag {
  diabetes,
  bloodPressure,
  weightDiet,
  healthyLiving,
  herbalWellness,
  parentingGrowth,
  skinCare,
  fitnessWalk,
  sleepStress,
}

extension HealthGoalTagX on HealthGoalTag {
  String get id => name;

  static HealthGoalTag? fromId(String? value) {
    for (final tag in HealthGoalTag.values) {
      if (tag.name == value) return tag;
    }
    return null;
  }

  IconData get icon {
    switch (this) {
      case HealthGoalTag.diabetes:
        return Icons.bloodtype_rounded;
      case HealthGoalTag.bloodPressure:
        return Icons.favorite_rounded;
      case HealthGoalTag.weightDiet:
        return Icons.restaurant_menu_rounded;
      case HealthGoalTag.healthyLiving:
        return Icons.eco_rounded;
      case HealthGoalTag.herbalWellness:
        return Icons.emoji_food_beverage_rounded;
      case HealthGoalTag.parentingGrowth:
        return Icons.child_care_rounded;
      case HealthGoalTag.skinCare:
        return Icons.face_retouching_natural_rounded;
      case HealthGoalTag.fitnessWalk:
        return Icons.directions_walk_rounded;
      case HealthGoalTag.sleepStress:
        return Icons.bedtime_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case HealthGoalTag.diabetes:
        return const Color(0xFFC8553D);
      case HealthGoalTag.bloodPressure:
        return const Color(0xFFDC2626);
      case HealthGoalTag.weightDiet:
        return const Color(0xFF16A34A);
      case HealthGoalTag.healthyLiving:
        return const Color(0xFF0B6E6E);
      case HealthGoalTag.herbalWellness:
        return const Color(0xFF15803D);
      case HealthGoalTag.parentingGrowth:
        return const Color(0xFF2563EB);
      case HealthGoalTag.skinCare:
        return const Color(0xFFD97706);
      case HealthGoalTag.fitnessWalk:
        return const Color(0xFF0891B2);
      case HealthGoalTag.sleepStress:
        return const Color(0xFF7C3AED);
    }
  }
}

/// Supported country options for global health buddy discovery.
class CommunityCountryOption {
  const CommunityCountryOption({
    required this.code,
    required this.flag,
    required this.label,
  });

  final String code;
  final String flag;
  final String label;

  static const List<CommunityCountryOption> all = [
    CommunityCountryOption(code: 'TR', flag: '🇹🇷', label: 'Türkiye'),
    CommunityCountryOption(code: 'US', flag: '🇺🇸', label: 'United States'),
    CommunityCountryOption(code: 'GB', flag: '🇬🇧', label: 'United Kingdom'),
    CommunityCountryOption(code: 'DE', flag: '🇩🇪', label: 'Deutschland'),
    CommunityCountryOption(code: 'FR', flag: '🇫🇷', label: 'France'),
    CommunityCountryOption(code: 'ES', flag: '🇪🇸', label: 'España'),
    CommunityCountryOption(code: 'BR', flag: '🇧🇷', label: 'Brasil'),
    CommunityCountryOption(code: 'SA', flag: '🇸🇦', label: 'السعودية'),
    CommunityCountryOption(code: 'AE', flag: '🇦🇪', label: 'UAE'),
    CommunityCountryOption(code: 'IN', flag: '🇮🇳', label: 'India'),
    CommunityCountryOption(code: 'PK', flag: '🇵🇰', label: 'Pakistan'),
    CommunityCountryOption(code: 'BD', flag: '🇧🇩', label: 'Bangladesh'),
    CommunityCountryOption(code: 'RU', flag: '🇷🇺', label: 'Россия'),
    CommunityCountryOption(code: 'CN', flag: '🇨🇳', label: '中国'),
    CommunityCountryOption(code: 'JP', flag: '🇯🇵', label: '日本'),
    CommunityCountryOption(code: 'CA', flag: '🇨🇦', label: 'Canada'),
    CommunityCountryOption(code: 'NL', flag: '🇳🇱', label: 'Nederland'),
    CommunityCountryOption(code: 'GLOBAL', flag: '🌍', label: 'Global'),
  ];

  static CommunityCountryOption byCode(String? code) {
    final normalized = (code ?? '').trim().toUpperCase();
    for (final c in all) {
      if (c.code == normalized) return c;
    }
    return all.last;
  }
}

/// Public opt-in Health Community profile stored separately from private
/// medical backup collections (`community_profiles/{uid}`).
class HealthCommunityProfile {
  const HealthCommunityProfile({
    required this.uid,
    required this.displayName,
    this.nickname = '',
    this.photoUrl,
    this.photoKey,
    this.countryCode = 'TR',
    this.city = '',
    this.languageCode = 'tr',
    this.healthGoals = const [HealthGoalTag.healthyLiving],
    this.bio = '',
    this.dailyFocus = '',
    this.hideRealName = false,
    this.hidePhoto = false,
    this.showBio = true,
    this.discoverable = true,
    this.allowMessages = true,
    this.requireMessageApproval = true,
    this.likedBy = const [],
    this.isSampleProfile = false,
    required this.updatedAt,
  });

  final String uid;
  final String displayName;
  final String nickname;
  final String? photoUrl;
  final String? photoKey;
  final String countryCode;
  final String city;
  final String languageCode;
  final List<HealthGoalTag> healthGoals;
  final String bio;
  final String dailyFocus;
  final bool hideRealName;
  final bool hidePhoto;
  final bool showBio;
  final bool discoverable;
  final bool allowMessages;
  final bool requireMessageApproval;
  final List<String> likedBy;
  final bool isSampleProfile;
  final DateTime updatedAt;

  int get likesCount => likedBy.length;

  bool isLikedBy(String userId) => userId.isNotEmpty && likedBy.contains(userId);

  /// Privacy-aware public name (respects [hideRealName]).
  String get visibleName {
    if (hideRealName) {
      final cleanNick = nickname.trim();
      if (cleanNick.isNotEmpty) return '@$cleanNick';
      return 'VisualCheckUp Member';
    }
    final cleanName = displayName.trim();
    if (cleanName.isNotEmpty) return cleanName;
    final cleanNick = nickname.trim();
    return cleanNick.isNotEmpty ? '@$cleanNick' : 'VisualCheckUp Member';
  }

  String? get visiblePhotoUrl {
    if (hidePhoto) return null;
    if (photoUrl == null || photoUrl!.trim().isEmpty) return null;
    return photoUrl!.trim();
  }

  String get initials {
    final source = visibleName.replaceFirst('@', '').trim();
    if (source.isEmpty) return 'VC';
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  CommunityCountryOption get country => CommunityCountryOption.byCode(countryCode);

  /// Sanitizes user handles into lowercase ASCII `[a-z0-9_.]` (adapted from
  /// Social Formül Bank's proven handle sanitizer).
  static String sanitizeNickname(String raw) {
    const trMap = {
      'ç': 'c',
      'Ç': 'c',
      'ğ': 'g',
      'Ğ': 'g',
      'ı': 'i',
      'I': 'i',
      'İ': 'i',
      'ö': 'o',
      'Ö': 'o',
      'ş': 's',
      'Ş': 's',
      'ü': 'u',
      'Ü': 'u',
    };
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final ch = raw[i];
      buffer.write(trMap[ch] ?? ch);
    }
    return buffer
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^a-z0-9_.]'), '');
  }

  HealthCommunityProfile copyWith({
    String? uid,
    String? displayName,
    String? nickname,
    String? photoUrl,
    bool clearPhoto = false,
    String? photoKey,
    String? countryCode,
    String? city,
    String? languageCode,
    List<HealthGoalTag>? healthGoals,
    String? bio,
    String? dailyFocus,
    bool? hideRealName,
    bool? hidePhoto,
    bool? showBio,
    bool? discoverable,
    bool? allowMessages,
    bool? requireMessageApproval,
    List<String>? likedBy,
    bool? isSampleProfile,
    DateTime? updatedAt,
  }) {
    return HealthCommunityProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      nickname: nickname ?? this.nickname,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      photoKey: clearPhoto ? null : (photoKey ?? this.photoKey),
      countryCode: countryCode ?? this.countryCode,
      city: city ?? this.city,
      languageCode: languageCode ?? this.languageCode,
      healthGoals: healthGoals ?? this.healthGoals,
      bio: bio ?? this.bio,
      dailyFocus: dailyFocus ?? this.dailyFocus,
      hideRealName: hideRealName ?? this.hideRealName,
      hidePhoto: hidePhoto ?? this.hidePhoto,
      showBio: showBio ?? this.showBio,
      discoverable: discoverable ?? this.discoverable,
      allowMessages: allowMessages ?? this.allowMessages,
      requireMessageApproval:
          requireMessageApproval ?? this.requireMessageApproval,
      likedBy: likedBy ?? this.likedBy,
      isSampleProfile: isSampleProfile ?? this.isSampleProfile,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName.trim(),
      'nickname': sanitizeNickname(nickname),
      if (photoUrl != null && photoUrl!.trim().isNotEmpty)
        'photoUrl': photoUrl!.trim(),
      if (photoKey != null && photoKey!.trim().isNotEmpty)
        'photoKey': photoKey!.trim(),
      'countryCode': countryCode.toUpperCase(),
      'city': city.trim(),
      'languageCode': languageCode.toLowerCase(),
      'healthGoals': healthGoals.map((g) => g.id).toList(),
      'bio': bio.trim(),
      'dailyFocus': dailyFocus.trim(),
      'hideRealName': hideRealName,
      'hidePhoto': hidePhoto,
      'showBio': showBio,
      'discoverable': discoverable,
      'allowMessages': allowMessages,
      'requireMessageApproval': requireMessageApproval,
      'likedBy': likedBy,
      'likesCount': likedBy.length,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HealthCommunityProfile.fromJson(
    Map<String, dynamic> json, {
    String? fallbackUid,
  }) {
    final rawGoals = (json['healthGoals'] as List<dynamic>?)
            ?.map((e) => HealthGoalTagX.fromId(e?.toString()))
            .whereType<HealthGoalTag>()
            .toList() ??
        const <HealthGoalTag>[];

    final rawLikedBy = (json['likedBy'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];

    DateTime parsedUpdated = DateTime.now();
    final rawUpdated = json['updatedAt'];
    if (rawUpdated is String) {
      parsedUpdated = DateTime.tryParse(rawUpdated) ?? parsedUpdated;
    }

    return HealthCommunityProfile(
      uid: (json['uid'] as String?) ?? fallbackUid ?? '',
      displayName: (json['displayName'] as String?) ?? '',
      nickname: (json['nickname'] as String?) ?? '',
      photoUrl: json['photoUrl'] as String?,
      photoKey: json['photoKey'] as String?,
      countryCode: (json['countryCode'] as String?) ?? 'GLOBAL',
      city: (json['city'] as String?) ?? '',
      languageCode: (json['languageCode'] as String?) ?? 'en',
      healthGoals:
          rawGoals.isEmpty ? const [HealthGoalTag.healthyLiving] : rawGoals,
      bio: (json['bio'] as String?) ?? '',
      dailyFocus: (json['dailyFocus'] as String?) ?? '',
      hideRealName: (json['hideRealName'] as bool?) ?? false,
      hidePhoto: (json['hidePhoto'] as bool?) ?? false,
      showBio: (json['showBio'] as bool?) ?? true,
      discoverable: (json['discoverable'] as bool?) ?? true,
      allowMessages: (json['allowMessages'] as bool?) ?? true,
      requireMessageApproval:
          (json['requireMessageApproval'] as bool?) ?? true,
      likedBy: rawLikedBy,
      isSampleProfile: (json['isSampleProfile'] as bool?) ?? false,
      updatedAt: parsedUpdated,
    );
  }
}

/// Approval state for a 1-on-1 community conversation (protects privacy).
enum ConversationRequestStatus {
  pending,
  accepted,
  declined,
}

extension ConversationRequestStatusX on ConversationRequestStatus {
  static ConversationRequestStatus fromId(String? value) {
    for (final s in ConversationRequestStatus.values) {
      if (s.name == value) return s;
    }
    return ConversationRequestStatus.accepted;
  }
}

/// Result status returned by `sendMessage`.
enum SendMessageStatus {
  sent,
  rateLimited,
  dailyLimitExceeded,
  blocked,
  senderDisabledMessages,
  receiverDisabledMessages,
  requestDeclined,
  emptyContent,
  error,
}

/// Summary document for a 1-on-1 community conversation.
class CommunityConversation {
  const CommunityConversation({
    required this.chatId,
    required this.members,
    required this.requesterId,
    required this.status,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastMessageAt,
    this.displayNames = const {},
    this.photoUrls = const {},
    this.readBy = const {},
    this.mutedBy = const [],
    this.deletedFor = const [],
  });

  final String chatId;
  final List<String> members;
  final String requesterId;
  final ConversationRequestStatus status;
  final String lastMessage;
  final String lastSenderId;
  final DateTime lastMessageAt;
  final Map<String, String> displayNames;
  final Map<String, String> photoUrls;
  final Map<String, bool> readBy;
  final List<String> mutedBy;
  final List<String> deletedFor;

  static String chatIdFor(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return ids.join('_');
  }

  String peerIdFor(String myUid) =>
      members.firstWhere((id) => id != myUid, orElse: () => '');

  String peerNameFor(String myUid) {
    final peer = peerIdFor(myUid);
    return displayNames[peer] ?? 'Member';
  }

  String? peerPhotoFor(String myUid) {
    final peer = peerIdFor(myUid);
    final url = photoUrls[peer];
    return (url != null && url.trim().isNotEmpty) ? url : null;
  }

  bool isUnreadFor(String myUid) =>
      lastSenderId != myUid && (readBy[myUid] == false);

  bool isMutedFor(String myUid) => mutedBy.contains(myUid);

  bool isHiddenFor(String myUid) => deletedFor.contains(myUid);

  bool isPendingIncomingFor(String myUid) =>
      status == ConversationRequestStatus.pending && requesterId != myUid;

  CommunityConversation copyWith({
    ConversationRequestStatus? status,
    String? lastMessage,
    String? lastSenderId,
    DateTime? lastMessageAt,
    Map<String, String>? displayNames,
    Map<String, String>? photoUrls,
    Map<String, bool>? readBy,
    List<String>? mutedBy,
    List<String>? deletedFor,
  }) {
    return CommunityConversation(
      chatId: chatId,
      members: members,
      requesterId: requesterId,
      status: status ?? this.status,
      lastMessage: lastMessage ?? this.lastMessage,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      displayNames: displayNames ?? this.displayNames,
      photoUrls: photoUrls ?? this.photoUrls,
      readBy: readBy ?? this.readBy,
      mutedBy: mutedBy ?? this.mutedBy,
      deletedFor: deletedFor ?? this.deletedFor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'members': members,
      'requesterId': requesterId,
      'status': status.name,
      'lastMessage': lastMessage,
      'lastSenderId': lastSenderId,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'displayNames': displayNames,
      'photoUrls': photoUrls,
      'readBy': readBy,
      'mutedBy': mutedBy,
      'deletedFor': deletedFor,
    };
  }

  factory CommunityConversation.fromJson(Map<String, dynamic> json) {
    final rawReadBy = <String, bool>{};
    if (json['readBy'] is Map) {
      (json['readBy'] as Map).forEach((k, v) {
        if (k is String && v is bool) rawReadBy[k] = v;
      });
    }
    final rawNames = <String, String>{};
    if (json['displayNames'] is Map) {
      (json['displayNames'] as Map).forEach((k, v) {
        if (k is String && v != null) rawNames[k] = v.toString();
      });
    }
    final rawPhotos = <String, String>{};
    if (json['photoUrls'] is Map) {
      (json['photoUrls'] as Map).forEach((k, v) {
        if (k is String && v != null) rawPhotos[k] = v.toString();
      });
    }
    return CommunityConversation(
      chatId: (json['chatId'] as String?) ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      requesterId: (json['requesterId'] as String?) ?? '',
      status: ConversationRequestStatusX.fromId(json['status'] as String?),
      lastMessage: (json['lastMessage'] as String?) ?? '',
      lastSenderId: (json['lastSenderId'] as String?) ?? '',
      lastMessageAt: DateTime.tryParse((json['lastMessageAt'] as String?) ?? '') ??
          DateTime.now(),
      displayNames: rawNames,
      photoUrls: rawPhotos,
      readBy: rawReadBy,
      mutedBy: (json['mutedBy'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      deletedFor: (json['deletedFor'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }
}

/// A single chat message supporting text and optional uploaded image attachment.
class CommunityChatMessage {
  const CommunityChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.text = '',
    this.imageUrl,
    this.imageKey,
    required this.sentAt,
    this.isRead = false,
    this.deletedFor = const [],
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String? imageUrl;
  final String? imageKey;
  final DateTime sentAt;
  final bool isRead;
  final List<String> deletedFor;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  bool isHiddenFor(String uid) => deletedFor.contains(uid);

  CommunityChatMessage copyWith({
    bool? isRead,
    List<String>? deletedFor,
  }) {
    return CommunityChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      imageUrl: imageUrl,
      imageKey: imageKey,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
      deletedFor: deletedFor ?? this.deletedFor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      if (imageUrl != null && imageUrl!.trim().isNotEmpty)
        'imageUrl': imageUrl!.trim(),
      if (imageKey != null && imageKey!.trim().isNotEmpty)
        'imageKey': imageKey!.trim(),
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
      'deletedFor': deletedFor,
    };
  }

  factory CommunityChatMessage.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return CommunityChatMessage(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      senderId: (json['senderId'] as String?) ?? '',
      receiverId: (json['receiverId'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      imageUrl: json['imageUrl'] as String?,
      imageKey: json['imageKey'] as String?,
      sentAt: DateTime.tryParse((json['sentAt'] as String?) ?? '') ??
          DateTime.now(),
      isRead: (json['isRead'] as bool?) ?? false,
      deletedFor: (json['deletedFor'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }
}

/// Standardized UGC safety report reasons (App Store / Google Play compliance).
enum CommunityReportReason {
  inappropriate,
  spam,
  harassment,
  medicalMisinformation,
  other,
}
