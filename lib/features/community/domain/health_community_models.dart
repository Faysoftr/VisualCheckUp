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
    CommunityCountryOption(code: 'SE', flag: '🇸🇪', label: 'Sverige'),
    CommunityCountryOption(code: 'FR', flag: '🇫🇷', label: 'France'),
    CommunityCountryOption(code: 'ES', flag: '🇪🇸', label: 'España'),
    CommunityCountryOption(code: 'IT', flag: '🇮🇹', label: 'Italia'),
    CommunityCountryOption(code: 'NL', flag: '🇳🇱', label: 'Nederland'),
    CommunityCountryOption(code: 'CH', flag: '🇨🇭', label: 'Schweiz'),
    CommunityCountryOption(code: 'AT', flag: '🇦🇹', label: 'Österreich'),
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

/// Optional chronic conditions users can list on their community profile
/// to find peers navigating the same health journey worldwide.
enum ChronicCondition {
  type1Diabetes,
  type2Diabetes,
  hypertension,
  asthmaCopd,
  thyroidHashimoto,
  migraine,
  heartCondition,
  celiacIbs,
  arthritisRheumatism,
  anemia,
  kidneyHealth,
  eczemaPsoriasis,
}

extension ChronicConditionX on ChronicCondition {
  String get id => name;

  static ChronicCondition? fromId(String? value) {
    for (final c in ChronicCondition.values) {
      if (c.name == value) return c;
    }
    return null;
  }

  IconData get icon {
    switch (this) {
      case ChronicCondition.type1Diabetes:
      case ChronicCondition.type2Diabetes:
        return Icons.bloodtype_rounded;
      case ChronicCondition.hypertension:
      case ChronicCondition.heartCondition:
        return Icons.monitor_heart_rounded;
      case ChronicCondition.asthmaCopd:
        return Icons.air_rounded;
      case ChronicCondition.thyroidHashimoto:
        return Icons.biotech_rounded;
      case ChronicCondition.migraine:
        return Icons.psychology_alt_rounded;
      case ChronicCondition.celiacIbs:
        return Icons.restaurant_rounded;
      case ChronicCondition.arthritisRheumatism:
        return Icons.accessibility_new_rounded;
      case ChronicCondition.anemia:
        return Icons.water_drop_rounded;
      case ChronicCondition.kidneyHealth:
        return Icons.medical_services_outlined;
      case ChronicCondition.eczemaPsoriasis:
        return Icons.spa_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case ChronicCondition.type1Diabetes:
        return const Color(0xFFB91C1C);
      case ChronicCondition.type2Diabetes:
        return const Color(0xFFC8553D);
      case ChronicCondition.hypertension:
        return const Color(0xFFDC2626);
      case ChronicCondition.asthmaCopd:
        return const Color(0xFF0284C7);
      case ChronicCondition.thyroidHashimoto:
        return const Color(0xFF7C3AED);
      case ChronicCondition.migraine:
        return const Color(0xFF6D28D9);
      case ChronicCondition.heartCondition:
        return const Color(0xFFBE123C);
      case ChronicCondition.celiacIbs:
        return const Color(0xFF15803D);
      case ChronicCondition.arthritisRheumatism:
        return const Color(0xFFD97706);
      case ChronicCondition.anemia:
        return const Color(0xFF9F1239);
      case ChronicCondition.kidneyHealth:
        return const Color(0xFF0F766E);
      case ChronicCondition.eczemaPsoriasis:
        return const Color(0xFFEA580C);
    }
  }
}

/// Daily wellness mood displayed on community profiles and discovery cards.
enum HealthMood {
  energetic,
  calm,
  grateful,
  focused,
  tired,
  recovering,
}

extension HealthMoodX on HealthMood {
  String get id => name;

  static HealthMood? fromId(String? value) {
    for (final m in HealthMood.values) {
      if (m.name == value) return m;
    }
    return null;
  }

  String get emoji {
    switch (this) {
      case HealthMood.energetic:
        return '⚡';
      case HealthMood.calm:
        return '🌿';
      case HealthMood.grateful:
        return '💛';
      case HealthMood.focused:
        return '🎯';
      case HealthMood.tired:
        return '🌙';
      case HealthMood.recovering:
        return '🩹';
    }
  }

