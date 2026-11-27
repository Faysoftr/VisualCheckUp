import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';

/// Repository backing VisualCheckUp's Admin Control Panel:
/// - Global Announcements (`app_announcements`)
/// - Promotions / Ads (`app_promotions`)
/// - Safety Reports Moderation (`community_reports`)
/// - User Moderation & Live Community Statistics (`HealthCommunityRepository`)
///
/// Supports live Cloud Firestore when signed in via Firebase Auth and falls back
/// seamlessly to local SharedPreferences storage offline / in widget tests.
class AdminRepository {
  AdminRepository({
    HealthCommunityRepository? communityRepository,
    this.useFirebase = true,
  }) : communityRepository =
            communityRepository ??
            HealthCommunityRepository(useFirebase: useFirebase);

  final HealthCommunityRepository communityRepository;
  final bool useFirebase;

  static const String _announcementsKey = 'visualcheckup_admin_announcements_v1';
  static const String _promotionsKey = 'visualcheckup_admin_promotions_v1';
  static const String _reportsKey = 'visualcheckup_comm_reports_v1';

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

  // ---------------------------------------------------------------------------
  // Announcements CRUD
  // ---------------------------------------------------------------------------

  Future<List<GlobalAnnouncement>> loadAnnouncements({
    bool activeOnly = false,
  }) async {
    final byId = <String, GlobalAnnouncement>{};
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_announcementsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final a = GlobalAnnouncement.fromJson(item);
            if (a.id.isNotEmpty) byId[a.id] = a;
          }
        }
      } catch (_) {}
    }

    if (_canUseFirestore) {
      try {
        final snap = await _db.collection('app_announcements').limit(50).get();
        for (final doc in snap.docs) {
          final a = GlobalAnnouncement.fromJson(
            doc.data(),
            fallbackId: doc.id,
          );
          byId[a.id] = a;
        }
      } catch (_) {}
    }

    final list = byId.values
        .where((a) => !activeOnly || a.isActive)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> _saveLocalAnnouncements(List<GlobalAnnouncement> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _announcementsKey,
      jsonEncode(list.map((a) => a.toJson()).toList()),
    );
  }

  Future<GlobalAnnouncement> saveAnnouncement(
    GlobalAnnouncement announcement,
  ) async {
    final list = await loadAnnouncements();
    list.removeWhere((a) => a.id == announcement.id);
    list.insert(0, announcement);
    await _saveLocalAnnouncements(list);

    if (_canUseFirestore) {
      try {
        await _db
            .collection('app_announcements')
            .doc(announcement.id)
            .set(announcement.toJson());
      } catch (_) {}
    }
    return announcement;
  }

  Future<void> deleteAnnouncement(String id) async {
    final list = await loadAnnouncements();
    list.removeWhere((a) => a.id == id);
    await _saveLocalAnnouncements(list);

    if (_canUseFirestore) {
      try {
        await _db.collection('app_announcements').doc(id).delete();
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // Promotions / Ads CRUD
  // ---------------------------------------------------------------------------

  Future<List<HealthPromotion>> loadPromotions({
    bool activeOnly = false,
    PromotionPlacement? placement,
  }) async {
    final byId = <String, HealthPromotion>{};
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_promotionsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final p = HealthPromotion.fromJson(item);
            if (p.id.isNotEmpty) byId[p.id] = p;
          }
        }
      } catch (_) {}
    }

    if (_canUseFirestore) {
      try {
        final snap = await _db.collection('app_promotions').limit(50).get();
        for (final doc in snap.docs) {
          final p = HealthPromotion.fromJson(
            doc.data(),
            fallbackId: doc.id,
          );
          byId[p.id] = p;
        }
      } catch (_) {}
    }

    final list = byId.values.where((p) {
      if (activeOnly && !p.isActive) return false;
      if (placement != null && p.placement != placement) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> _saveLocalPromotions(List<HealthPromotion> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _promotionsKey,
      jsonEncode(list.map((p) => p.toJson()).toList()),
    );
  }

  Future<HealthPromotion> savePromotion(HealthPromotion promo) async {
    final list = await loadPromotions();
    list.removeWhere((p) => p.id == promo.id);
    list.insert(0, promo);
    await _saveLocalPromotions(list);

    if (_canUseFirestore) {
      try {
        await _db
            .collection('app_promotions')
            .doc(promo.id)
            .set(promo.toJson());
      } catch (_) {}
    }
    return promo;
  }

  Future<void> deletePromotion(String id) async {
    final list = await loadPromotions();
    list.removeWhere((p) => p.id == id);
    await _saveLocalPromotions(list);

    if (_canUseFirestore) {
      try {
        await _db.collection('app_promotions').doc(id).delete();
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // Reports Moderation
  // ---------------------------------------------------------------------------

  Future<List<AdminReportItem>> loadReports() async {
    final byId = <String, AdminReportItem>{};
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_reportsKey) ?? const <String>[];
    for (int i = 0; i < rawList.length; i++) {
      try {
        final map = jsonDecode(rawList[i]) as Map<String, dynamic>;
        final id = (map['id'] as String?)?.isNotEmpty == true
            ? map['id'] as String
            : 'local_report_$i';
        byId[id] = AdminReportItem.fromJson(map, fallbackId: id);
      } catch (_) {}
    }

    if (_canUseFirestore) {
      try {
        final snap = await _db.collection('community_reports').limit(100).get();
        for (final doc in snap.docs) {
          byId[doc.id] = AdminReportItem.fromJson(
            doc.data(),
            fallbackId: doc.id,
          );
        }
      } catch (_) {}
    }

    final list = byId.values.toList()
      ..sort((a, b) {
        if (a.status == 'pending' && b.status != 'pending') return -1;
        if (a.status != 'pending' && b.status == 'pending') return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    return list;
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_reportsKey) ?? const <String>[];
    final updated = <String>[];
    for (int i = 0; i < rawList.length; i++) {
      try {
        final map = jsonDecode(rawList[i]) as Map<String, dynamic>;
        final id = (map['id'] as String?)?.isNotEmpty == true
            ? map['id'] as String
            : 'local_report_$i';
        if (id == reportId) {
          map['id'] = id;
          map['status'] = status;
        }
        updated.add(jsonEncode(map));
      } catch (_) {
        updated.add(rawList[i]);
      }
    }
    await prefs.setStringList(_reportsKey, updated);

    if (_canUseFirestore && !reportId.startsWith('local_report_')) {
      try {
        await _db
            .collection('community_reports')
            .doc(reportId)
            .update({'status': status});
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // Live Admin Dashboard Statistics
  // ---------------------------------------------------------------------------

  Future<AdminDashboardStats> computeStats() async {
    final profiles = await communityRepository.loadAllProfilesForAdmin();
    final conversations =
        await communityRepository.loadTotalConversationCountForAdmin();
    final reports = await loadReports();
    final announcements = await loadAnnouncements(activeOnly: true);
    final promotions = await loadPromotions(activeOnly: true);

    final now = DateTime.now();
    int online = 0;
    int discoverable = 0;
    int suspended = 0;
    int totalLikes = 0;
    final conditionCounts = <ChronicCondition, int>{};

    for (final p in profiles) {
      if (p.isVisibleOnlineAt(now)) online++;
      if (p.discoverable && !p.isSuspended) discoverable++;
      if (p.isSuspended) suspended++;
      totalLikes += p.likesCount;
      for (final c in p.chronicConditions) {
        conditionCounts[c] = (conditionCounts[c] ?? 0) + 1;
      }
    }

    return AdminDashboardStats(
      totalMembers: profiles.length,
      onlineMembers: online,
      discoverableMembers: discoverable,
      suspendedMembers: suspended,
      totalLikes: totalLikes,
      totalConversations: conversations,
      pendingReports: reports.where((r) => r.status == 'pending').length,
      activeAnnouncements: announcements.length,
      activePromotions: promotions.length,
      conditionCounts: conditionCounts,
    );
  }
}
