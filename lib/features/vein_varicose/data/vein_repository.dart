import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/vein_varicose/domain/vein_models.dart';

class VeinRepository {
  VeinRepository({SharedPreferences? preferences}) : _prefs = preferences;

  SharedPreferences? _prefs;
  static const String _keyRecords = 'visualcheckup_vein_records_v1';
  final ValueNotifier<int> revisionNotifier = ValueNotifier<int>(0);

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<VeinCheckRecord>> loadRecords() async {
    final prefs = await _getPrefs();
    final raw = prefs.getStringList(_keyRecords) ?? [];
    final list = <VeinCheckRecord>[];
    for (final s in raw) {
      try {
        list.add(VeinCheckRecord.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Error parsing vein record: $e');
      }
    }
    list.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return list;
  }

  Future<void> saveRecord(VeinCheckRecord record) async {
    final prefs = await _getPrefs();
    final current = await loadRecords();
    current.removeWhere((r) => r.id == record.id);
    current.insert(0, record);
    if (current.length > 50) current.removeRange(50, current.length);
    final encoded = current.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyRecords, encoded);
    revisionNotifier.value++;
  }

  Future<void> deleteRecord(String id) async {
    final prefs = await _getPrefs();
    final current = await loadRecords();
    current.removeWhere((r) => r.id == id);
    final encoded = current.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyRecords, encoded);
    revisionNotifier.value++;
  }
}