  Color get accentColor {
    switch (this) {
      case HealthMood.energetic:
        return const Color(0xFF16A34A);
      case HealthMood.calm:
        return const Color(0xFF0B6E6E);
      case HealthMood.grateful:
        return const Color(0xFFD97706);
      case HealthMood.focused:
        return const Color(0xFF2563EB);
      case HealthMood.tired:
        return const Color(0xFF7C3AED);
      case HealthMood.recovering:
        return const Color(0xFFE11D48);
    }
  }
}

/// Computed wellness & community engagement badges shown on profiles.
enum HealthAchievementBadge {
  verifiedMember,
  streak7,
  streak30,
  communityHelper,
  chronicWarrior,
  musicLover,
}

extension HealthAchievementBadgeX on HealthAchievementBadge {
  String get emoji {
    switch (this) {
      case HealthAchievementBadge.verifiedMember:
        return '✅';
      case HealthAchievementBadge.streak7:
        return '🔥';
      case HealthAchievementBadge.streak30:
        return '🏆';
      case HealthAchievementBadge.communityHelper:
        return '💚';
      case HealthAchievementBadge.chronicWarrior:
        return '🛡️';
      case HealthAchievementBadge.musicLover:
        return '🎵';
    }
  }

  Color get accentColor {
    switch (this) {
      case HealthAchievementBadge.verifiedMember:
        return const Color(0xFF2563EB);
      case HealthAchievementBadge.streak7:
        return const Color(0xFFEA580C);
      case HealthAchievementBadge.streak30:
        return const Color(0xFFD97706);
      case HealthAchievementBadge.communityHelper:
        return const Color(0xFF16A34A);
      case HealthAchievementBadge.chronicWarrior:
        return const Color(0xFF0B6E6E);
      case HealthAchievementBadge.musicLover:
        return const Color(0xFF7C3AED);
    }
  }
}

/// Supported social media platforms on Health Community profiles.
class SocialLinksHelper {
  SocialLinksHelper._();

  static String? buildProfileUrl(String platform, String rawHandle) {
    final trimmed = rawHandle.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final clean = trimmed.startsWith('@') ? trimmed.substring(1).trim() : trimmed;
    if (clean.isEmpty) return null;
    switch (platform.toLowerCase()) {
      case 'instagram':
        return 'https://instagram.com/$clean';
      case 'x':
      case 'twitter':
        return 'https://x.com/$clean';
      case 'tiktok':
        return 'https://www.tiktok.com/@$clean';
      case 'facebook':
        return 'https://facebook.com/$clean';
      case 'snapchat':
        return 'https://snapchat.com/add/$clean';
      default:
        return null;
    }
  }
}

/// Validates and parses concentration/relaxation music links (YouTube,
/// YouTube Music, Spotify, Apple Music, SoundCloud).
class MusicLinkHelper {
  MusicLinkHelper._();

  static bool isSupportedMusicUrl(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.isEmpty) return true; // Optional field
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return false;
    }
    return trimmed.contains('youtube.com') ||
        trimmed.contains('youtu.be') ||
        trimmed.contains('music.youtube.com') ||
        trimmed.contains('spotify.com') ||
        trimmed.contains('soundcloud.com') ||
        trimmed.contains('music.apple.com');
  }

  static String detectPlatformName(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('music.youtube.com')) return 'YouTube Music';
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return 'YouTube';
    }
    if (lower.contains('spotify.com')) return 'Spotify';
    if (lower.contains('music.apple.com')) return 'Apple Music';
    if (lower.contains('soundcloud.com')) return 'SoundCloud';
    return 'Music';
  }

  static Color detectPlatformColor(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('spotify.com')) return const Color(0xFF1DB954);
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return const Color(0xFFFF0033);
    }
    if (lower.contains('soundcloud.com')) return const Color(0xFFFF5500);
    if (lower.contains('music.apple.com')) return const Color(0xFFFA243C);
    return const Color(0xFF7C3AED);
  }

  static String? extractYoutubeVideoId(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
    if (host.contains('youtube.com')) {
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;
      if (uri.pathSegments.length >= 2 &&
          (uri.pathSegments.first == 'embed' ||
              uri.pathSegments.first == 'shorts')) {
        return uri.pathSegments[1];
      }
    }
    return null;
  }
}

