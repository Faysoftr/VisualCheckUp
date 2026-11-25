import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/safety/content_safety_service.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/domain/wellness_wall_models.dart';

/// Repository backing the Health Experience & Q&A Wall (`wellness_posts`).
class WellnessWallRepository {
  WellnessWallRepository({
    this.useFirebase = true,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final bool useFirebase;
  final DateTime Function() _clock;

  static const String _postsKey = 'visualcheckup_wellness_posts_v1';
  static const String _commentsKeyPrefix = 'visualcheckup_wellness_comments_v1_';

  bool get _canUseFirestore {
    if (!useFirebase) return false;
    try {
      return Firebase.apps.isNotEmpty &&
          fb.FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static List<WellnessWallPost> starterPosts() {
    final base = DateTime(2026, 11, 22, 11, 0);
    return [
      WellnessWallPost(
        id: 'post_seed_bp',
        authorUid: 'sample_tr_mehmet',
        authorName: 'Mehmet Yılmaz',
        authorCountryCode: 'TR',
        condition: ChronicCondition.hypertension,
        title: 'Evde tansiyon ölçerken kol yüksekliği ne kadar fark ediyor?',
        body:
            'Sabahları oturur pozisyonda 5 dakika dinlendikten sonra ölçüm yapıyorum, kolu kalp hizasında tutmak gerçekten sonucu daha istikrarlı hale getirdi.',
        likedBy: const ['sample_tr_ayse', 'sample_de_lukas'],
        commentCount: 1,
        hasDoctorReply: true,
        createdAt: base,
      ),
      WellnessWallPost(
        id: 'post_seed_diabetes',
        authorUid: 'sample_tr_ayse',
        authorName: 'Ayşe Demir',
        authorCountryCode: 'TR',
        condition: ChronicCondition.type2Diabetes,
        title: 'Akşam yemeğinden sonra 20 dakikalık yürüyüş deneyimi',
        body:
            'Yemekten 30 dakika sonra hafif tempolu yürüyüşe başladığımdan beri tokluk kan şekeri dalgalanmalarım belirgin şekilde azaldı.',
        likedBy: const ['sample_de_lukas', 'sample_es_elena', 'u_demo_1'],
        commentCount: 0,
        hasDoctorReply: false,
        createdAt: base.subtract(const Duration(hours: 5)),
      ),
    ];
  }

  Future<Map<String, WellnessWallPost>> _loadLocalPosts() async {
    final map = <String, WellnessWallPost>{
      for (final p in starterPosts()) p.id: p,
    };
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_postsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          if (entry.value is Map<String, dynamic>) {
            map[entry.key] = WellnessWallPost.fromJson(
              entry.value as Map<String, dynamic>,
              fallbackId: entry.key,
            );
          }
        }
      } catch (_) {}
    }
    return map;
  }

  Future<void> _saveLocalPosts(Map<String, WellnessWallPost> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _postsKey,
      jsonEncode({for (final e in map.entries) e.key: e.value.toJson()}),
    );
  }

