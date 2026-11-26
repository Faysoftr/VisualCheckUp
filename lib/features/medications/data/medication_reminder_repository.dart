import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/storage/checkup_photo_storage.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';

/// Profile-scoped local persistence for medication alarms and daily adherence
/// logs using [SharedPreferences] + private local photo storage.
class MedicationReminderRepository {
  MedicationReminderRepository({this.profileId = 'default'});

  final String profileId;

  static const String _baseRemindersKey = 'visualcheckup_med_reminders_v1';
  static const String _baseDoseLogsKey = 'visualcheckup_med_dose_logs_v1';

  String _scoped(String baseKey) =>
      profileId == 'default' ? baseKey : '${baseKey}_$profileId';

  String get _remindersKey => _scoped(_baseRemindersKey);
  String get _doseLogsKey => _scoped(_baseDoseLogsKey);

  Future<List<MedicationReminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_remindersKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(MedicationReminder.fromJson)
          .toList()
        ..sort((a, b) {
          final timeCmp = a.minutesFromMidnight.compareTo(b.minutesFromMidnight);
          if (timeCmp != 0) return timeCmp;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
      return list;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _persistReminders(List<MedicationReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_remindersKey, encoded);
  }

  Future<void> saveReminder(MedicationReminder reminder) async {
    final list = List<MedicationReminder>.from(await loadReminders());
    final index = list.indexWhere((r) => r.id == reminder.id);
    if (index >= 0) {
      final previous = list[index];
      if (previous.photoPath != null &&
          previous.photoPath != reminder.photoPath) {
        await CheckupPhotoStorage.deletePhoto(previous.photoPath);
      }
      list[index] = reminder;
    } else {
      list.add(reminder);
    }
    await _persistReminders(list);
  }

  Future<void> toggleEnabled(String reminderId, bool enabled) async {
    final list = List<MedicationReminder>.from(await loadReminders());
    final index = list.indexWhere((r) => r.id == reminderId);
    if (index < 0) return;
    list[index] = list[index].copyWith(enabled: enabled);
    await _persistReminders(list);
  }

  Future<void> deleteReminder(String reminderId) async {
    final list = List<MedicationReminder>.from(await loadReminders());
    final removed = list.where((r) => r.id == reminderId).toList();
    for (final item in removed) {
      await CheckupPhotoStorage.deletePhoto(item.photoPath);
    }
    list.removeWhere((r) => r.id == reminderId);
    await _persistReminders(list);

    final logs = List<MedicationDoseLog>.from(await loadDoseLogs());
    logs.removeWhere((l) => l.reminderId == reminderId);
    await _persistDoseLogs(logs);
  }

  Future<MedicationReminder?> findById(String reminderId) async {
    final list = await loadReminders();
    for (final r in list) {
      if (r.id == reminderId) return r;
    }
    return null;
  }

  /// Stores a medication photo privately inside the app's documents directory.
  Future<String?> saveMedicationPhoto({
    required String reminderId,
    required Uint8List imageBytes,
  }) {
    return CheckupPhotoStorage.savePhoto(
      resultId: 'med_${profileId}_$reminderId',
      imageBytes: imageBytes,
    );
  }

  Future<List<MedicationDoseLog>> loadDoseLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_doseLogsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(MedicationDoseLog.fromJson)
          .toList()
        ..sort((a, b) => b.actionAt.compareTo(a.actionAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> _persistDoseLogs(List<MedicationDoseLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    // Keep last 400 dose records to bound storage cleanly.
    final trimmed = logs.take(400).toList();
    final encoded = jsonEncode(trimmed.map((l) => l.toJson()).toList());
    await prefs.setString(_doseLogsKey, encoded);
  }

  Future<void> logDoseStatus({
    required String reminderId,
    required MedicationDoseStatus status,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now();
    final dateKey = MedicationReminder.dateKeyFor(ts);
    final logs = List<MedicationDoseLog>.from(await loadDoseLogs());
    logs.removeWhere((l) => l.reminderId == reminderId && l.dateKey == dateKey);
    logs.insert(
      0,
      MedicationDoseLog(
        id: '${reminderId}_$dateKey',
        reminderId: reminderId,
        dateKey: dateKey,
        status: status,
        actionAt: ts,
      ),
    );
    await _persistDoseLogs(logs);
  }

  Future<void> clearTodayDoseStatus(String reminderId, {DateTime? now}) async {
    final dateKey = MedicationReminder.dateKeyFor(now ?? DateTime.now());
    final logs = List<MedicationDoseLog>.from(await loadDoseLogs());
    logs.removeWhere((l) => l.reminderId == reminderId && l.dateKey == dateKey);
    await _persistDoseLogs(logs);
  }

  Future<Map<String, MedicationDoseLog>> getTodayStatusMap({
    DateTime? now,
  }) async {
    final dateKey = MedicationReminder.dateKeyFor(now ?? DateTime.now());
    final logs = await loadDoseLogs();
    final map = <String, MedicationDoseLog>{};
    for (final log in logs) {
      if (log.dateKey == dateKey) {
        map[log.reminderId] = log;
      }
    }
    return map;
  }

  Future<void> clearAll() async {
    final reminders = await loadReminders();
    for (final r in reminders) {
      await CheckupPhotoStorage.deletePhoto(r.photoPath);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_remindersKey);
    await prefs.remove(_doseLogsKey);
  }
}
