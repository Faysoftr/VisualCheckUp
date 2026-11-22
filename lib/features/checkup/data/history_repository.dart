import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

class HistoryRepository {
  static const String _historyKey = 'visualcheckup_history_v1';
  static const String _disclaimerAcceptedKey = 'visualcheckup_disclaimer_v1';
  static const String _baselinesKey = 'visualcheckup_baselines_v1';

  Future<List<AnalysisResult>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_historyKey) ?? <String>[];
    final results = <AnalysisResult>[];
    for (final raw in rawList) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        results.add(AnalysisResult.fromJson(decoded));
      } catch (_) {
        // Ignore malformed legacy entries safely
      }
    }
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<void> saveResult(AnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadHistory();
    final updated = [result, ...current].take(100).toList();
    final encoded = updated.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<void> deleteResult(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadHistory();
    final updated = current.where((e) => e.id != id).toList();
    final encoded = updated.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<bool> isDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerAcceptedKey) ?? false;
  }

  Future<void> setDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerAcceptedKey, true);
  }

  Future<Map<CheckCategory, CategoryBaseline>> loadBaselines() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_baselinesKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final map = <CheckCategory, CategoryBaseline>{};
      for (final entry in decoded.entries) {
        try {
          final baseline = CategoryBaseline.fromJson(
            entry.value as Map<String, dynamic>,
          );
          map[baseline.category] = baseline;
        } catch (_) {
          // Skip malformed baseline entry
        }
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  Future<CategoryBaseline?> getBaseline(CheckCategory category) async {
    final baselines = await loadBaselines();
    return baselines[category];
  }

  Future<void> saveBaseline(CategoryBaseline baseline) async {
    final prefs = await SharedPreferences.getInstance();
    final baselines = await loadBaselines();
    baselines[baseline.category] = baseline;
    final payload = {
      for (final entry in baselines.entries)
        entry.key.id: entry.value.toJson(),
    };
    await prefs.setString(_baselinesKey, jsonEncode(payload));
  }

  Future<void> deleteBaseline(CheckCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    final baselines = await loadBaselines();
    baselines.remove(category);
    final payload = {
      for (final entry in baselines.entries)
        entry.key.id: entry.value.toJson(),
    };
    await prefs.setString(_baselinesKey, jsonEncode(payload));
  }
}
