import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

class HistoryRepository {
  static const String _historyKey = 'visualcheckup_history_v1';
  static const String _disclaimerAcceptedKey = 'visualcheckup_disclaimer_v1';
  static const String _baselinesKey = 'visualcheckup_baselines_v1';
  static const String _cloudAiEnabledKey = 'visualcheckup_cloud_ai_v1';
  static const String _aiCacheKey = 'visualcheckup_ai_cache_v1';
  static const int _maxAiCacheEntries = 20;

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

  /// Removes all user-scoped local health check records, baselines, and AI cache.
  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_baselinesKey);
    await prefs.remove(_aiCacheKey);
    await prefs.remove(_cloudAiEnabledKey);
  }

  Future<bool> isDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerAcceptedKey) ?? false;
  }

  Future<void> setDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerAcceptedKey, true);
  }

  /// Privacy-first opt-in toggle for optional cloud Vision AI (Gemini/Firebase).
  Future<bool> isCloudAiEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cloudAiEnabledKey) ?? false;
  }

  Future<void> setCloudAiEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cloudAiEnabledKey, enabled);
  }

  /// Looks up a previously analyzed AI result by preprocessed image fingerprint
  /// so identical gallery images cost 0 tokens on repeat checks.
  Future<AnalysisResult?> getCachedAiResult(String fingerprint) async {
    final map = await _loadAiCacheMap();
    final entry = map[fingerprint];
    if (entry is! Map<String, dynamic>) return null;
    try {
      return AnalysisResult.fromJson(entry);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedAiResult(
    String fingerprint,
    AnalysisResult result,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _loadAiCacheMap();
    map.remove(fingerprint);
    map[fingerprint] = result.toJson();

    // Keep cache bounded to the most recent entries.
    while (map.length > _maxAiCacheEntries) {
      map.remove(map.keys.first);
    }
    await prefs.setString(_aiCacheKey, jsonEncode(map));
  }

  Future<void> clearAiCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_aiCacheKey);
  }

  Future<Map<String, dynamic>> _loadAiCacheMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_aiCacheKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
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
