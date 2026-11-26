import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/safety/content_safety_service.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';
import 'package:visualcheckup/features/subscription/domain/subscription_models.dart';

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
    int? dailyMessageLimit,
    this.subscriptionRepository,
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now,
        _customDailyMessageLimit = dailyMessageLimit;

  final bool useFirebase;
  final int rateLimitSeconds;
  final int? _customDailyMessageLimit;
  final SubscriptionRepository? subscriptionRepository;
  final DateTime Function() _clock;

  int get dailyMessageLimit =>
      _customDailyMessageLimit ?? UserSubscriptionState.freeDailyMessageLimit;

  static const String _profilesKey = 'visualcheckup_comm_profiles_v1';
  static const String _blocksKeyPrefix = 'visualcheckup_comm_blocks_v1_';
  static const String _convosKey = 'visualcheckup_comm_convos_v1';
  static const String _messagesKeyPrefix = 'visualcheckup_comm_msgs_v1_';
  static const String _reportsKey = 'visualcheckup_comm_reports_v1';
  static const String _rateKeyPrefix = 'visualcheckup_comm_rate_v1_';
  static const String _musicListenersKeyPrefix =
      'visualcheckup_comm_music_listeners_v1_';

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
        chronicConditions: const [
          ChronicCondition.type2Diabetes,
          ChronicCondition.thyroidHashimoto,
        ],
        currentMusicUrl: 'https://www.youtube.com/watch?v=jfKfPfyJRdk',
        currentMusicTitle: 'Lofi & Doğa Sesleri — Sabah Yürüyüşü & Odak',
        musicLikedBy: const ['u_demo_1', 'u_demo_2', 'u_demo_3'],
        showSocials: true,
        instagram: 'ayse_saglikli_yasam',
        twitterX: 'ayse_saglik',
        bio:
            'Tip 2 diyabet sürecinde dengeli beslenme ve günlük 8.000 adım hedefiyle ilerliyorum. Motivasyon paylaşmak isterim.',
        dailyFocus: 'Sabah yürüyüşü + şekersiz bitki çayı',
        isOnline: true,
        showOnlineStatus: true,
        lastActiveAt: baseTime,
        birthMonth: DateTime.now().month,
        birthDay: DateTime.now().day,
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
        chronicConditions: const [
          ChronicCondition.hypertension,
          ChronicCondition.heartCondition,
        ],
        currentMusicUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
        currentMusicTitle: 'Deep Focus & Calm Breathing Playlist',
        musicLikedBy: const ['u_demo_1', 'u_demo_5'],
        showSocials: true,
        instagram: 'lukas_heart_health',
        bio:
            'Tracking daily blood pressure and Mediterranean meals. Always happy to exchange low-sodium recipe ideas!',
        dailyFocus: 'DASH diet + evening stretching',
        isOnline: true,
        showOnlineStatus: true,
        lastActiveAt: baseTime,
        birthMonth: DateTime.now().month,
        birthDay: DateTime.now().day,
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
        chronicConditions: const [
          ChronicCondition.hypertension,
          ChronicCondition.type2Diabetes,
        ],
        bio:
            'Tansiyon takibimi düzenli yapıyorum, tuzu azalttım ve her akşam yürüyüşe çıkıyorum.',
        dailyFocus: 'Akşam 45 dk tempolu yürüyüş',
        isOnline: false,
        showOnlineStatus: true,
        lastActiveAt: baseTime.subtract(const Duration(hours: 3)),
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
        chronicConditions: const [
          ChronicCondition.migraine,
          ChronicCondition.anemia,
        ],
        bio:
            'Mamá siguiendo el crecimiento saludable de mis hijos y recetas mediterráneas equilibradas.',
        dailyFocus: 'Comida casera y hidratación',
        isOnline: true,
        showOnlineStatus: true,
        lastActiveAt: baseTime,
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
        chronicConditions: const [
          ChronicCondition.eczemaPsoriasis,
          ChronicCondition.asthmaCopd,
        ],
        bio:
            'أشارك عادات النوم الصحي وشاي الأعشاب والروتين اليومي للعناية بالصحة العامة.',
        dailyFocus: 'شرب 2 لتر ماء يومياً',
        isOnline: false,
        showOnlineStatus: true,
        lastActiveAt: baseTime.subtract(const Duration(hours: 5)),
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
        chronicConditions: const [
          ChronicCondition.type1Diabetes,
          ChronicCondition.celiacIbs,
        ],
        bio:
            'Focused on steady blood sugar habits, high-protein breakfasts, and daily walking streaks.',
        dailyFocus: '10,000 steps + balanced plate',
        isOnline: true,
        showOnlineStatus: true,
        lastActiveAt: baseTime,
        likedBy: const ['u_demo_1', 'u_demo_3', 'u_demo_8'],
        isSampleProfile: true,
        updatedAt: baseTime.subtract(const Duration(hours: 10)),
      ),
    ];
  }

  /// Returns active community members whose birthday is today.
  static List<HealthCommunityProfile> getTodayBirthdayProfiles({
    List<HealthCommunityProfile>? source,
    DateTime? now,
  }) {
    final dt = now ?? DateTime.now();
    final list = source ?? starterGlobalProfiles();
    return list.where((p) => p.isBirthdayTodayAt(dt)).toList();
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

  Future<void> updateOnlinePresence(
    String uid, {
    required bool isOnline,
  }) async {
    if (uid.trim().isEmpty) return;
    final now = _clock();
    final local = await _loadLocalProfileMap();
    final existing = local[uid];
    if (existing != null && !existing.isSampleProfile) {
      local[uid] = existing.copyWith(
        isOnline: isOnline,
        lastActiveAt: now,
      );
      await _saveLocalProfileMap(local);
    }

    if (_canUseFirestore) {
      try {
        await _db.collection('community_profiles').doc(uid).update({
          'isOnline': isOnline,
          'lastActiveAt': now.toIso8601String(),
        });
      } catch (_) {
        // Ignore if user has not opted in yet or is offline.
      }
    }
  }

  Future<List<HealthCommunityProfile>> discoverProfiles({
    required String myUid,
    HealthGoalTag? goalFilter,
    ChronicCondition? conditionFilter,
    bool sameConditionAsMe = false,
    bool onlineOnly = false,
    String? countryCodeFilter,
    String? languageCodeFilter,
    String searchQuery = '',
  }) async {
    final blocked = await loadBlockedUsers(myUid);
    final merged = await _loadLocalProfileMap();
    final myProfile = await loadMyProfile(myUid);
    final now = _clock();

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
      if (!p.discoverable || p.isSuspended) return false;
      if (blocked.contains(p.uid)) return false;

      if (onlineOnly && !p.isVisibleOnlineAt(now)) {
        return false;
      }

      if (sameConditionAsMe) {
        if (myProfile == null || !myProfile.hasAnyChronicCondition) {
          return false;
        }
        if (!p.sharesConditionWith(myProfile)) {
          return false;
        }
      }

      if (conditionFilter != null) {
        if (!p.showChronicConditions ||
            !p.chronicConditions.contains(conditionFilter)) {
          return false;
        }
      }

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
          if (p.showChronicConditions) p.customChronicCondition,
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();

    results.sort((a, b) {
      if (onlineOnly) {
        final aOn = a.isVisibleOnlineAt(now) ? 1 : 0;
        final bOn = b.isVisibleOnlineAt(now) ? 1 : 0;
        if (aOn != bOn) return bOn.compareTo(aOn);
      }
      final likeCmp = b.likesCount.compareTo(a.likesCount);
      if (likeCmp != 0) return likeCmp;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return results;
  }

  /// Admin helper: returns all community profiles (including hidden/suspended).
  Future<List<HealthCommunityProfile>> loadAllProfilesForAdmin() async {
    final merged = await _loadLocalProfileMap();
    if (_canUseFirestore) {
      try {
        final snap =
            await _db.collection('community_profiles').limit(150).get();
        for (final doc in snap.docs) {
          final p = HealthCommunityProfile.fromJson(
            doc.data(),
            fallbackUid: doc.id,
          );
          merged[p.uid] = p;
        }
      } catch (_) {
        // Fallback to local profiles.
      }
    }
    final list = merged.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> setProfileSuspended(String uid, bool suspended) async {
    final local = await _loadLocalProfileMap();
    final existing = local[uid];
    if (existing != null) {
      local[uid] = existing.copyWith(isSuspended: suspended);
      await _saveLocalProfileMap(local);
    }
    if (_canUseFirestore && existing?.isSampleProfile != true) {
      try {
        await _db.collection('community_profiles').doc(uid).update({
          'isSuspended': suspended,
        });
      } catch (_) {}
    }
  }

  Future<void> setProfileVerified(String uid, bool verified) async {
    final local = await _loadLocalProfileMap();
    final existing = local[uid];
    if (existing != null) {
      local[uid] = existing.copyWith(isVerified: verified);
      await _saveLocalProfileMap(local);
    }
    if (_canUseFirestore && existing?.isSampleProfile != true) {
      try {
        await _db.collection('community_profiles').doc(uid).update({
          'isVerified': verified,
        });
      } catch (_) {}
    }
  }

  Future<void> deleteProfileByAdmin(String uid) async {
    final local = await _loadLocalProfileMap();
    local.remove(uid);
    await _saveLocalProfileMap(local);
    if (_canUseFirestore) {
      try {
        await _db.collection('community_profiles').doc(uid).delete();
      } catch (_) {}
    }
  }

  Future<int> loadTotalConversationCountForAdmin() async {
    final local = await _loadLocalConversations();
    var count = local.length;
    if (_canUseFirestore) {
      try {
        final snap =
            await _db.collection('community_conversations').limit(200).get();
        if (snap.docs.length > count) count = snap.docs.length;
      } catch (_) {}
    }
    return count;
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

  /// Toggles the current user's like on a profile's concentration music.
  Future<HealthCommunityProfile?> toggleMusicLike({
    required String targetUid,
    required String myUid,
  }) async {
    if (targetUid.isEmpty || myUid.isEmpty) return null;

    final local = await _loadLocalProfileMap();
    final existing = local[targetUid] ?? await getProfile(targetUid);
    if (existing == null) return null;

    final alreadyLiked = existing.isMusicLikedBy(myUid);
    final updatedLikedBy = List<String>.from(existing.musicLikedBy);
    if (alreadyLiked) {
      updatedLikedBy.remove(myUid);
    } else {
      updatedLikedBy.add(myUid);
    }

    final updated = existing.copyWith(musicLikedBy: updatedLikedBy);
    local[targetUid] = updated;
    await _saveLocalProfileMap(local);

    if (_canUseFirestore && !existing.isSampleProfile) {
      try {
        await _db.collection('community_profiles').doc(targetUid).update({
          'musicLikedBy': alreadyLiked
              ? FieldValue.arrayRemove([myUid])
              : FieldValue.arrayUnion([myUid]),
          'musicLikesCount': FieldValue.increment(alreadyLiked ? -1 : 1),
        });
      } catch (_) {}
    }
    return updated;
  }

  /// Quickly toggles whether a user's social media handles are publicly visible.
  Future<HealthCommunityProfile?> setShowSocials(
    String uid,
    bool showSocials,
  ) async {
    if (uid.isEmpty) return null;
    final local = await _loadLocalProfileMap();
    final existing = local[uid] ?? await loadMyProfile(uid);
    if (existing == null) return null;

    final updated = existing.copyWith(
      showSocials: showSocials,
      updatedAt: _clock(),
    );
    local[uid] = updated;
    await _saveLocalProfileMap(local);

    if (_canUseFirestore && !existing.isSampleProfile) {
      try {
        await _db.collection('community_profiles').doc(uid).update({
          'showSocials': showSocials,
          'updatedAt': updated.updatedAt.toIso8601String(),
        });
      } catch (_) {}
    }
    return updated;
  }

  // ---------------------------------------------------------------------------
  // Concentration Music Listeners (`community_profiles/{uid}/musicListeners`)
  // ---------------------------------------------------------------------------

  Future<List<MusicListenerRecord>> _loadLocalListeners(String targetUid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_musicListenersKeyPrefix$targetUid');
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(MusicListenerRecord.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveLocalListeners(
    String targetUid,
    List<MusicListenerRecord> list,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_musicListenersKeyPrefix$targetUid',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<MusicListenerRecord>> loadMusicListeners(String targetUid) async {
    if (targetUid.isEmpty) return const [];
    final byUser = <String, MusicListenerRecord>{};

    // Seed sample listeners for curated starter profiles so demo cards feel alive.
    if (targetUid == 'sample_tr_ayse') {
      final t = _clock();
      byUser['sample_tr_mehmet'] = MusicListenerRecord(
        userId: 'sample_tr_mehmet',
        userName: 'Mehmet Yılmaz',
        nickname: 'mehmet_tansiyon',
        musicUrl: 'https://www.youtube.com/watch?v=jfKfPfyJRdk',
        listenCount: 3,
        listenedAt: t.subtract(const Duration(minutes: 18)),
      );
      byUser['sample_de_lukas'] = MusicListenerRecord(
        userId: 'sample_de_lukas',
        userName: 'Lukas Weber',
        nickname: 'lukas_heart',
        musicUrl: 'https://www.youtube.com/watch?v=jfKfPfyJRdk',
        listenCount: 1,
        listenedAt: t.subtract(const Duration(hours: 2)),
      );
    } else if (targetUid == 'sample_de_lukas') {
      final t = _clock();
      byUser['sample_tr_ayse'] = MusicListenerRecord(
        userId: 'sample_tr_ayse',
        userName: 'Ayşe Demir',
        nickname: 'ayse_saglik',
        musicUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
        listenCount: 2,
        listenedAt: t.subtract(const Duration(minutes: 45)),
      );
    }

    for (final rec in await _loadLocalListeners(targetUid)) {
      byUser[rec.userId] = rec;
    }

    if (_canUseFirestore) {
      try {
        final snap = await _db
            .collection('community_profiles')
            .doc(targetUid)
            .collection('musicListeners')
            .limit(100)
            .get();
        for (final doc in snap.docs) {
          final rec = MusicListenerRecord.fromJson(
            doc.data(),
            fallbackUid: doc.id,
          );
          byUser[rec.userId] = rec;
        }
      } catch (_) {}
    }

    final list = byUser.values.toList()
      ..sort((a, b) => b.listenedAt.compareTo(a.listenedAt));
    return list;
  }

  Future<MusicListenerRecord> recordMusicListen({
    required String targetUid,
    required String listenerUid,
    required String listenerName,
    String listenerNickname = '',
    String? listenerPhotoUrl,
    required String musicUrl,
  }) async {
    final now = _clock();
    final existingList = await _loadLocalListeners(targetUid);
    final idx = existingList.indexWhere((e) => e.userId == listenerUid);
    final prevCount = idx >= 0 ? existingList[idx].listenCount : 0;

    final record = MusicListenerRecord(
      userId: listenerUid,
      userName: listenerName.trim().isEmpty ? 'VisualCheckUp Member' : listenerName.trim(),
      nickname: listenerNickname.trim(),
      photoUrl: listenerPhotoUrl,
      musicUrl: musicUrl.trim(),
      listenCount: prevCount + 1,
      listenedAt: now,
    );

    final updatedList = List<MusicListenerRecord>.from(existingList);
    if (idx >= 0) {
      updatedList[idx] = record;
    } else {
      updatedList.insert(0, record);
    }
    await _saveLocalListeners(targetUid, updatedList);

    if (_canUseFirestore) {
      try {
        final ref = _db
            .collection('community_profiles')
            .doc(targetUid)
            .collection('musicListeners')
            .doc(listenerUid);
        final remoteSnap = await ref.get();
        final remotePrev = remoteSnap.exists
            ? ((remoteSnap.data()?['listenCount'] as num?)?.toInt() ?? 0)
            : prevCount;
        await ref.set({
          'userId': listenerUid,
          'userName': record.userName,
          if (record.nickname.isNotEmpty) 'nickname': record.nickname,
          if (record.photoUrl != null && record.photoUrl!.isNotEmpty)
            'photoUrl': record.photoUrl,
          'musicUrl': record.musicUrl,
          'listenCount': remotePrev + 1,
          'listenedAt': now.toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
    return record;
  }

  /// Resolves profiles of members who liked [targetUid]'s profile.
  Future<List<HealthCommunityProfile>> loadProfileLikers(
    String targetUid,
  ) async {
    final target = await getProfile(targetUid);
    if (target == null || target.likedBy.isEmpty) return const [];
    final all = await _loadLocalProfileMap();
    final result = <HealthCommunityProfile>[];
    for (final uid in target.likedBy) {
      final found = all[uid] ?? await getProfile(uid);
      if (found != null) {
        result.add(found);
      } else {
        result.add(
          HealthCommunityProfile(
            uid: uid,
            displayName: uid.startsWith('u_demo_')
                ? 'Sağlık Üyesi #${uid.replaceFirst('u_demo_', '')}'
                : uid,
            updatedAt: _clock(),
          ),
        );
      }
    }
    return result;
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
    String? senderEmail,
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

    // 0. Content safety check (profanity, insults, hate speech, ad-spam)
    if (trimmedText.isNotEmpty) {
      final safety = ContentSafetyService.checkText(trimmedText);
      if (!safety.isSafe) {
        return SendMessageStatus.unsafeContent;
      }
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
    if (receiver.onlyFriendsCanMessage &&
        !await areFriends(senderUid, receiver.uid)) {
      return SendMessageStatus.friendsOnly;
    }

    // 3. Anti-spam cooldown + daily quota check (adapted from Social Formül Bank)
    final now = _clock();
    final prefs = await SharedPreferences.getInstance();
    final rateKey = '$_rateKeyPrefix$senderUid';
    final rawRate = prefs.getString(rateKey);
    int sentToday = 0;
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final subRepo = subscriptionRepository ?? SubscriptionRepository();
    final senderSub = await subRepo.loadSubscription(uid: senderUid);
    final isSenderAdmin = AdminUtils.isAdmin(
      email: senderEmail,
      uid: senderUid,
    );
    final effectiveDailyLimit = _customDailyMessageLimit ??
        subRepo.dailyDirectMessageLimit(
          subscription: senderSub,
          isAdmin: isSenderAdmin,
        );

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
        if (sentToday >= effectiveDailyLimit) {
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

  // ---------------------------------------------------------------------------
  // Mutual Health Friends (`community_friendships/{pairId}`) & Mood
  // ---------------------------------------------------------------------------

  static const String _friendsKey = 'visualcheckup_comm_friends_v1';

  Future<List<FriendshipRecord>> _loadLocalFriendships() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_friendsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(FriendshipRecord.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalFriendships(List<FriendshipRecord> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _friendsKey,
      jsonEncode(list.map((f) => f.toJson()).toList()),
    );
  }

  Future<List<FriendshipRecord>> loadFriendships(String myUid) async {
    if (myUid.isEmpty) return const [];
    final byId = <String, FriendshipRecord>{};
    for (final f in await _loadLocalFriendships()) {
      if (f.members.contains(myUid)) byId[f.pairId] = f;
    }
    if (_canUseFirestore) {
      try {
        final snap = await _db
            .collection('community_friendships')
            .where('members', arrayContains: myUid)
            .get();
        for (final doc in snap.docs) {
          byId[doc.id] =
              FriendshipRecord.fromJson(doc.data(), fallbackId: doc.id);
        }
      } catch (_) {}
    }
    return byId.values.where((f) => f.status != FriendshipStatus.declined).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<bool> areFriends(String uidA, String uidB) async {
    final id = FriendshipRecord.pairIdFor(uidA, uidB);
    for (final f in await loadFriendships(uidA)) {
      if (f.pairId == id && f.status == FriendshipStatus.accepted) return true;
    }
    return false;
  }

  Future<void> _upsertFriendship(FriendshipRecord rec) async {
    final list = await _loadLocalFriendships();
    list.removeWhere((f) => f.pairId == rec.pairId);
    list.add(rec);
    await _saveLocalFriendships(list);
    if (_canUseFirestore) {
      try {
        await _db
            .collection('community_friendships')
            .doc(rec.pairId)
            .set(rec.toJson());
      } catch (_) {}
    }
  }

  Future<FriendshipRecord?> sendFriendRequest({
    required String myUid,
    required String myName,
    required HealthCommunityProfile target,
  }) async {
    if (myUid.isEmpty || target.uid.isEmpty || myUid == target.uid) return null;
    final pairId = FriendshipRecord.pairIdFor(myUid, target.uid);
    for (final f in await loadFriendships(myUid)) {
      if (f.pairId == pairId) return f;
    }
    final rec = FriendshipRecord(
      pairId: pairId,
      members: [myUid, target.uid]..sort(),
      requesterId: myUid,
      status: target.isSampleProfile
          ? FriendshipStatus.accepted
          : FriendshipStatus.pending,
      displayNames: {myUid: myName, target.uid: target.visibleName},
      updatedAt: _clock(),
    );
    await _upsertFriendship(rec);
    return rec;
  }

  Future<void> respondFriendRequest({
    required String pairId,
    required bool accept,
  }) async {
    final list = await _loadLocalFriendships();
    final idx = list.indexWhere((f) => f.pairId == pairId);
    if (idx == -1) return;
    final updated = list[idx].copyWith(
      status: accept ? FriendshipStatus.accepted : FriendshipStatus.declined,
      updatedAt: _clock(),
    );
    await _upsertFriendship(updated);
  }

  Future<void> removeFriend(String pairId) async {
    final list = await _loadLocalFriendships();
    list.removeWhere((f) => f.pairId == pairId);
    await _saveLocalFriendships(list);
    if (_canUseFirestore) {
      try {
        await _db.collection('community_friendships').doc(pairId).delete();
      } catch (_) {}
    }
  }

  Future<HealthCommunityProfile?> updateMood(
    String uid,
    HealthMood? mood,
  ) async {
    final existing = await loadMyProfile(uid);
    if (existing == null) return null;
    final updated = mood == null
        ? existing.copyWith(clearMood: true)
        : existing.copyWith(mood: mood);
    return saveMyProfile(updated);
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
