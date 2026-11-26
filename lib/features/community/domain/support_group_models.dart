import 'package:flutter/material.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';

/// Health & Chronic Condition Support Group (`support_groups/{groupId}`).
class HealthSupportGroup {
  const HealthSupportGroup({
    required this.id,
    required this.name,
    required this.description,
    this.condition,
    this.countryCode = 'GLOBAL',
    this.languageCode = 'tr',
    required this.creatorUid,
    required this.creatorName,
    this.memberUids = const [],
    this.isSampleGroup = false,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final ChronicCondition? condition;
  final String countryCode;
  final String languageCode;
  final String creatorUid;
  final String creatorName;
  final List<String> memberUids;
  final bool isSampleGroup;
  final DateTime createdAt;

  int get memberCount => memberUids.length;
  bool isMember(String uid) => uid.isNotEmpty && memberUids.contains(uid);
  CommunityCountryOption get country => CommunityCountryOption.byCode(countryCode);

  Color get accentColor =>
      condition?.accentColor ?? const Color(0xFF0B6E6E);

  IconData get icon => condition?.icon ?? Icons.groups_rounded;

  HealthSupportGroup copyWith({
    List<String>? memberUids,
  }) {
    return HealthSupportGroup(
      id: id,
      name: name,
      description: description,
      condition: condition,
      countryCode: countryCode,
      languageCode: languageCode,
      creatorUid: creatorUid,
      creatorName: creatorName,
      memberUids: memberUids ?? this.memberUids,
      isSampleGroup: isSampleGroup,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.trim(),
        'description': description.trim(),
        if (condition != null) 'condition': condition!.id,
        'countryCode': countryCode.toUpperCase(),
        'languageCode': languageCode.toLowerCase(),
        'creatorUid': creatorUid,
        'creatorName': creatorName.trim(),
        'memberUids': memberUids,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HealthSupportGroup.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return HealthSupportGroup(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      condition: ChronicConditionX.fromId(json['condition'] as String?),
      countryCode: (json['countryCode'] as String?) ?? 'GLOBAL',
      languageCode: (json['languageCode'] as String?) ?? 'en',
      creatorUid: (json['creatorUid'] as String?) ?? '',
      creatorName: (json['creatorName'] as String?) ?? '',
      memberUids: (json['memberUids'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      isSampleGroup: (json['isSampleGroup'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Message posted inside a [HealthSupportGroup] chat room
/// (`support_groups/{groupId}/messages/{messageId}`).
class SupportGroupMessage {
  const SupportGroupMessage({
    required this.id,
    required this.groupId,
    required this.senderUid,
    required this.senderName,
    this.isVerifiedDoctor = false,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String groupId;
  final String senderUid;
  final String senderName;
  final bool isVerifiedDoctor;
  final String text;
  final DateTime sentAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'senderUid': senderUid,
        'senderName': senderName.trim(),
        'isVerifiedDoctor': isVerifiedDoctor,
        'text': text.trim(),
        'sentAt': sentAt.toIso8601String(),
      };

  factory SupportGroupMessage.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return SupportGroupMessage(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      groupId: (json['groupId'] as String?) ?? '',
      senderUid: (json['senderUid'] as String?) ?? '',
      senderName: (json['senderName'] as String?) ?? '',
      isVerifiedDoctor: (json['isVerifiedDoctor'] as bool?) ?? false,
      text: (json['text'] as String?) ?? '',
      sentAt: DateTime.tryParse((json['sentAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
