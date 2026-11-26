import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/storage/checkup_photo_storage.dart';
import 'package:visualcheckup/features/diet/domain/diet_models.dart';

/// Profile-scoped local persistence for active diet plan, meal compliance
/// ("Uydum" / "Uymadım"), diet weight tracking, and AI plate calorie scans.
class DietRepository {
  DietRepository({this.profileId = 'default'});

  final String profileId;

  static const String _baseActivePlanKey = 'visualcheckup_diet_active_plan_v1';
  static const String _baseCustomTemplatesKey =
      'visualcheckup_diet_custom_templates_v1';
  static const String _baseComplianceKey = 'visualcheckup_diet_compliance_v1';
  static const String _baseWeightLogsKey = 'visualcheckup_diet_weights_v1';
  static const String _baseCalorieScansKey = 'visualcheckup_calorie_scans_v1';

  String _scoped(String baseKey) =>
      profileId == 'default' ? baseKey : '${baseKey}_$profileId';

  String get _activePlanKey => _scoped(_baseActivePlanKey);
  String get _customTemplatesKey => _scoped(_baseCustomTemplatesKey);
  String get _complianceKey => _scoped(_baseComplianceKey);
  String get _weightLogsKey => _scoped(_baseWeightLogsKey);
  String get _calorieScansKey => _scoped(_baseCalorieScansKey);

  // ── Custom User-Created Diet Templates ───────────────────────────────────

  Future<List<DietTemplate>> loadCustomTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customTemplatesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(DietTemplate.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCustomTemplate(DietTemplate template) async {
    final list = List<DietTemplate>.from(await loadCustomTemplates());
    final idx = list.indexWhere((t) => t.id == template.id);
    if (idx >= 0) {
      list[idx] = template;
    } else {
      list.insert(0, template);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _customTemplatesKey,
      jsonEncode(list.map((t) => t.toJson()).toList()),
    );
  }

  Future<void> deleteCustomTemplate(String templateId) async {
    final list = List<DietTemplate>.from(await loadCustomTemplates());
    list.removeWhere((t) => t.id == templateId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _customTemplatesKey,
      jsonEncode(list.map((t) => t.toJson()).toList()),
    );
  }

  // ── Active Diet Plan ──────────────────────────────────────────────────────

  Future<ActiveDietPlan?> loadActivePlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activePlanKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final plan =
          ActiveDietPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return plan.isActive ? plan : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActivePlan(ActiveDietPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activePlanKey, jsonEncode(plan.toJson()));
  }

  Future<void> endActivePlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activePlanKey);
  }

  // ── Meal Compliance ("Uydum" / "Uymadım") ─────────────────────────────────

  Future<List<DietMealComplianceLog>> loadComplianceLogs({
    String? planId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_complianceKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(DietMealComplianceLog.fromJson)
          .where((l) => planId == null || l.planId == planId)
          .toList()
        ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
      return list;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _persistComplianceLogs(List<DietMealComplianceLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = logs.take(600).toList();
    await prefs.setString(
      _complianceKey,
      jsonEncode(trimmed.map((l) => l.toJson()).toList()),
    );
  }

  Future<void> setMealCompliance({
    required String planId,
    required DateTime date,
    required MealSlot slot,
    required MealComplianceStatus status,
    String note = '',
  }) async {
    final dateKey = ActiveDietPlan.dateKeyFor(date);
    final all = List<DietMealComplianceLog>.from(await loadComplianceLogs());
    all.removeWhere(
      (l) => l.planId == planId && l.dateKey == dateKey && l.slot == slot,
    );
    if (status != MealComplianceStatus.pending) {
      all.insert(
        0,
        DietMealComplianceLog(
          id: '${planId}_${dateKey}_${slot.name}',
          planId: planId,
          dateKey: dateKey,
          slot: slot,
          status: status,
          note: note,
          loggedAt: DateTime.now(),
        ),
      );
    }
    await _persistComplianceLogs(all);
  }

  Future<Map<MealSlot, DietMealComplianceLog>> getDayComplianceMap({
    required String planId,
    required DateTime date,
  }) async {
    final dateKey = ActiveDietPlan.dateKeyFor(date);
    final logs = await loadComplianceLogs(planId: planId);
    final map = <MealSlot, DietMealComplianceLog>{};
    for (final log in logs) {
      if (log.dateKey == dateKey) {
        map[log.slot] = log;
      }
    }
    return map;
  }

  Future<DietComplianceSummary> getComplianceSummary(String planId) async {
    final logs = await loadComplianceLogs(planId: planId);
    int followed = 0;
    int notFollowed = 0;
    for (final log in logs) {
      if (log.status == MealComplianceStatus.followed) followed++;
      if (log.status == MealComplianceStatus.notFollowed) notFollowed++;
    }
    return DietComplianceSummary(
      followedCount: followed,
      notFollowedCount: notFollowed,
    );
  }

  // ── Diet Weight Tracking ──────────────────────────────────────────────────

  Future<List<DietWeightEntry>> loadWeightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weightLogsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(DietWeightEntry.fromJson)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return const [];
    }
  }

  Future<void> _persistWeightEntries(List<DietWeightEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = entries.take(300).toList();
    await prefs.setString(
      _weightLogsKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addWeightEntry(DietWeightEntry entry) async {
    final list = List<DietWeightEntry>.from(await loadWeightEntries());
    list.removeWhere((e) => e.id == entry.id);
    list.insert(0, entry);
    list.sort((a, b) => b.date.compareTo(a.date));
    await _persistWeightEntries(list);
  }

  Future<void> deleteWeightEntry(String entryId) async {
    final list = List<DietWeightEntry>.from(await loadWeightEntries());
    list.removeWhere((e) => e.id == entryId);
    await _persistWeightEntries(list);
  }

  // ── AI Plate Calorie Scans (Diet-linked OR standalone) ───────────────────

  Future<List<CalorieScanEntry>> loadCalorieScans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_calorieScansKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CalorieScanEntry.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> _persistCalorieScans(List<CalorieScanEntry> scans) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = scans.take(300).toList();
    await prefs.setString(
      _calorieScansKey,
      jsonEncode(trimmed.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> saveCalorieScan(CalorieScanEntry entry) async {
    final list = List<CalorieScanEntry>.from(await loadCalorieScans());
    list.removeWhere((e) => e.id == entry.id);
    list.insert(0, entry);
    await _persistCalorieScans(list);
  }

  Future<void> deleteCalorieScan(String entryId) async {
    final list = List<CalorieScanEntry>.from(await loadCalorieScans());
    for (final item in list.where((e) => e.id == entryId)) {
      await CheckupPhotoStorage.deletePhoto(item.photoPath);
    }
    list.removeWhere((e) => e.id == entryId);
    await _persistCalorieScans(list);
  }

  Future<String?> savePlatePhoto({
    required String scanId,
    required Uint8List imageBytes,
  }) {
    return CheckupPhotoStorage.savePhoto(
      resultId: 'plate_${profileId}_$scanId',
      imageBytes: imageBytes,
    );
  }

  Future<void> clearAll() async {
    final scans = await loadCalorieScans();
    for (final scan in scans) {
      await CheckupPhotoStorage.deletePhoto(scan.photoPath);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activePlanKey);
    await prefs.remove(_customTemplatesKey);
    await prefs.remove(_complianceKey);
    await prefs.remove(_weightLogsKey);
    await prefs.remove(_calorieScansKey);
  }
}
