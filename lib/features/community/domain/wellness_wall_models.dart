import 'package:visualcheckup/features/community/domain/health_community_models.dart';

/// Community Wellness Experience & Q&A Post (`wellness_posts/{postId}`).
class WellnessWallPost {
  const WellnessWallPost({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorCountryCode = 'TR',
    this.isAuthorDoctor = false,
    this.condition,
    required this.title,
    required this.body,
    this.likedBy = const [],
    this.commentCount = 0,
    this.hasDoctorReply = false,
    required this.createdAt,
  });

  final String id;
  final String authorUid;
  final String authorName;
  final String authorCountryCode;
  final bool isAuthorDoctor;
  final ChronicCondition? condition;
  final String title;
  final String body;
  final List<String> likedBy;
  final int commentCount;
  final bool hasDoctorReply;
  final DateTime createdAt;

  int get likesCount => likedBy.length;
  bool isLikedBy(String uid) => uid.isNotEmpty && likedBy.contains(uid);
  CommunityCountryOption get country =>
      CommunityCountryOption.byCode(authorCountryCode);

  WellnessWallPost copyWith({
    List<String>? likedBy,
    int? commentCount,
    bool? hasDoctorReply,
  }) {
    return WellnessWallPost(
      id: id,
      authorUid: authorUid,
      authorName: authorName,
      authorCountryCode: authorCountryCode,
      isAuthorDoctor: isAuthorDoctor,
      condition: condition,
      title: title,
      body: body,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
      hasDoctorReply: hasDoctorReply ?? this.hasDoctorReply,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorUid': authorUid,
        'authorName': authorName.trim(),
        'authorCountryCode': authorCountryCode.toUpperCase(),
        'isAuthorDoctor': isAuthorDoctor,
        if (condition != null) 'condition': condition!.id,
        'title': title.trim(),
        'body': body.trim(),
        'likedBy': likedBy,
        'commentCount': commentCount,
        'hasDoctorReply': hasDoctorReply,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WellnessWallPost.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return WellnessWallPost(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      authorUid: (json['authorUid'] as String?) ?? '',
      authorName: (json['authorName'] as String?) ?? '',
      authorCountryCode: (json['authorCountryCode'] as String?) ?? 'TR',
      isAuthorDoctor: (json['isAuthorDoctor'] as bool?) ?? false,
      condition: ChronicConditionX.fromId(json['condition'] as String?),
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      likedBy: (json['likedBy'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      hasDoctorReply: (json['hasDoctorReply'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Comment / reply on a [WellnessWallPost] (`wellness_posts/{postId}/comments`).
/// Verified Doctor replies are highlighted and pinned at the top!
class WellnessWallComment {
  const WellnessWallComment({
    required this.id,
    required this.postId,
    required this.authorUid,
    required this.authorName,
    this.isVerifiedDoctor = false,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String authorUid;
  final String authorName;
  final bool isVerifiedDoctor;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'authorUid': authorUid,
        'authorName': authorName.trim(),
        'isVerifiedDoctor': isVerifiedDoctor,
        'text': text.trim(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory WellnessWallComment.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return WellnessWallComment(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      postId: (json['postId'] as String?) ?? '',
      authorUid: (json['authorUid'] as String?) ?? '',
      authorName: (json['authorName'] as String?) ?? '',
      isVerifiedDoctor: (json['isVerifiedDoctor'] as bool?) ?? false,
      text: (json['text'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
