import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/water_tracker/domain/water_models.dart';

class WaterRepository {
  WaterRepository({SharedPreferences? preferences}) : _prefs = preferences;

  SharedPreferences? _prefs;
  static const String _keyLogs = 'visualcheckup_water_logs_v1';
  static const String _keyTarget = 'visualcheckup_water_target_v1';

  final ValueNotifier<int> revisionNotifier = ValueNotifier<int>(0);

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<int> getDailyTarget() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyTarget) ?? 2500;
  }

  Future<void> setDailyTarget(int targetMl) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_keyTarget, targetMl.clamp(1000, 5000));
    revisionNotifier.value++;
  }

  Future<List<WaterLogEntry>> loadAllEntries() async {
    final prefs = await _getPrefs();
    final raw = prefs.getStringList(_keyLogs) ?? [];
    final list = <WaterLogEntry>[];
    for (final s in raw) {
      try {
        list.add(WaterLogEntry.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Error parsing water log: $e');
      }
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<DailyWaterSummary> getTodaySummary() async {
    final target = await getDailyTarget();
    final all = await loadAllEntries();
    final now = DateTime.now();

    final todayEntries = all.where((e) {
      return e.timestamp.year == now.year &&
          e.timestamp.month == now.month &&
          e.timestamp.day == now.day;
    }).toList();

    final totalConsumed =
        todayEntries.fold<int>(0, (sum, e) => sum + e.amountMl);

    return DailyWaterSummary(
      date: DateTime(now.year, now.month, now.day),
      consumedMl: totalConsumed,
      targetMl: target,
      entries: todayEntries,
    );
  }

  Future<void> logWater(int amountMl) async {
    final prefs = await _getPrefs();
    final all = await loadAllEntries();
    final entry = WaterLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      amountMl: amountMl,
    );
    all.insert(0, entry);

    // Keep last 300 entries
    if (all.length > 300) all.removeRange(300, all.length);

    final encoded = all.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyLogs, encoded);
    revisionNotifier.value++;
  }

  Future<void> removeEntry(String id) async {
    final prefs = await _getPrefs();
    final all = await loadAllEntries();
    all.removeWhere((e) => e.id == id);
    final encoded = all.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyLogs, encoded);
    revisionNotifier.value++;
  }

  Future<void> resetToday() async {
    final prefs = await _getPrefs();
    final all = await loadAllEntries();
    final now = DateTime.now();
    all.removeWhere((e) =>
        e.timestamp.year == now.year &&
        e.timestamp.month == now.month &&
        e.timestamp.day == now.day);
    final encoded = all.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyLogs, encoded);
    revisionNotifier.value++;
  }
}
