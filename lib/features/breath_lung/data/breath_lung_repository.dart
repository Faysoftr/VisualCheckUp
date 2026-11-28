import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/breath_lung/domain/breath_lung_models.dart';

class BreathLungRepository {
  BreathLungRepository({SharedPreferences? preferences})
      : _prefs = preferences;

  SharedPreferences? _prefs;

  static const String _keyRecords = 'visualcheckup_breath_lung_records_v1';
  static const String _keyLastAge = 'visualcheckup_breath_lung_last_age';
  static const String _keyExerciseCount = 'visualcheckup_breath_lung_exercise_count';

  final ValueNotifier<int> revisionNotifier = ValueNotifier<int>(0);

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Loads all saved breath-holding test records, newest first.
  Future<List<BreathHoldRecord>> loadRecords() async {
    final prefs = await _getPrefs();
    final rawList = prefs.getStringList(_keyRecords) ?? [];
    final records = <BreathHoldRecord>[];

    for (final item in rawList) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        records.add(BreathHoldRecord.fromJson(decoded));
      } catch (e) {
        debugPrint('Error parsing breath record: $e');
      }
    }

    records.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return records;
  }

  /// Appends or updates a test record.
  Future<void> saveRecord(BreathHoldRecord record) async {
    final prefs = await _getPrefs();
    final current = await loadRecords();
    current.removeWhere((r) => r.id == record.id);
    current.insert(0, record);

    // Keep up to 100 historical tests
    if (current.length > 100) {
      current.removeRange(100, current.length);
    }

    final encoded = current.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyRecords, encoded);
    await saveLastAge(record.age);
    revisionNotifier.value++;
  }

  /// Removes a test record by id.
  Future<void> deleteRecord(String id) async {
    final prefs = await _getPrefs();
    final current = await loadRecords();
    current.removeWhere((r) => r.id == id);
    final encoded = current.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyRecords, encoded);
    revisionNotifier.value++;
  }

  /// Clears all stored records.
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyRecords);
    revisionNotifier.value++;
  }

  /// Gets the last saved age or null.
  Future<int?> getLastAge() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyLastAge);
  }

  /// Saves the last selected or tested age.
  Future<void> saveLastAge(int age) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_keyLastAge, age.clamp(8, 110));
  }

  /// Gets the total count of guided breathing exercises completed.
  Future<int> getExerciseCompletedCount() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyExerciseCount) ?? 0;
  }

  /// Increments exercise count after a full cycle session.
  Future<int> incrementExerciseCompletedCount() async {
    final prefs = await _getPrefs();
    final current = prefs.getInt(_keyExerciseCount) ?? 0;
    final next = current + 1;
    await prefs.setInt(_keyExerciseCount, next);
    revisionNotifier.value++;
    return next;
  }

  /// Resolves the user's initial age from `birthDate` string ('dd-MM-yyyy' or 'yyyy-MM-dd'),
  /// community profile age, cached age, or fallback to 30.
  int resolveInitialAge({
    String? birthDate,
    int? profileAge,
    int? cachedAge,
  }) {
    if (profileAge != null && profileAge >= 8 && profileAge <= 110) {
      return profileAge;
    }

    if (birthDate != null && birthDate.trim().isNotEmpty) {
      final computed = calculateAgeFromBirthDate(birthDate);
      if (computed != null && computed >= 8 && computed <= 110) {
        return computed;
      }
    }

    if (cachedAge != null && cachedAge >= 8 && cachedAge <= 110) {
      return cachedAge;
    }

    return 30; // standard adult default
  }

  /// Parses 'dd-MM-yyyy', 'yyyy-MM-dd', or with '.' / '/' separators.
  static int? calculateAgeFromBirthDate(String birthDate) {
    try {
      final parts = birthDate.trim().split(RegExp(r'[-/.]'));
      if (parts.length != 3) return null;

      final p0 = int.tryParse(parts[0]);
      final p1 = int.tryParse(parts[1]);
      final p2 = int.tryParse(parts[2]);
      if (p0 == null || p1 == null || p2 == null) return null;

      int? year, month, day;
      if (p2 > 1900) {
        // dd-MM-yyyy
        day = p0;
        month = p1;
        year = p2;
      } else if (p0 > 1900) {
        // yyyy-MM-dd
        year = p0;
        month = p1;
        day = p2;
      } else {
        return null;
      }

      final now = DateTime.now();
      if (year < 1900 || year > now.year) return null;

      int age = now.year - year;
      if (now.month < month || (now.month == month && now.day < day)) {
        age--;
      }
      return age.clamp(1, 120);
    } catch (_) {
      return null;
    }
  }
}