/// Record of a community member who listened to another member's concentration
/// or relaxation music (`community_profiles/{targetUid}/musicListeners/{uid}`).
class MusicListenerRecord {
  const MusicListenerRecord({
    required this.userId,
    required this.userName,
    this.nickname = '',
    this.photoUrl,
    this.musicUrl = '',
    this.listenCount = 1,
    required this.listenedAt,
  });

  final String userId;
  final String userName;
  final String nickname;
  final String? photoUrl;
  final String musicUrl;
  final int listenCount;
  final DateTime listenedAt;

  String get initials {
    final clean = userName.replaceFirst('@', '').trim();
    if (clean.isEmpty) return 'M';
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        if (nickname.trim().isNotEmpty) 'nickname': nickname.trim(),
        if (photoUrl != null && photoUrl!.trim().isNotEmpty)
          'photoUrl': photoUrl!.trim(),
        if (musicUrl.trim().isNotEmpty) 'musicUrl': musicUrl.trim(),
        'listenCount': listenCount,
        'listenedAt': listenedAt.toIso8601String(),
      };

  factory MusicListenerRecord.fromJson(
    Map<String, dynamic> json, {
    String? fallbackUid,
  }) {
    DateTime parsedAt = DateTime.now();
    final rawTs = json['listenedAt'];
    if (rawTs is String) {
      parsedAt = DateTime.tryParse(rawTs) ?? parsedAt;
    } else if (rawTs != null) {
      try {
        // Supports Firestore Timestamp via dynamic .toDate() without importing cloud_firestore.
        parsedAt = (rawTs as dynamic).toDate() as DateTime;
      } catch (_) {}
    }

    return MusicListenerRecord(
      userId: (json['userId'] as String?) ?? fallbackUid ?? '',
      userName: (json['userName'] as String?) ?? 'Member',
      nickname: (json['nickname'] as String?) ?? '',
      photoUrl: json['photoUrl'] as String?,
      musicUrl: (json['musicUrl'] as String?) ?? '',
      listenCount: (json['listenCount'] as num?)?.toInt() ?? 1,
      listenedAt: parsedAt,
    );
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
    this.chronicConditions = const [],
    this.customChronicCondition = '',
    this.showChronicConditions = true,
    this.currentMusicUrl = '',
    this.currentMusicTitle = '',
    this.musicLikedBy = const [],
    this.showSocials = true,
    this.instagram = '',
    this.twitterX = '',
    this.tiktok = '',
    this.facebook = '',
    this.snapchat = '',
    this.bio = '',
    this.motto = '',
    this.showMotto = true,
    this.dailyFocus = '',
    this.hideRealName = false,
    this.hidePhoto = false,
    this.showBio = true,
    this.showSobrietyOnProfile = true,
    this.smokeQuitAt,
    this.alcoholQuitAt,
    this.dailySmokeCostTry = 75.0,
    this.dailyCigarettesCount = 20,
    this.dailyAlcoholCostTry = 120.0,
    this.showStepsOnProfile = true,
    this.todayStepsCount = 0,
    this.weekStepsCount = 0,
    this.monthStepsCount = 0,
    this.dailyStepGoal = 10000,
    this.discoverable = true,
    this.allowMessages = true,
    this.requireMessageApproval = true,
    this.onlyFriendsCanMessage = false,
    this.isOnline = false,
    this.showOnlineStatus = true,
    this.lastActiveAt,
    this.isVerified = false,
    this.isSuspended = false,
    this.suspensionReason = '',
    this.hasAppealed = false,
    this.appealText,
    this.appealTimestamp,
    this.mood,
    this.streakDays = 1,
    this.birthMonth,
    this.birthDay,
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
  final List<ChronicCondition> chronicConditions;
  final String customChronicCondition;
  final bool showChronicConditions;
  final String currentMusicUrl;
  final String currentMusicTitle;
  final List<String> musicLikedBy;
  final bool showSocials;
  final String instagram;
  final String twitterX;
  final String tiktok;
  final String facebook;
  final String snapchat;
  final String bio;
  final String motto;
  final bool showMotto;
  final String dailyFocus;
  final bool hideRealName;
  final bool hidePhoto;
  final bool showBio;
  final bool showSobrietyOnProfile;
  final DateTime? smokeQuitAt;
  final DateTime? alcoholQuitAt;
  final double dailySmokeCostTry;
  final int dailyCigarettesCount;
  final double dailyAlcoholCostTry;
  final bool showStepsOnProfile;
  final int todayStepsCount;
  final int weekStepsCount;
  final int monthStepsCount;
  final int dailyStepGoal;
  final bool discoverable;
  final bool allowMessages;
  final bool requireMessageApproval;
  final bool onlyFriendsCanMessage;
  final bool isOnline;
  final bool showOnlineStatus;
  final DateTime? lastActiveAt;
  final bool isVerified;
  final bool isSuspended;
  final String suspensionReason;
  final bool hasAppealed;
  final String? appealText;
  final DateTime? appealTimestamp;
  final HealthMood? mood;
  final int streakDays;
  final int? birthMonth;
  final int? birthDay;
  final List<String> likedBy;
  final bool isSampleProfile;
  final DateTime updatedAt;

  int get likesCount => likedBy.length;

  /// Automatically computes wellness & engagement badges for this member.
  List<HealthAchievementBadge> get computedBadges {
    final badges = <HealthAchievementBadge>[];
    if (isVerified) badges.add(HealthAchievementBadge.verifiedMember);
    if (streakDays >= 30) {
      badges.add(HealthAchievementBadge.streak30);
    } else if (streakDays >= 7) {
      badges.add(HealthAchievementBadge.streak7);
    }
    if (likesCount >= 3) badges.add(HealthAchievementBadge.communityHelper);
    if (hasAnyChronicCondition) badges.add(HealthAchievementBadge.chronicWarrior);
    if (hasMusic) badges.add(HealthAchievementBadge.musicLover);
    return badges;
  }

  bool isLikedBy(String userId) => userId.isNotEmpty && likedBy.contains(userId);

  int get musicLikesCount => musicLikedBy.length;

  bool isMusicLikedBy(String userId) =>
      userId.isNotEmpty && musicLikedBy.contains(userId);

  bool get hasMusic => currentMusicUrl.trim().isNotEmpty;

  Map<String, String> get allSocialHandles => {
        if (instagram.trim().isNotEmpty) 'instagram': instagram.trim(),
        if (twitterX.trim().isNotEmpty) 'x': twitterX.trim(),
        if (tiktok.trim().isNotEmpty) 'tiktok': tiktok.trim(),
        if (facebook.trim().isNotEmpty) 'facebook': facebook.trim(),
        if (snapchat.trim().isNotEmpty) 'snapchat': snapchat.trim(),
      };

  Map<String, String> get visibleSocialHandles =>
      showSocials ? allSocialHandles : const {};

  bool get hasAnySocial => allSocialHandles.isNotEmpty;

  bool get hasAnyChronicCondition =>
      chronicConditions.isNotEmpty || customChronicCondition.trim().isNotEmpty;

  /// True when the member allows online presence AND is active right now
  /// (explicit online flag or active within the last 10 minutes).
  bool isVisibleOnlineAt(DateTime now) {
    if (!showOnlineStatus) return false;
    if (isOnline) return true;
    if (lastActiveAt != null && now.difference(lastActiveAt!).inMinutes <= 10) {
      return true;
    }
    return false;
  }

  bool get isVisibleOnline => isVisibleOnlineAt(DateTime.now());

  /// Returns true if this member's birthday matches today's month and day.
  bool isBirthdayTodayAt(DateTime now) {
    if (birthMonth == null || birthDay == null) return false;
    return birthMonth == now.month && birthDay == now.day;
  }

  bool get isBirthdayToday => isBirthdayTodayAt(DateTime.now());

  /// Returns true if this profile shares at least one chronic condition
  /// (selected enum or normalized custom entry) with [other].
  bool sharesConditionWith(HealthCommunityProfile other) {
    if (!showChronicConditions || !other.showChronicConditions) return false;
    for (final c in chronicConditions) {
      if (other.chronicConditions.contains(c)) return true;
    }
    final mine = customChronicCondition.trim().toLowerCase();
    final theirs = other.customChronicCondition.trim().toLowerCase();
    if (mine.isNotEmpty && theirs.isNotEmpty) {
      return mine == theirs || mine.contains(theirs) || theirs.contains(mine);
    }
    return false;
  }

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
    List<ChronicCondition>? chronicConditions,
    String? customChronicCondition,
    bool? showChronicConditions,
    String? currentMusicUrl,
    String? currentMusicTitle,
    List<String>? musicLikedBy,
    bool? showSocials,
    String? instagram,
    String? twitterX,
    String? tiktok,
    String? facebook,
    String? snapchat,
    String? bio,
    String? motto,
    bool? showMotto,
    String? dailyFocus,
    bool? hideRealName,
    bool? hidePhoto,
    bool? showBio,
    bool? showSobrietyOnProfile,
    DateTime? smokeQuitAt,
    bool clearSmokeQuitAt = false,
    DateTime? alcoholQuitAt,
    bool clearAlcoholQuitAt = false,
    double? dailySmokeCostTry,
    int? dailyCigarettesCount,
    double? dailyAlcoholCostTry,
    bool? showStepsOnProfile,
    int? todayStepsCount,
    int? weekStepsCount,
    int? monthStepsCount,
    int? dailyStepGoal,
    bool? discoverable,
    bool? allowMessages,
    bool? requireMessageApproval,
    bool? onlyFriendsCanMessage,
    bool? isOnline,
    bool? showOnlineStatus,
    DateTime? lastActiveAt,
    bool? isVerified,
    bool? isSuspended,
    String? suspensionReason,
    bool? hasAppealed,
    String? appealText,
    DateTime? appealTimestamp,
    HealthMood? mood,
    bool clearMood = false,
    int? streakDays,
    int? birthMonth,
    int? birthDay,
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
      chronicConditions: chronicConditions ?? this.chronicConditions,
      customChronicCondition:
          customChronicCondition ?? this.customChronicCondition,
      showChronicConditions:
          showChronicConditions ?? this.showChronicConditions,
      currentMusicUrl: currentMusicUrl ?? this.currentMusicUrl,
      currentMusicTitle: currentMusicTitle ?? this.currentMusicTitle,
      musicLikedBy: musicLikedBy ?? this.musicLikedBy,
      showSocials: showSocials ?? this.showSocials,
      instagram: instagram ?? this.instagram,
      twitterX: twitterX ?? this.twitterX,
      tiktok: tiktok ?? this.tiktok,
      facebook: facebook ?? this.facebook,
      snapchat: snapchat ?? this.snapchat,
      bio: bio ?? this.bio,
      motto: motto ?? this.motto,
      showMotto: showMotto ?? this.showMotto,
      dailyFocus: dailyFocus ?? this.dailyFocus,
      hideRealName: hideRealName ?? this.hideRealName,
      hidePhoto: hidePhoto ?? this.hidePhoto,
      showBio: showBio ?? this.showBio,
      showSobrietyOnProfile:
          showSobrietyOnProfile ?? this.showSobrietyOnProfile,
      smokeQuitAt:
          clearSmokeQuitAt ? null : (smokeQuitAt ?? this.smokeQuitAt),
      alcoholQuitAt:
          clearAlcoholQuitAt ? null : (alcoholQuitAt ?? this.alcoholQuitAt),
      dailySmokeCostTry: dailySmokeCostTry ?? this.dailySmokeCostTry,
      dailyCigarettesCount: dailyCigarettesCount ?? this.dailyCigarettesCount,
      dailyAlcoholCostTry: dailyAlcoholCostTry ?? this.dailyAlcoholCostTry,
      showStepsOnProfile: showStepsOnProfile ?? this.showStepsOnProfile,
      todayStepsCount: todayStepsCount ?? this.todayStepsCount,
      weekStepsCount: weekStepsCount ?? this.weekStepsCount,
      monthStepsCount: monthStepsCount ?? this.monthStepsCount,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      discoverable: discoverable ?? this.discoverable,
      allowMessages: allowMessages ?? this.allowMessages,
      requireMessageApproval:
          requireMessageApproval ?? this.requireMessageApproval,
      onlyFriendsCanMessage:
          onlyFriendsCanMessage ?? this.onlyFriendsCanMessage,
      isOnline: isOnline ?? this.isOnline,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isVerified: isVerified ?? this.isVerified,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      hasAppealed: hasAppealed ?? this.hasAppealed,
      appealText: appealText ?? this.appealText,
      appealTimestamp: appealTimestamp ?? this.appealTimestamp,
      mood: clearMood ? null : (mood ?? this.mood),
      streakDays: streakDays ?? this.streakDays,
      birthMonth: birthMonth ?? this.birthMonth,
      birthDay: birthDay ?? this.birthDay,
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
      'chronicConditions': chronicConditions.map((c) => c.id).toList(),
      if (customChronicCondition.trim().isNotEmpty)
        'customChronicCondition': customChronicCondition.trim(),
      'showChronicConditions': showChronicConditions,
      if (currentMusicUrl.trim().isNotEmpty)
        'currentMusicUrl': currentMusicUrl.trim(),
      if (currentMusicTitle.trim().isNotEmpty)
        'currentMusicTitle': currentMusicTitle.trim(),
      'musicLikedBy': musicLikedBy,
      'musicLikesCount': musicLikedBy.length,
      'showSocials': showSocials,
      if (instagram.trim().isNotEmpty) 'instagram': instagram.trim(),
      if (twitterX.trim().isNotEmpty) 'twitterX': twitterX.trim(),
      if (tiktok.trim().isNotEmpty) 'tiktok': tiktok.trim(),
      if (facebook.trim().isNotEmpty) 'facebook': facebook.trim(),
      if (snapchat.trim().isNotEmpty) 'snapchat': snapchat.trim(),
      'bio': bio.trim(),
      'motto': motto.trim(),
      'showMotto': showMotto,
      'dailyFocus': dailyFocus.trim(),
      'hideRealName': hideRealName,
      'hidePhoto': hidePhoto,
      'showBio': showBio,
      'showSobrietyOnProfile': showSobrietyOnProfile,
      'smokeQuitAt': smokeQuitAt?.toIso8601String() ?? '',
      'alcoholQuitAt': alcoholQuitAt?.toIso8601String() ?? '',
      'dailySmokeCostTry': dailySmokeCostTry,
      'dailyCigarettesCount': dailyCigarettesCount,
      'dailyAlcoholCostTry': dailyAlcoholCostTry,
      'showStepsOnProfile': showStepsOnProfile,
      'todayStepsCount': todayStepsCount,
      'weekStepsCount': weekStepsCount,
      'monthStepsCount': monthStepsCount,
      'dailyStepGoal': dailyStepGoal,
      'discoverable': discoverable,
      'allowMessages': allowMessages,
      'requireMessageApproval': requireMessageApproval,
      'onlyFriendsCanMessage': onlyFriendsCanMessage,
      'isOnline': isOnline,
      'showOnlineStatus': showOnlineStatus,
      if (lastActiveAt != null) 'lastActiveAt': lastActiveAt!.toIso8601String(),
      'isVerified': isVerified,
      'isSuspended': isSuspended,
      if (suspensionReason.trim().isNotEmpty)
        'suspensionReason': suspensionReason.trim(),
      'hasAppealed': hasAppealed,
      if (appealText != null && appealText!.trim().isNotEmpty)
        'appealText': appealText!.trim(),
      if (appealTimestamp != null)
        'appealTimestamp': appealTimestamp!.toIso8601String(),
      if (mood != null) 'mood': mood!.id,
      'streakDays': streakDays,
      if (birthMonth != null) 'birthMonth': birthMonth,
      if (birthDay != null) 'birthDay': birthDay,
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

    final rawConditions = (json['chronicConditions'] as List<dynamic>?)
            ?.map((e) => ChronicConditionX.fromId(e?.toString()))
            .whereType<ChronicCondition>()
            .toList() ??
        const <ChronicCondition>[];

    final rawLikedBy = (json['likedBy'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];

    final rawMusicLikedBy = (json['musicLikedBy'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];

    DateTime parsedUpdated = DateTime.now();
    final rawUpdated = json['updatedAt'];
    if (rawUpdated is String) {
      parsedUpdated = DateTime.tryParse(rawUpdated) ?? parsedUpdated;
    }

    DateTime? parsedLastActive;
    final rawLastActive = json['lastActiveAt'];
    if (rawLastActive is String) {
      parsedLastActive = DateTime.tryParse(rawLastActive);
    }

    DateTime? parseOptDate(dynamic raw) {
      if (raw is String && raw.trim().isNotEmpty) {
        return DateTime.tryParse(raw.trim());
      }
      return null;
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
      chronicConditions: rawConditions,
      customChronicCondition:
          (json['customChronicCondition'] as String?) ?? '',
      showChronicConditions: (json['showChronicConditions'] as bool?) ?? true,
      currentMusicUrl: (json['currentMusicUrl'] as String?) ?? '',
      currentMusicTitle: (json['currentMusicTitle'] as String?) ?? '',
      musicLikedBy: rawMusicLikedBy,
      showSocials: (json['showSocials'] as bool?) ?? true,
      instagram: (json['instagram'] as String?) ?? '',
      twitterX: (json['twitterX'] as String?) ?? '',
      tiktok: (json['tiktok'] as String?) ?? '',
      facebook: (json['facebook'] as String?) ?? '',
      snapchat: (json['snapchat'] as String?) ?? '',
      bio: (json['bio'] as String?) ?? '',
      motto: (json['motto'] as String?) ?? '',
      showMotto: (json['showMotto'] as bool?) ?? true,
      dailyFocus: (json['dailyFocus'] as String?) ?? '',
      hideRealName: (json['hideRealName'] as bool?) ?? false,
      hidePhoto: (json['hidePhoto'] as bool?) ?? false,
      showBio: (json['showBio'] as bool?) ?? true,
      showSobrietyOnProfile: (json['showSobrietyOnProfile'] as bool?) ?? true,
      smokeQuitAt: parseOptDate(json['smokeQuitAt']),
      alcoholQuitAt: parseOptDate(json['alcoholQuitAt']),
      dailySmokeCostTry:
          (json['dailySmokeCostTry'] as num?)?.toDouble() ?? 75.0,
      dailyCigarettesCount:
          (json['dailyCigarettesCount'] as num?)?.toInt() ?? 20,
      dailyAlcoholCostTry:
          (json['dailyAlcoholCostTry'] as num?)?.toDouble() ?? 120.0,
      showStepsOnProfile: (json['showStepsOnProfile'] as bool?) ?? true,
      todayStepsCount: (json['todayStepsCount'] as num?)?.toInt() ?? 0,
      weekStepsCount: (json['weekStepsCount'] as num?)?.toInt() ?? 0,
      monthStepsCount: (json['monthStepsCount'] as num?)?.toInt() ?? 0,
      dailyStepGoal: (json['dailyStepGoal'] as num?)?.toInt() ?? 10000,
      discoverable: (json['discoverable'] as bool?) ?? true,
      allowMessages: (json['allowMessages'] as bool?) ?? true,
      requireMessageApproval:
          (json['requireMessageApproval'] as bool?) ?? true,
      onlyFriendsCanMessage:
          (json['onlyFriendsCanMessage'] as bool?) ?? false,
      isOnline: (json['isOnline'] as bool?) ?? false,
      showOnlineStatus: (json['showOnlineStatus'] as bool?) ?? true,
      lastActiveAt: parsedLastActive,
      isVerified: (json['isVerified'] as bool?) ?? false,
      isSuspended: (json['isSuspended'] as bool?) ?? false,
      suspensionReason: (json['suspensionReason'] as String?) ?? '',
      hasAppealed: (json['hasAppealed'] as bool?) ?? false,
      appealText: json['appealText'] as String?,
      appealTimestamp: DateTime.tryParse((json['appealTimestamp'] as String?) ?? ''),
      mood: HealthMoodX.fromId(json['mood'] as String?),
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 1,
      birthMonth: (json['birthMonth'] as num?)?.toInt(),
      birthDay: (json['birthDay'] as num?)?.toInt(),
      likedBy: rawLikedBy,
      isSampleProfile: (json['isSampleProfile'] as bool?) ?? false,
      updatedAt: parsedUpdated,
    );
  }
}

/// Curated inspiring mottos for healthy living that users can pick or customize.
class HealthyLivingMottos {
  HealthyLivingMottos._();

  static const List<String> presets = [
    'Bedenin ömür boyu yaşayacağın tek evindir; ona en iyi şekilde bak. 🌿',
    'Bugün attığın her küçük adım, yarının güçlü nefesidir. 🚶‍♂️✨',
    'Sağlık bir hedef değil, her gün sevgiyle seçtiğin bir yaşam biçimidir. 💚',
    'İyi uyku, temiz su, hareket ve huzur: En güçlü dört ilaç. 💧☀️',
    'Yarının enerjisi, bugün kendine gösterdiğin özende saklı. ⚡',
    'Mükemmel olmak zorunda değilsin; dün olduğundan %1 daha sağlıklı ol yeter. 🌱',
    'Derin bir nefes al; temiz bir beden berrak bir zihin demektir. 🌬️🧘',
    'Alışkanlıklarını iyileştir, alışkanlıkların da hayatını iyileştirsin. 🏆',
    'Her yeni sabah, bedeninle yeniden barışmak için taze bir başlangıçtır. 🌅',
    'Kendine yaptığın en kârlı yatırım, sağlığına ayırdığın zamandır. 💎',
    'Zararlı alışkanlıkları geride bırak, özgür ve zinde bir ömre kucak aç. 🕊️',
    'Hareket berekettir; adımların seni en dinç haline taşısın. 🏃‍♀️🔥',
  ];
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
  friendsOnly,
  requestDeclined,
  unsafeContent,
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

/// Mutual health friendship state (`community_friendships/{pairId}`).
enum FriendshipStatus {
  pending,
  accepted,
  declined,
}

extension FriendshipStatusX on FriendshipStatus {
  static FriendshipStatus fromId(String? value) {
    for (final s in FriendshipStatus.values) {
      if (s.name == value) return s;
    }
    return FriendshipStatus.pending;
  }
}

/// Mutual health-buddy friendship link between two community members.
class FriendshipRecord {
  const FriendshipRecord({
    required this.pairId,
    required this.members,
    required this.requesterId,
    required this.status,
    this.displayNames = const {},
    required this.updatedAt,
  });

  final String pairId;
  final List<String> members;
  final String requesterId;
  final FriendshipStatus status;
  final Map<String, String> displayNames;
  final DateTime updatedAt;

  static String pairIdFor(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return ids.join('_');
  }

  String peerIdFor(String myUid) =>
      members.firstWhere((id) => id != myUid, orElse: () => '');

  String peerNameFor(String myUid) {
    final peer = peerIdFor(myUid);
    return displayNames[peer] ?? 'Member';
  }

  bool isIncomingPendingFor(String myUid) =>
      status == FriendshipStatus.pending && requesterId != myUid;

  bool isOutgoingPendingFor(String myUid) =>
      status == FriendshipStatus.pending && requesterId == myUid;

  FriendshipRecord copyWith({
    FriendshipStatus? status,
    Map<String, String>? displayNames,
    DateTime? updatedAt,
  }) {
    return FriendshipRecord(
      pairId: pairId,
      members: members,
      requesterId: requesterId,
      status: status ?? this.status,
      displayNames: displayNames ?? this.displayNames,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'pairId': pairId,
        'members': members,
        'requesterId': requesterId,
        'status': status.name,
        'displayNames': displayNames,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory FriendshipRecord.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    final rawNames = <String, String>{};
    if (json['displayNames'] is Map) {
      (json['displayNames'] as Map).forEach((k, v) {
        if (k is String && v != null) rawNames[k] = v.toString();
      });
    }
    return FriendshipRecord(
      pairId: (json['pairId'] as String?) ?? fallbackId ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      requesterId: (json['requesterId'] as String?) ?? '',
      status: FriendshipStatusX.fromId(json['status'] as String?),
      displayNames: rawNames,
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
