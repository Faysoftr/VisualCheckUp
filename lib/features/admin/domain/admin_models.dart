import 'package:flutter/material.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';

/// Role & authorization helper for VisualCheckUp Admin Control Panel.
class AdminUtils {
  AdminUtils._();

  static const String adminEmail = 'f.s.yuksek@gmail.com';

  static bool isAdmin({
    String? email,
    String? uid,
    Map<String, dynamic>? userData,
  }) {
    if (email != null && email.trim().toLowerCase() == adminEmail) return true;
    if (userData != null) {
      final userEmail = userData['email']?.toString().trim().toLowerCase();
      if (userEmail == adminEmail) return true;
      if (userData['isAdmin'] == true || userData['role'] == 'admin') {
        return true;
      }
    }
    return false;
  }
}

/// Visual tone for global announcements broadcast by admins.
enum AnnouncementType {
  info,
  healthTip,
  warning,
  campaign,
}

extension AnnouncementTypeX on AnnouncementType {
  static AnnouncementType fromId(String? value) {
    for (final t in AnnouncementType.values) {
      if (t.name == value) return t;
    }
    return AnnouncementType.info;
  }

  IconData get icon {
    switch (this) {
      case AnnouncementType.info:
        return Icons.campaign_rounded;
      case AnnouncementType.healthTip:
        return Icons.health_and_safety_rounded;
      case AnnouncementType.warning:
        return Icons.warning_amber_rounded;
      case AnnouncementType.campaign:
        return Icons.auto_awesome_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case AnnouncementType.info:
        return const Color(0xFF0B6E6E);
      case AnnouncementType.healthTip:
        return const Color(0xFF16A34A);
      case AnnouncementType.warning:
        return const Color(0xFFD97706);
      case AnnouncementType.campaign:
        return const Color(0xFF7C3AED);
    }
  }

  String get defaultEmoji {
    switch (this) {
      case AnnouncementType.info:
        return '📢';
      case AnnouncementType.healthTip:
        return '💚';
      case AnnouncementType.warning:
        return '⚠️';
      case AnnouncementType.campaign:
        return '🎉';
    }
  }
}

/// Curated health & celebration icon option for announcements (Social Formula Bank style).
class AnnouncementIconOption {
  const AnnouncementIconOption({
    required this.id,
    required this.emoji,
    required this.accentColor,
  });

  final String id;
  final String emoji;
  final Color accentColor;
}

class AnnouncementIcons {
  AnnouncementIcons._();

  static const List<AnnouncementIconOption> all = [
    AnnouncementIconOption(id: 'heart', emoji: '❤️', accentColor: Color(0xFFE11D48)),
    AnnouncementIconOption(id: 'confetti', emoji: '🎉', accentColor: Color(0xFFEC4899)),
    AnnouncementIconOption(id: 'doctor', emoji: '🩺', accentColor: Color(0xFF0284C7)),
    AnnouncementIconOption(id: 'pill', emoji: '💊', accentColor: Color(0xFF7C3AED)),
    AnnouncementIconOption(id: 'water', emoji: '💧', accentColor: Color(0xFF06B6D4)),
    AnnouncementIconOption(id: 'nutrition', emoji: '🥗', accentColor: Color(0xFF16A34A)),
    AnnouncementIconOption(id: 'fitness', emoji: '🏃', accentColor: Color(0xFFF59E0B)),
    AnnouncementIconOption(id: 'sleep', emoji: '😴', accentColor: Color(0xFF6366F1)),
    AnnouncementIconOption(id: 'mind', emoji: '🧠', accentColor: Color(0xFF8B5CF6)),
    AnnouncementIconOption(id: 'herbal', emoji: '🌿', accentColor: Color(0xFF10B981)),
    AnnouncementIconOption(id: 'megaphone', emoji: '📢', accentColor: Color(0xFF0B6E6E)),
    AnnouncementIconOption(id: 'sparkle', emoji: '✨', accentColor: Color(0xFFD97706)),
  ];

  static Color accentFor(String emoji, Color fallback) {
    final trimmed = emoji.trim();
    for (final opt in all) {
      if (opt.emoji == trimmed) return opt.accentColor;
    }
    return fallback;
  }
}

/// Global announcement banner published from the VisualCheckUp Admin Panel.
class GlobalAnnouncement {
  const GlobalAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    this.type = AnnouncementType.info,
    this.iconEmoji = '',
    this.linkUrl = '',
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final AnnouncementType type;
  final String iconEmoji;
  final String linkUrl;
  final bool isActive;
  final DateTime createdAt;

  String get effectiveEmoji =>
      iconEmoji.trim().isNotEmpty ? iconEmoji.trim() : type.defaultEmoji;

  Color get effectiveAccentColor =>
      AnnouncementIcons.accentFor(effectiveEmoji, type.accentColor);

