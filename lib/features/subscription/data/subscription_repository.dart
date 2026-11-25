import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/subscription/domain/subscription_models.dart';

/// Persists and evaluates VisualCheckUp Pro subscriptions and free monthly
/// lab report limits (3 free lab reports / month; unlimited for Pro).
class SubscriptionRepository {
  SubscriptionRepository({
    this.useFirebase = true,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final bool useFirebase;
  final DateTime Function() _clock;

  static const String _subKeyPrefix = 'visualcheckup_subscription_v1_';

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

  String _resolveKey(String? uid) {
    if (uid != null && uid.trim().isNotEmpty) return '$_subKeyPrefix$uid';
    try {
      final fbUid = Firebase.apps.isNotEmpty
          ? fb.FirebaseAuth.instance.currentUser?.uid
          : null;
      if (fbUid != null && fbUid.isNotEmpty) return '$_subKeyPrefix$fbUid';
    } catch (_) {}
    return '${_subKeyPrefix}local_default';
  }

  Future<UserSubscriptionState> loadSubscription({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _resolveKey(uid);
    UserSubscriptionState state = const UserSubscriptionState();

    final raw = prefs.getString(key);
    if (raw != null && raw.isNotEmpty) {
      try {
        state = UserSubscriptionState.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    if (_canUseFirestore) {
      final docUid = uid ?? fb.FirebaseAuth.instance.currentUser?.uid;
      if (docUid != null && docUid.isNotEmpty) {
        try {
          final snap = await _db.collection('subscriptions').doc(docUid).get();
          if (snap.exists && snap.data() != null) {
            state = UserSubscriptionState.fromJson(snap.data()!);
            await prefs.setString(key, jsonEncode(state.toJson()));
          }
        } catch (_) {}
      }
    }

    return state;
  }

  Future<UserSubscriptionState> activatePlan({
    String? uid,
    required SubscriptionTier tier,
    String storeSource = 'app_store',
  }) async {
    final now = _clock();
    final expiresAt = tier == SubscriptionTier.proYearly
        ? now.add(const Duration(days: 365))
        : tier == SubscriptionTier.proMonthly
            ? now.add(const Duration(days: 30))
            : null;

    final state = UserSubscriptionState(
      tier: tier,
      activatedAt: tier.isPro ? now : null,
      expiresAt: expiresAt,
      storeSource: storeSource,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_resolveKey(uid), jsonEncode(state.toJson()));

    if (_canUseFirestore) {
      final docUid = uid ?? fb.FirebaseAuth.instance.currentUser?.uid;
      if (docUid != null && docUid.isNotEmpty) {
        try {
          await _db
              .collection('subscriptions')
              .doc(docUid)
              .set(state.toJson(), SetOptions(merge: true));
        } catch (_) {}
      }
    }
    return state;
  }

  /// Counts lab reports created in the current calendar month.
  int countReportsInCurrentMonth(List<LabReportRecord> reports) {
    final now = _clock();
    return reports.where((r) {
      return r.reportDate.year == now.year && r.reportDate.month == now.month;
    }).length;
  }

  /// Remaining free lab report analyses for the current month (`-1` means
  /// unlimited for VisualCheckUp Pro subscribers).
  int remainingFreeLabReports({
    required List<LabReportRecord> existingReports,
    required UserSubscriptionState subscription,
  }) {
    if (subscription.isProAt(_clock())) return -1;
    final used = countReportsInCurrentMonth(existingReports);
    final rem = UserSubscriptionState.freeMonthlyLabReportLimit - used;
    return rem < 0 ? 0 : rem;
  }

  bool canAddLabReport({
    required List<LabReportRecord> existingReports,
    required UserSubscriptionState subscription,
  }) {
    if (subscription.isProAt(_clock())) return true;
    return countReportsInCurrentMonth(existingReports) <
        UserSubscriptionState.freeMonthlyLabReportLimit;
  }
}