  Future<List<WellnessWallPost>> loadPosts({
    ChronicCondition? conditionFilter,
  }) async {
    final merged = await _loadLocalPosts();
    if (_canUseFirestore) {
      try {
        final snap = await _db.collection('wellness_posts').limit(80).get();
        for (final doc in snap.docs) {
          final p = WellnessWallPost.fromJson(doc.data(), fallbackId: doc.id);
          merged[p.id] = p;
        }
      } catch (_) {}
    }
    final list = merged.values.where((p) {
      if (conditionFilter != null && p.condition != conditionFilter) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<WellnessWallPost?> createPost({
    required String authorUid,
    required String authorName,
    String authorCountryCode = 'TR',
    bool isAuthorDoctor = false,
    ChronicCondition? condition,
    required String title,
    required String body,
  }) async {
    final safety = ContentSafetyService.checkText('$title $body');
    if (!safety.isSafe) return null;

    final now = _clock();
    final post = WellnessWallPost(
      id: 'post_${now.microsecondsSinceEpoch}',
      authorUid: authorUid,
      authorName: authorName,
      authorCountryCode: authorCountryCode,
      isAuthorDoctor: isAuthorDoctor,
      condition: condition,
      title: title.trim(),
      body: body.trim(),
      createdAt: now,
    );

    final map = await _loadLocalPosts();
    map[post.id] = post;
    await _saveLocalPosts(map);

    if (_canUseFirestore) {
      try {
        await _db
            .collection('wellness_posts')
            .doc(post.id)
            .set(post.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
    return post;
  }

  Future<WellnessWallPost?> toggleLike({
    required String postId,
    required String uid,
  }) async {
    final map = await _loadLocalPosts();
    final existing = map[postId];
    if (existing == null) return null;

    final liked = existing.isLikedBy(uid);
    final nextLikes = List<String>.from(existing.likedBy);
    if (liked) {
      nextLikes.remove(uid);
    } else {
      nextLikes.add(uid);
    }
    final updated = existing.copyWith(likedBy: nextLikes);
    map[postId] = updated;
    await _saveLocalPosts(map);

    if (_canUseFirestore && !postId.startsWith('post_seed_')) {
      try {
        await _db.collection('wellness_posts').doc(postId).update({
          'likedBy': liked
              ? FieldValue.arrayRemove([uid])
              : FieldValue.arrayUnion([uid]),
        });
      } catch (_) {}
    }
    return updated;
  }

  Future<List<WellnessWallComment>> loadComments(String postId) async {
    final byId = <String, WellnessWallComment>{};
    if (postId == 'post_seed_bp') {
      byId['seed_doc_reply'] = WellnessWallComment(
        id: 'seed_doc_reply',
        postId: postId,
        authorUid: 'doc_tr_selim',
        authorName: 'Uzm. Dr. Selim Arslan',
        isVerifiedDoctor: true,
        text:
            'Doğru uygulama! Kolu kalp hizasında desteklemek ve ölçümden 30 dk önce kafein/sigara almamak en güvenilir sonucu verir. Düzenli ölçümlerinizi doktorunuzla paylaşmayı unutmayın.',
        createdAt: _clock().subtract(const Duration(hours: 2)),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_commentsKeyPrefix$postId');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final c = WellnessWallComment.fromJson(item);
            if (c.id.isNotEmpty) byId[c.id] = c;
          }
        }
      } catch (_) {}
    }

    if (_canUseFirestore) {
      try {
        final snap = await _db
            .collection('wellness_posts')
            .doc(postId)
            .collection('comments')
            .limit(100)
            .get();
        for (final doc in snap.docs) {
          final c = WellnessWallComment.fromJson(doc.data(), fallbackId: doc.id);
          byId[c.id] = c;
        }
      } catch (_) {}
    }

    // Verified doctor replies are pinned at the top!
    final list = byId.values.toList()
      ..sort((a, b) {
        if (a.isVerifiedDoctor && !b.isVerifiedDoctor) return -1;
        if (!a.isVerifiedDoctor && b.isVerifiedDoctor) return 1;
        return a.createdAt.compareTo(b.createdAt);
      });
    return list;
  }

  Future<WellnessWallComment?> addComment({
    required String postId,
    required String authorUid,
    required String authorName,
    required String text,
    bool isVerifiedDoctor = false,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final safety = ContentSafetyService.checkText(trimmed);
    if (!safety.isSafe) return null;

    final now = _clock();
    final comment = WellnessWallComment(
      id: 'cm_${now.microsecondsSinceEpoch}',
      postId: postId,
      authorUid: authorUid,
      authorName: authorName,
      isVerifiedDoctor: isVerifiedDoctor,
      text: trimmed,
      createdAt: now,
    );

    final existing = await loadComments(postId);
    final updatedComments = [...existing, comment];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_commentsKeyPrefix$postId',
      jsonEncode(updatedComments.map((e) => e.toJson()).toList()),
    );

    final posts = await _loadLocalPosts();
    final post = posts[postId];
    if (post != null) {
      posts[postId] = post.copyWith(
        commentCount: updatedComments.length,
        hasDoctorReply: post.hasDoctorReply || isVerifiedDoctor,
      );
      await _saveLocalPosts(posts);
    }

    if (_canUseFirestore && !postId.startsWith('post_seed_')) {
      try {
        await _db
            .collection('wellness_posts')
            .doc(postId)
            .collection('comments')
            .doc(comment.id)
            .set(comment.toJson());
        await _db.collection('wellness_posts').doc(postId).update({
          'commentCount': FieldValue.increment(1),
          if (isVerifiedDoctor) 'hasDoctorReply': true,
        });
      } catch (_) {}
    }
    return comment;
  }
}
