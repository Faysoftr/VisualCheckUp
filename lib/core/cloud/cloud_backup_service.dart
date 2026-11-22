import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

class CloudSyncSummary {
  const CloudSyncSummary({
    required this.labReportsCount,
    required this.bpCount,
    required this.sugarCount,
    required this.visualChecksCount,
  });

  final int labReportsCount;
  final int bpCount;
  final int sugarCount;
  final int visualChecksCount;

  int get totalCount =>
      labReportsCount + bpCount + sugarCount + visualChecksCount;
}

/// Opt-in personal Firebase Firestore cloud backup service.
///
/// Defaults to OFF (local-first privacy). Only syncs when the user explicitly
/// consents and is signed in with a real Firebase Auth account (Google/Apple).
class CloudBackupService {
  const CloudBackupService();

  static const String _enabledKey = 'visualcheckup_cloud_backup_enabled_v1';
  static const String _lastSyncKey = 'visualcheckup_cloud_backup_last_sync_v1';

  bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;

  String? get activeFirebaseUid =>
      isFirebaseAvailable ? fb.FirebaseAuth.instance.currentUser?.uid : null;

  bool get canSyncNow => activeFirebaseUid != null;

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    final uid = activeFirebaseUid;
    if (uid != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'cloudBackupEnabled': enabled,
            'updatedAt': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );
      } catch (_) {
        // Local preference still persists even when offline.
      }
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<CloudSyncSummary> backupAll({
    required LabsVitalsRepository labsVitalsRepository,
    required HistoryRepository historyRepository,
  }) async {
    final uid = activeFirebaseUid;
    if (uid == null) {
      throw StateError(
        'Bulut yedekleme için Google veya Apple hesabıyla giriş yapılmalıdır.',
      );
    }

    final db = FirebaseFirestore.instance;
    final userDoc = db.collection('users').doc(uid);

    final labs = await labsVitalsRepository.loadLabReports();
    final bp = await labsVitalsRepository.loadBloodPressureReadings();
    final sugar = await labsVitalsRepository.loadBloodSugarReadings();
    final visuals = await historyRepository.loadHistory();

    final batch = db.batch();
    batch.set(
      userDoc,
      {
        'cloudBackupEnabled': true,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );

    for (final report in labs) {
      batch.set(
        userDoc.collection('labReports').doc(report.id),
        report.toJson(),
      );
    }
    for (final reading in bp) {
      batch.set(
        userDoc.collection('bloodPressure').doc(reading.id),
        reading.toJson(),
      );
    }
    for (final reading in sugar) {
      batch.set(
        userDoc.collection('bloodSugar').doc(reading.id),
        reading.toJson(),
      );
    }
    for (final check in visuals) {
      batch.set(
        userDoc.collection('visualChecks').doc(check.id),
        check.toJson(),
      );
    }

    await batch.commit();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

    return CloudSyncSummary(
      labReportsCount: labs.length,
      bpCount: bp.length,
      sugarCount: sugar.length,
      visualChecksCount: visuals.length,
    );
  }

  Future<CloudSyncSummary> restoreAll({
    required LabsVitalsRepository labsVitalsRepository,
    required HistoryRepository historyRepository,
  }) async {
    final uid = activeFirebaseUid;
    if (uid == null) {
      throw StateError(
        'Buluttan geri yükleme için Google veya Apple hesabıyla giriş yapılmalıdır.',
      );
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    final labsSnap = await userDoc.collection('labReports').get();
    var labsRestored = 0;
    for (final doc in labsSnap.docs) {
      try {
        await labsVitalsRepository.saveLabReport(
          LabReportRecord.fromJson(doc.data()),
        );
        labsRestored++;
      } catch (_) {}
    }

    final bpSnap = await userDoc.collection('bloodPressure').get();
    var bpRestored = 0;
    for (final doc in bpSnap.docs) {
      try {
        await labsVitalsRepository.saveBloodPressure(
          BloodPressureReading.fromJson(doc.data()),
        );
        bpRestored++;
      } catch (_) {}
    }

    final sugarSnap = await userDoc.collection('bloodSugar').get();
    var sugarRestored = 0;
    for (final doc in sugarSnap.docs) {
      try {
        await labsVitalsRepository.saveBloodSugar(
          BloodSugarReading.fromJson(doc.data()),
        );
        sugarRestored++;
      } catch (_) {}
    }

    final visualsSnap = await userDoc.collection('visualChecks').get();
    var visualsRestored = 0;
    for (final doc in visualsSnap.docs) {
      try {
        await historyRepository.saveResult(
          AnalysisResult.fromJson(doc.data()),
        );
        visualsRestored++;
      } catch (_) {}
    }

    return CloudSyncSummary(
      labReportsCount: labsRestored,
      bpCount: bpRestored,
      sugarCount: sugarRestored,
      visualChecksCount: visualsRestored,
    );
  }

  Future<void> deleteAllCloudData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_enabledKey);
    await prefs.remove(_lastSyncKey);

    final uid = activeFirebaseUid;
    if (uid == null) return;

    try {
      final db = FirebaseFirestore.instance;
      final userDoc = db.collection('users').doc(uid);
      const subcollections = [
        'labReports',
        'bloodPressure',
        'bloodSugar',
        'visualChecks',
      ];
      for (final sub in subcollections) {
        final snap = await userDoc.collection(sub).get();
        if (snap.docs.isEmpty) continue;
        final batch = db.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
      await userDoc.delete();
    } catch (_) {
      // Best-effort cleanup if offline.
    }
  }
}
