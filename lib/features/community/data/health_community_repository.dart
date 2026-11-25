import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';

/// Repository powering VisualCheckUp's opt-in Global Health Community:
/// - Opt-in health profiles (`community_profiles/{uid}`) — strictly separated
///   from private medical data (`users/{uid}`).
/// - Profile likes, worldwide discovery filters (health goal, country,
///   language, search).
/// - 1-on-1 messaging with optional uploaded image attachments, message request
///   approval, rate-limiting, muting, hiding, and per-message deletion.
/// - Two-way user blocking (`community_safety/{uid}`) and UGC reporting
///   (`community_reports/{reportId}`).
///
/// Works seamlessly with live Cloud Firestore when signed in via Firebase Auth
/// and automatically falls back to local SharedPreferences storage + curated
/// global wellness starter profiles when offline or in guest/test mode.
class HealthCommunityRepository {
  HealthCommunityRepository({
    this.useFirebase = true,
    this.rateLimitSeconds = 3,
    this.dailyMessageLimit = 100,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final bool useFirebase;
  final int rateLimitSeconds;
  final int dailyMessageLimit;
  final DateTime Function() _clock;

  static const String _profilesKey = 'visualcheckup_comm_profiles_v1';
  static const String _blocksKeyPrefix = 'visualcheckup_comm_blocks_v1_';
  static const String _convosKey = 'visualcheckup_comm_convos_v1';
  static const String _messagesKeyPrefix = 'visualcheckup_comm_msgs_v1_';
  static const String _reportsKey = 'visualcheckup_comm_reports_v1';
  static const String _rateKeyPrefix = 'visualcheckup_comm_rate_v1_';

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

  /// Curated global sample wellness profiles so users exploring the community
  /// immediately experience worldwide health goals, languages, and peer support.
  static List<HealthCommunityProfile> starterGlobalProfiles() {
    final baseTime = DateTime(2026, 11, 20, 10, 0);
    return [
      HealthCommunityProfile(
        uid: 'sample_tr_ayse',
        displayName: 'Ayşe Demir',
        nickname: 'ayse_saglik',
        countryCode: 'TR',
        city: 'İzmir',
        languageCode: 'tr',
        healthGoals: const [
          HealthGoalTag.diabetes,
          HealthGoalTag.herbalWellness,
          HealthGoalTag.fitnessWalk,
        ],
        bio:
            'Tip 2 diyabet sürecinde dengeli beslenme ve günlük 8.000 adım hedefiyle ilerliyorum. Motivasyon paylaşmak isterim.',
        dailyFocus: 'Sabah yürüyüşü + şekersiz bitki çayı',
        likedBy: const ['u_demo_1', 'u_demo_2', 'u_demo_3', 'u_demo_4'],
        isSampleProfile: true,
        updatedAt: baseTime,
      ),
      HealthCommunityProfile(
        uid: 'sample_de_lukas',
        displayName: 'Lukas Weber',
        nickname: 'lukas_heart',
        countryCode: 'DE',
        city: 'München',
        languageCode: 'en',
        healthGoals: const [
          HealthGoalTag.bloodPressure,
          HealthGoalTag.weightDiet,
          HealthGoalTag.sleepStress,
        ],
        bio:
            'Tracking daily blood pressure and Mediterranean meals. Always happy to exchange low-sodium recipe ideas!',
        dailyFocus: 'DASH diet + evening stretching',
        likedBy: const ['u_demo_1', 'u_demo_5', 'u_demo_6'],
        isSampleProfile: true,
        updatedAt: baseTime.subtract(const Duration(hours: 2)),
      ),
      HealthCommunityProfile(
        uid: 'sample_tr_mehmet',
        displayName: 'Mehmet Yılmaz',
        nickname: 'mehmet_tansiyon',
        countryCode: 'TR',
        city: 'Ankara',
        languageCode: 'tr',
        healthGoals: const [
          HealthGoalTag.bloodPressure,
          HealthGoalTag.healthyLiving,
        ],
        bio:
            'Tansiyon takibimi düzenli yapıyorum, tuzu azalttım ve her akşam yürüyüşe çıkıyorum.',
        dailyFocus: 'Akşam 45 dk tempolu yürüyüş',
        likedBy: const ['u_demo_2', 'u_demo_3'],
        isSampleProfile: true,
        updatedAt: baseTime.subtract(const Duration(hours: 4)),
      ),
      HealthCommunityProfile(
        uid: 'sample_es_elena',
        displayName: 'Elena Ruiz',
        nickname: 'elena_bienestar',
        countryCode: 'ES',
        city: 'Valencia',
        languageCode: 'es',
        healthGoals: const [
          HealthGoalTag.parentingGrowth,
          HealthGoalTag.weightDiet,
          HealthGoalTag.healthyLiving,
        ],
        bio:
            'Mamá siguiendo el crecimiento saludable de mis hijos y recetas mediterráneas equilibradas.',
        dailyFocus: 'Comida casera y hidratación',
        likedBy: const ['u_demo_1', 'u_demo_2', 'u_demo_7', 'u_demo_8', 'u_demo_9'],
        isSampleProfile: true,
        updatedAt: baseTime.subtract(const Duration(hours: 6)),
      ),
      HealthCommunityProfile(
        uid: 'sample_sa_noura',
        displayName: 'Noura Al-Harbi',
        nickname: 'noura_wellness',
        countryCode: 'SA',
        city: 'Riyadh',
        languageCode: 'ar',
        healthGoals: const [
          HealthGoalTag.herbalWellness,
          HealthGoalTag.skinCare,
          HealthGoalTag.sleepStress,
        ],
        bio:
            'أشارك عادات النوم الصحي وشاي الأعشاب والروتين اليومي للعناية بالصحة العامة.',
        dailyFocus: 'شرب 2 لتر ماء يومياً',
        likedBy: const ['u_demo_4', 'u_demo_5'],
        isSampleProfile: true,
        updatedAt: baseTime.subtract(const Duration(hours: 8)),
      ),
      HealthCommunityProfile(
        uid: 'sample_us_sarah',
        displayName: 'Sarah Mitchell',
        nickname: 'sarah_active',
        countryCode: 'US',
        city: 'Seattle',
        languageCode: 'en',
        healthGoals: const [
          HealthGoalTag.weightDiet,
          HealthGoalTag.fitnessWalk,
          HealthGoalTag.diabetes,
        ],
        bio:
            'Focused on steady blood sugar habits, high-protein breakfasts, and daily walking streaks.',
        dailyFocus: '10,000 steps + balanced plate',
        likedBy: const ['u_demo_1', 'u_demo_3', 'u_demo_8'],
        isSampleProfile: true,
        updatedAt: baseTime.subtract(const Duration(hours: 10)),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Local Storage Helpers
  // ---------------------------------------------------------------------------

  Future<Map<String, HealthCommunityProfile>> _loadLocalProfileMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilesKey);
    final map = <String, HealthCommunityProfile>{};
    for (final sample in starterGlobalProfiles()) {
      map[sample.uid] = sample;
    }
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final p = HealthCommunityProfile.fromJson(item);
            if (p.uid.isNotEmpty) map[p.uid] = p;
          }
        }
      } catch (_) {
        // Ignore corrupted cache gracefully.
      }
    }
    return map;
  }

  Future<void> _saveLocalProfileMap(
    Map<String, HealthCommunityProfile> map,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      map.values.map((p) => p.toJson()..['isSampleProfile'] = p.isSampleProfile).toList(),
    );
    await prefs.setString(_profilesKey, encoded);
  }

  Future<List<CommunityConversation>> _loadLocalConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_convosKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(CommunityConversation.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalConversations(List<CommunityConversation> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _convosKey,
      jsonEncode(list.map((c) => c.toJson()).toList()),
    );
  }

  Future<List<CommunityChatMessage>> _loadLocalMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_messagesKeyPrefix$chatId');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(CommunityChatMessage.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalMessages(
    String chatId,
    List<CommunityChatMessage> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_messagesKeyPrefix$chatId',
      jsonEncode(messages.map((m) => m.toJson()).toList()),
    );
  }

  // ---------------------------------------------------------------------------
  // Opt-In Profile CRUD & Discovery
  // ---------------------------------------------------------------------------

  Future<HealthCommunityProfile?> loadMyProfile(String uid) async {
    if (uid.trim().isEmpty) return null;
    if (_canUseFirestore) {
      try {
        final doc = await _db.collection('community_profiles').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final profile = HealthCommunityProfile.fromJson(
            doc.data()!,
            fallbackUid: doc.id,
          );
          final local = await _loadLocalProfileMap();
          local[uid] = profile;
          await _saveLocalProfileMap(local);
          return profile;
        }
      } catch (_) {
        // Fall back to local cache.
      }
    }
    final local = await _loadLocalProfileMap();
    final candidate = local[uid];
    if (candidate == null || candidate.isSampleProfile) return null;
    return candidate;
  }

  Future<HealthCommunityProfile> saveMyProfile(
    HealthCommunityProfile profile,
  ) async {
    final updated = profile.copyWith(
      nickname: HealthCommunityProfile.sanitizeNickname(profile.nickname),
      updatedAt: _clock(),
      isSampleProfile: false,
    );

    final local = await _loadLocalProfileMap();
    local[updated.uid] = updated;
    await _saveLocalProfileMap(local);

    if (_canUseFirestore) {
      try {
        await _db
            .collection('community_profiles')
            .doc(updated.uid)
            .set(updated.toJson(), SetOptions(merge: true));
      } catch (_) {
        // Keep local copy even if offline.
      }
    }
    return updated;
  }

  Future<void> leaveCommunity(String uid) async {
    if (uid.trim().isEmpty) return;
    final local = await _loadLocalProfileMap();
    local.remove(uid);
    await _saveLocalProfileMap(local);

    if (_canUseFirestore) {
      try {
        await _db.collection('community_profiles').doc(uid).delete();
      } catch (_) {
        // Ignore offline delete errors.
      }
    }
  }

  Future<HealthCommunityProfile?> getProfile(String uid) async {
    if (uid.trim().isEmpty) return null;
    if (_canUseFirestore) {
      try {
        final doc = await _db.collection('community_profiles').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          return HealthCommunityProfile.fromJson(
            doc.data()!,
            fallbackUid: doc.id,
          );
        }
      } catch (_) {
        // Fallback below.
      }
    }
    final local = await _loadLocalProfileMap();
    return local[uid];
  }

  Future<List<HealthCommunityProfile>> discoverProfiles({
    required String myUid,
    HealthGoalTag? goalFilter,
    String? countryCodeFilter,
    String? languageCodeFilter,
    String searchQuery = '',
  }) async {
    final blocked = await loadBlockedUsers(myUid);
    final merged = await _loadLocalProfileMap();

    if (_canUseFirestore) {
      try {
        final snap = await _db
            .collection('community_profiles')
            .where('discoverable', isEqualTo: true)
            .limit(80)
            .get();
        for (final doc in snap.docs) {
          final p = HealthCommunityProfile.fromJson(
            doc.data(),
            fallbackUid: doc.id,
          );
          merged[p.uid] = p;
        }
      } catch (_) {
        // Fallback to local/starter profiles gracefully.
      }
    }

    final q = searchQuery.trim().toLowerCase();
    final results = merged.values.where((p) {
      if (p.uid == myUid) return false;
      if (!p.discoverable) return false;
      if (blocked.contains(p.uid)) return false;

      if (goalFilter != null && !p.healthGoals.contains(goalFilter)) {
        return false;
      }
      if (countryCodeFilter != null &&
          countryCodeFilter.isNotEmpty &&
          countryCodeFilter != 'ALL' &&
          p.countryCode.toUpperCase() != countryCodeFilter.toUpperCase()) {
        return false;
      }
      if (languageCodeFilter != null &&
          languageCodeFilter.isNotEmpty &&
          languageCodeFilter != 'ALL' &&
          p.languageCode.toLowerCase() != languageCodeFilter.toLowerCase()) {
        return false;
      }
      if (q.isNotEmpty) {
        final haystack = [
          p.visibleName,
          p.nickname,
          p.city,
          p.country.label,
          p.bio,
          p.dailyFocus,
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();

    results.sort((a, b) {
      final likeCmp = b.likesCount.compareTo(a.likesCount);
      if (likeCmp != 0) return likeCmp;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return results;
  }

  // ---------------------------------------------------------------------------
  // Profile Likes
  // ---------------------------------------------------------------------------

  Future<HealthCommunityProfile?> toggleProfileLike({
    required String targetUid,
    required String myUid,
  }) async {
    if (targetUid.isEmpty || myUid.isEmpty || targetUid == myUid) return null;

    final local = await _loadLocalProfileMap();
    final existing = local[targetUid] ?? await getProfile(targetUid);
    if (existing == null) return null;

    final alreadyLiked = existing.isLikedBy(myUid);
    final updatedLikedBy = List<String>.from(existing.likedBy);
    if (alreadyLiked) {
      updatedLikedBy.remove(myUid);
    } else {
      updatedLikedBy.add(myUid);
    }

    final updated = existing.copyWith(likedBy: updatedLikedBy);
    local[targetUid] = updated;
    await _saveLocalProfileMap(local);

    if (_canUseFirestore && !existing.isSampleProfile) {
      try {
        await _db.collection('community_profiles').doc(targetUid).update({
          'likedBy': alreadyLiked
              ? FieldValue.arrayRemove([myUid])
              : FieldValue.arrayUnion([myUid]),
          'likesCount': FieldValue.increment(alreadyLiked ? -1 : 1),
        });
      } catch (_) {
        // Optimistic local state preserved.
      }
    }

    return updated;
  }

  // ---------------------------------------------------------------------------
  // Blocking & Reporting (App Store / Google Play UGC Compliance)
  // ---------------------------------------------------------------------------

  Future<Set<String>> loadBlockedUsers(String myUid) async {
    if (myUid.isEmpty) return <String>{};
    final prefs = await SharedPreferences.getInstance();
    final localList =
        prefs.getStringList('$_blocksKeyPrefix$myUid') ?? const <String>[];
    final result = localList.toSet();

    if (_canUseFirestore) {
      try {
        final doc = await _db.collection('community_safety').doc(myUid).get();
        final remote = (doc.data()?['blockedUsers'] as List<dynamic>?)
                ?.whereType<String>() ??
            const <String>[];
        result.addAll(remote);
      } catch (_) {
        // Keep local set.
      }
    }
    return result;
  }

  Future<void> blockUser({
    required String myUid,
    required String targetUid,
  }) async {
    if (myUid.isEmpty || targetUid.isEmpty || myUid == targetUid) return;
    final prefs = await SharedPreferences.getInstance();
    final blocks = await loadBlockedUsers(myUid);
    blocks.add(targetUid);
    await prefs.setStringList('$_blocksKeyPrefix$myUid', blocks.toList());

    if (_canUseFirestore) {
      try {
        await _db.collection('community_safety').doc(myUid).set({
          'blockedUsers': FieldValue.arrayUnion([targetUid]),
          'updatedAt': _clock().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Ignore offline failure.
      }
    }
  }

  Future<void> unblockUser({
    required String myUid,
    required String targetUid,
  }) async {
    if (myUid.isEmpty || targetUid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final blocks = await loadBlockedUsers(myUid);
    blocks.remove(targetUid);
    await prefs.setStringList('$_blocksKeyPrefix$myUid', blocks.toList());

    if (_canUseFirestore) {
      try {
        await _db.collection('community_safety').doc(myUid).set({
          'blockedUsers': FieldValue.arrayRemove([targetUid]),
          'updatedAt': _clock().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Ignore offline failure.
      }
    }
  }

  Future<void> submitReport({
    required String reporterUid,
    required String targetType,
    required String targetId,
    required CommunityReportReason reason,
    String note = '',
  }) async {
    if (reporterUid.isEmpty || targetId.isEmpty) return;
    final payload = {
      'reporterId': reporterUid,
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason.name,
      'note': note.trim(),
      'createdAt': _clock().toIso8601String(),
      'status': 'pending',
    };

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_reportsKey) ?? <String>[];
    existing.add(jsonEncode(payload));
    await prefs.setStringList(_reportsKey, existing);

    if (_canUseFirestore) {
      try {
        await _db.collection('community_reports').add(payload);
      } catch (_) {
        // Stored locally for resilience.
      }
    }
  }

  Future<int> loadSubmittedReportCount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_reportsKey) ?? const []).length;
  }

  // ---------------------------------------------------------------------------
  // 1-on-1 Conversations & Messaging (with Approval + Image Attachments)
  // ---------------------------------------------------------------------------

  Future<List<CommunityConversation>> loadConversations(String myUid) async {
    if (myUid.isEmpty) return const [];
    final blocked = await loadBlockedUsers(myUid);
    final byId = <String, CommunityConversation>{};

    for (final c in await _loadLocalConversations()) {
      if (c.members.contains(myUid)) {
        byId[c.chatId] = c;
      }
    }

    if (_canUseFirestore) {
      try {
        final snap = await _db
            .collection('community_conversations')
            .where('members', arrayContains: myUid)
            .get();
        for (final doc in snap.docs) {
          final c = CommunityConversation.fromJson(
            doc.data()..['chatId'] = doc.id,
          );
          byId[c.chatId] = c;
        }
      } catch (_) {
        // Keep local conversations.
      }
    }

    final visible = byId.values.where((c) {
      if (c.isHiddenFor(myUid)) return false;
      final peer = c.peerIdFor(myUid);
      if (peer.isEmpty || blocked.contains(peer)) return false;
      if (c.status == ConversationRequestStatus.declined &&
          c.requesterId != myUid) {
        return false;
      }
      return true;
    }).toList();

    visible.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return visible;
  }

  Future<CommunityConversation?> loadConversation(String chatId) async {
    if (chatId.isEmpty) return null;
    if (_canUseFirestore) {
      try {
        final doc = await _db
            .collection('community_conversations')
            .doc(chatId)
            .get();
        if (doc.exists && doc.data() != null) {
          return CommunityConversation.fromJson(
            doc.data()!..['chatId'] = doc.id,
          );
        }
      } catch (_) {
        // Fallback below.
      }
    }
    final list = await _loadLocalConversations();
    for (final c in list) {
      if (c.chatId == chatId) return c;
    }
    return null;
  }

  Future<List<CommunityChatMessage>> loadMessages(
    String chatId, {
    required String myUid,
  }) async {
    if (chatId.isEmpty) return const [];
    final byId = <String, CommunityChatMessage>{};

    for (final m in await _loadLocalMessages(chatId)) {
      byId[m.id] = m;
    }

    if (_canUseFirestore) {
      try {
        final snap = await _db
            .collection('community_conversations')
            .doc(chatId)
            .collection('messages')
            .orderBy('sentAt', descending: false)
            .limitToLast(100)
            .get();
        for (final doc in snap.docs) {
          final m = CommunityChatMessage.fromJson(
            doc.data(),
            fallbackId: doc.id,
          );
          byId[m.id] = m;
        }
      } catch (_) {
        // Fallback to local messages.
      }
    }

    final list = byId.values.where((m) => !m.isHiddenFor(myUid)).toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return list;
  }

  Future<SendMessageStatus> sendMessage({
    required String senderUid,
    required String senderDisplayName,
    String? senderPhotoUrl,
    required HealthCommunityProfile receiver,
    String text = '',
    String? imageUrl,
    String? imageKey,
    String imagePreviewFallbackLabel = '📷 Photo',
  }) async {
    final trimmedText = text.trim();
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    if (trimmedText.isEmpty && !hasImage) {
      return SendMessageStatus.emptyContent;
    }
    if (senderUid.isEmpty || receiver.uid.isEmpty || senderUid == receiver.uid) {
      return SendMessageStatus.error;
    }

    // 1. Two-way block check
    final myBlocks = await loadBlockedUsers(senderUid);
    if (myBlocks.contains(receiver.uid)) {
      return SendMessageStatus.blocked;
    }
    final receiverBlocks = await loadBlockedUsers(receiver.uid);
    if (receiverBlocks.contains(senderUid)) {
      return SendMessageStatus.blocked;
    }

    // 2. Allow-messages privacy check
    final myProfile = await loadMyProfile(senderUid);
    if (myProfile != null && !myProfile.allowMessages) {
      return SendMessageStatus.senderDisabledMessages;
    }
    if (!receiver.allowMessages) {
      return SendMessageStatus.receiverDisabledMessages;
    }

    // 3. Anti-spam cooldown + daily quota check (adapted from Social Formül Bank)
    final now = _clock();
    final prefs = await SharedPreferences.getInstance();
    final rateKey = '$_rateKeyPrefix$senderUid';
    final rawRate = prefs.getString(rateKey);
    int sentToday = 0;
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (rawRate != null && rawRate.isNotEmpty) {
      try {
        final rateMap = jsonDecode(rawRate) as Map<String, dynamic>;
        final lastMs = (rateMap['lastMs'] as num?)?.toInt() ?? 0;
        final lastDate = (rateMap['date'] as String?) ?? '';
        sentToday = lastDate == todayKey
            ? ((rateMap['count'] as num?)?.toInt() ?? 0)
            : 0;
        if (rateLimitSeconds > 0 &&
            now.millisecondsSinceEpoch - lastMs < rateLimitSeconds * 1000) {
          return SendMessageStatus.rateLimited;
        }
        if (sentToday >= dailyMessageLimit) {
          return SendMessageStatus.dailyLimitExceeded;
        }
      } catch (_) {
        // Ignore malformed rate state.
      }
    }

    final chatId = CommunityConversation.chatIdFor(senderUid, receiver.uid);
    final existingConvo = await loadConversation(chatId);
    if (existingConvo != null &&
        existingConvo.status == ConversationRequestStatus.declined) {
      return SendMessageStatus.requestDeclined;
    }

    final status = existingConvo != null
        ? (existingConvo.requesterId != senderUid &&
                existingConvo.status == ConversationRequestStatus.pending
            ? ConversationRequestStatus.accepted
            : existingConvo.status)
        : (receiver.requireMessageApproval
            ? ConversationRequestStatus.pending
            : ConversationRequestStatus.accepted);

    final messageId = 'msg_${now.microsecondsSinceEpoch}';
    final message = CommunityChatMessage(
      id: messageId,
      senderId: senderUid,
      receiverId: receiver.uid,
      text: trimmedText,
      imageUrl: hasImage ? imageUrl.trim() : null,
      imageKey: hasImage ? imageKey?.trim() : null,
      sentAt: now,
      isRead: false,
    );

    final summaryPreview = trimmedText.isNotEmpty
        ? trimmedText
        : imagePreviewFallbackLabel;

    final members = [senderUid, receiver.uid]..sort();
    final updatedConvo = CommunityConversation(
      chatId: chatId,
      members: members,
      requesterId: existingConvo?.requesterId ?? senderUid,
      status: status,
      lastMessage: summaryPreview,
      lastSenderId: senderUid,
      lastMessageAt: now,
      displayNames: {
        senderUid: myProfile?.visibleName ?? senderDisplayName,
        receiver.uid: receiver.visibleName,
      },
      photoUrls: {
        senderUid: myProfile?.visiblePhotoUrl ?? senderPhotoUrl ?? '',
        receiver.uid: receiver.visiblePhotoUrl ?? '',
      },
      readBy: {
        senderUid: true,
        receiver.uid: false,
      },
      mutedBy: existingConvo?.mutedBy ?? const [],
      deletedFor: const [],
    );

    // Save locally first
    final localMsgs = await _loadLocalMessages(chatId);
    localMsgs.add(message);
    await _saveLocalMessages(chatId, localMsgs);

    final localConvos = await _loadLocalConversations();
    localConvos.removeWhere((c) => c.chatId == chatId);
    localConvos.insert(0, updatedConvo);
    await _saveLocalConversations(localConvos);

    await prefs.setString(
      rateKey,
      jsonEncode({
        'lastMs': now.millisecondsSinceEpoch,
        'date': todayKey,
        'count': sentToday + 1,
      }),
    );

    if (_canUseFirestore && !receiver.isSampleProfile) {
      try {
        final convoRef = _db.collection('community_conversations').doc(chatId);
        final msgRef = convoRef.collection('messages').doc(messageId);
        final batch = _db.batch();
        batch.set(convoRef, updatedConvo.toJson(), SetOptions(merge: true));
        batch.set(msgRef, message.toJson());
        await batch.commit();
      } catch (_) {
        // Local persistence already completed.
      }
    }

    return SendMessageStatus.sent;
  }

  Future<void> respondToMessageRequest({
    required String chatId,
    required bool accept,
  }) async {
    final newStatus = accept
        ? ConversationRequestStatus.accepted
        : ConversationRequestStatus.declined;

    final convos = await _loadLocalConversations();
    final idx = convos.indexWhere((c) => c.chatId == chatId);
    if (idx != -1) {
      convos[idx] = convos[idx].copyWith(status: newStatus);
      await _saveLocalConversations(convos);
    }

    if (_canUseFirestore) {
      try {
        await _db
            .collection('community_conversations')
            .doc(chatId)
            .update({'status': newStatus.name});
      } catch (_) {
        // Ignore offline errors.
      }
    }
  }

  Future<void> markConversationRead({
    required String chatId,
    required String myUid,
  }) async {
    final convos = await _loadLocalConversations();
    final idx = convos.indexWhere((c) => c.chatId == chatId);
    if (idx != -1) {
      final updatedReadBy = Map<String, bool>.from(convos[idx].readBy);
      updatedReadBy[myUid] = true;
      convos[idx] = convos[idx].copyWith(readBy: updatedReadBy);
      await _saveLocalConversations(convos);
    }

    final msgs = await _loadLocalMessages(chatId);
    bool changed = false;
    final updatedMsgs = msgs.map((m) {
      if (m.receiverId == myUid && !m.isRead) {
        changed = true;
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();
    if (changed) {
      await _saveLocalMessages(chatId, updatedMsgs);
    }

    if (_canUseFirestore) {
      try {
        await _db.collection('community_conversations').doc(chatId).update({
          'readBy.$myUid': true,
        });
      } catch (_) {
        // Ignore offline errors.
      }
    }
  }

  Future<void> toggleMuteConversation({
    required String chatId,
    required String myUid,
    required bool muted,
  }) async {
    final convos = await _loadLocalConversations();
    final idx = convos.indexWhere((c) => c.chatId == chatId);
    if (idx != -1) {
      final mutedBy = List<String>.from(convos[idx].mutedBy);
      if (muted) {
        if (!mutedBy.contains(myUid)) mutedBy.add(myUid);
      } else {
        mutedBy.remove(myUid);
      }
      convos[idx] = convos[idx].copyWith(mutedBy: mutedBy);
      await _saveLocalConversations(convos);
    }

    if (_canUseFirestore) {
      try {
        await _db.collection('community_conversations').doc(chatId).update({
          'mutedBy': muted
              ? FieldValue.arrayUnion([myUid])
              : FieldValue.arrayRemove([myUid]),
        });
      } catch (_) {
        // Ignore offline errors.
      }
    }
  }

  Future<void> hideConversationForMe({
    required String chatId,
    required String myUid,
  }) async {
    final convos = await _loadLocalConversations();
    final idx = convos.indexWhere((c) => c.chatId == chatId);
    if (idx != -1) {
      final deletedFor = List<String>.from(convos[idx].deletedFor);
      if (!deletedFor.contains(myUid)) deletedFor.add(myUid);
      convos[idx] = convos[idx].copyWith(deletedFor: deletedFor);
      await _saveLocalConversations(convos);
    }

    if (_canUseFirestore) {
      try {
        await _db.collection('community_conversations').doc(chatId).update({
          'deletedFor': FieldValue.arrayUnion([myUid]),
          'readBy.$myUid': true,
        });
      } catch (_) {
        // Ignore offline errors.
      }
    }
  }

  Future<void> deleteMessageForMe({
    required String chatId,
    required String messageId,
    required String myUid,
  }) async {
    final msgs = await _loadLocalMessages(chatId);
    final updated = msgs.map((m) {
      if (m.id == messageId) {
        final hidden = List<String>.from(m.deletedFor);
        if (!hidden.contains(myUid)) hidden.add(myUid);
        return m.copyWith(deletedFor: hidden);
      }
      return m;
    }).toList();
    await _saveLocalMessages(chatId, updated);

    if (_canUseFirestore) {
      try {
        await _db
            .collection('community_conversations')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .update({'deletedFor': FieldValue.arrayUnion([myUid])});
      } catch (_) {
        // Ignore offline errors.
      }
    }
  }

  Future<void> deleteMessageForEveryone({
    required String chatId,
    required String messageId,
  }) async {
    final msgs = await _loadLocalMessages(chatId);
    msgs.removeWhere((m) => m.id == messageId);
    await _saveLocalMessages(chatId, msgs);

    if (_canUseFirestore) {
      try {
        await _db
            .collection('community_conversations')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .delete();
      } catch (_) {
        // Ignore offline errors.
      }
    }
  }
}
