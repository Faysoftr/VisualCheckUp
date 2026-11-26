import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/growth/domain/growth_models.dart';

/// Persists adult height/weight/BMI history, registered children profiles,
/// and per-child growth measurements locally on-device.
class GrowthRepository {
  static const String _adultMeasurementsKey = 'visualcheckup_adult_growth_v1';
  static const String _childrenKey = 'visualcheckup_children_v1';
  static const String _childMeasurementsKey = 'visualcheckup_child_growth_v1';

  Future<List<AdultBodyMeasurement>> loadAdultMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_adultMeasurementsKey) ?? <String>[];
    final items = <AdultBodyMeasurement>[];
    for (final entry in raw) {
      try {
        items.add(
          AdultBodyMeasurement.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        );
      } catch (_) {}
    }
    items.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return items;
  }

  Future<void> saveAdultMeasurement(AdultBodyMeasurement item) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadAdultMeasurements();
    final updated = [item, ...current.where((e) => e.id != item.id)]
        .take(200)
        .toList();
    await prefs.setStringList(
      _adultMeasurementsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> deleteAdultMeasurement(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadAdultMeasurements();
    final updated = current.where((e) => e.id != id).toList();
    await prefs.setStringList(
      _adultMeasurementsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<List<ChildProfile>> loadChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_childrenKey) ?? <String>[];
    final items = <ChildProfile>[];
    for (final entry in raw) {
      try {
        items.add(
          ChildProfile.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        );
      } catch (_) {}
    }
    return items;
  }

  Future<void> saveChild(ChildProfile child) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadChildren();
    final updated = [...current.where((c) => c.id != child.id), child];
    await prefs.setStringList(
      _childrenKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> deleteChild(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadChildren();
    final updated = current.where((c) => c.id != childId).toList();
    await prefs.setStringList(
      _childrenKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
    final allMeasurements = await loadAllChildMeasurements();
    final remaining =
        allMeasurements.where((m) => m.childId != childId).toList();
    await prefs.setStringList(
      _childMeasurementsKey,
      remaining.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<List<ChildGrowthMeasurement>> loadAllChildMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_childMeasurementsKey) ?? <String>[];
    final items = <ChildGrowthMeasurement>[];
    for (final entry in raw) {
      try {
        items.add(
          ChildGrowthMeasurement.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        );
      } catch (_) {}
    }
    items.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return items;
  }

  Future<List<ChildGrowthMeasurement>> loadMeasurementsForChild(
    String childId,
  ) async {
    final all = await loadAllChildMeasurements();
    return all.where((m) => m.childId == childId).toList();
  }

  Future<void> saveChildMeasurement(ChildGrowthMeasurement item) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadAllChildMeasurements();
    final updated = [item, ...current.where((e) => e.id != item.id)]
        .take(400)
        .toList();
    await prefs.setStringList(
      _childMeasurementsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> deleteChildMeasurement(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadAllChildMeasurements();
    final updated = current.where((e) => e.id != id).toList();
    await prefs.setStringList(
      _childMeasurementsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