  GlobalAnnouncement copyWith({
    String? title,
    String? message,
    AnnouncementType? type,
    String? iconEmoji,
    String? linkUrl,
    bool? isActive,
  }) {
    return GlobalAnnouncement(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      linkUrl: linkUrl ?? this.linkUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title.trim(),
        'message': message.trim(),
        'type': type.name,
        if (iconEmoji.trim().isNotEmpty) 'iconEmoji': iconEmoji.trim(),
        if (linkUrl.trim().isNotEmpty) 'linkUrl': linkUrl.trim(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GlobalAnnouncement.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return GlobalAnnouncement(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      title: (json['title'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      type: AnnouncementTypeX.fromId(json['type'] as String?),
      iconEmoji: (json['iconEmoji'] as String?) ?? '',
      linkUrl: (json['linkUrl'] as String?) ?? '',
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Placement slots where promotional cards / ads can be displayed.
enum PromotionPlacement {
  homeTop,
  communityTop,
  profileTop,
}

extension PromotionPlacementX on PromotionPlacement {
  static PromotionPlacement fromId(String? value) {
    for (final p in PromotionPlacement.values) {
      if (p.name == value) return p;
    }
    return PromotionPlacement.homeTop;
  }
}

enum PromotionFormat {
  banner,
  featuredCard,
  adMobBanner,
  adMobNative,
}

extension PromotionFormatX on PromotionFormat {
  static PromotionFormat fromId(String? value) {
    for (final f in PromotionFormat.values) {
      if (f.name == value) return f;
    }
    return PromotionFormat.banner;
  }
}

/// Managed promotion / advertisement item controlled from Admin Panel.
class HealthPromotion {
  const HealthPromotion({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.placement = PromotionPlacement.homeTop,
    this.format = PromotionFormat.banner,
    this.imageUrl,
    this.imageKey,
    this.linkUrl = '',
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final PromotionPlacement placement;
  final PromotionFormat format;
  final String? imageUrl;
  final String? imageKey;
  final String linkUrl;
  final bool isActive;
  final DateTime createdAt;

  HealthPromotion copyWith({
    String? title,
    String? subtitle,
    PromotionPlacement? placement,
    PromotionFormat? format,
    String? imageUrl,
    String? imageKey,
    String? linkUrl,
    bool? isActive,
  }) {
    return HealthPromotion(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      placement: placement ?? this.placement,
      format: format ?? this.format,
      imageUrl: imageUrl ?? this.imageUrl,
      imageKey: imageKey ?? this.imageKey,
      linkUrl: linkUrl ?? this.linkUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title.trim(),
        'subtitle': subtitle.trim(),
        'placement': placement.name,
        'format': format.name,
        if (imageUrl != null && imageUrl!.trim().isNotEmpty)
          'imageUrl': imageUrl!.trim(),
        if (imageKey != null && imageKey!.trim().isNotEmpty)
          'imageKey': imageKey!.trim(),
        if (linkUrl.trim().isNotEmpty) 'linkUrl': linkUrl.trim(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HealthPromotion.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return HealthPromotion(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      placement: PromotionPlacementX.fromId(json['placement'] as String?),
      format: PromotionFormatX.fromId(json['format'] as String?),
      imageUrl: json['imageUrl'] as String?,
      imageKey: json['imageKey'] as String?,
      linkUrl: (json['linkUrl'] as String?) ?? '',
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Moderation report submitted against a community profile or chat message.
class AdminReportItem {
  const AdminReportItem({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.note = '',
    this.status = 'pending',
    required this.createdAt,
  });

  final String id;
  final String reporterId;
  final String targetType;
  final String targetId;
  final String reason;
  final String note;
  final String status;
  final DateTime createdAt;

  AdminReportItem copyWith({String? status}) {
    return AdminReportItem(
      id: id,
      reporterId: reporterId,
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      note: note,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reporterId': reporterId,
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        'note': note,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AdminReportItem.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return AdminReportItem(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      reporterId: (json['reporterId'] as String?) ?? '',
      targetType: (json['targetType'] as String?) ?? 'profile',
      targetId: (json['targetId'] as String?) ?? '',
      reason: (json['reason'] as String?) ?? 'other',
      note: (json['note'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Live overview KPIs computed for the VisualCheckUp Admin Dashboard.
class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalMembers,
    required this.onlineMembers,
    required this.discoverableMembers,
    required this.suspendedMembers,
    required this.totalLikes,
    required this.totalConversations,
    required this.pendingReports,
    required this.activeAnnouncements,
    required this.activePromotions,
    required this.conditionCounts,
  });

  final int totalMembers;
  final int onlineMembers;
  final int discoverableMembers;
  final int suspendedMembers;
  final int totalLikes;
  final int totalConversations;
  final int pendingReports;
  final int activeAnnouncements;
  final int activePromotions;
  final Map<ChronicCondition, int> conditionCounts;
}
