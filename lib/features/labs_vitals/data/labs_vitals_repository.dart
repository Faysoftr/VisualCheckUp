import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

/// Persists dated hospital/blood lab reports, blood pressure measurements,
/// and blood sugar measurements locally on-device.
class LabsVitalsRepository {
  static const String _labReportsKey = 'visualcheckup_lab_reports_v1';
  static const String _bpReadingsKey = 'visualcheckup_bp_readings_v1';
  static const String _sugarReadingsKey = 'visualcheckup_sugar_readings_v1';

  Future<List<LabReportRecord>> loadLabReports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_labReportsKey) ?? <String>[];
    final items = <LabReportRecord>[];
    for (final entry in raw) {
      try {
        items.add(
          LabReportRecord.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        );
      } catch (_) {
        // Ignore malformed legacy entries safely
      }
    }
    items.sort((a, b) => b.reportDate.compareTo(a.reportDate));
    return items;
  }

  Future<void> saveLabReport(LabReportRecord report) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadLabReports();
    final updated = [
      report,
      ...current.where((r) => r.id != report.id),
    ].take(100).toList();
    await prefs.setStringList(
      _labReportsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> deleteLabReport(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadLabReports();
    final updated = current.where((r) => r.id != id).toList();
    await prefs.setStringList(
      _labReportsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<List<BloodPressureReading>> loadBloodPressureReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bpReadingsKey) ?? <String>[];
    final items = <BloodPressureReading>[];
    for (final entry in raw) {
      try {
        items.add(
          BloodPressureReading.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        );
      } catch (_) {}
    }
    items.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return items;
  }

  Future<void> saveBloodPressure(BloodPressureReading reading) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadBloodPressureReadings();
    final updated = [
      reading,
      ...current.where((r) => r.id != reading.id),
    ].take(200).toList();
    await prefs.setStringList(
      _bpReadingsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> deleteBloodPressure(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadBloodPressureReadings();
    final updated = current.where((r) => r.id != id).toList();
    await prefs.setStringList(
      _bpReadingsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<List<BloodSugarReading>> loadBloodSugarReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_sugarReadingsKey) ?? <String>[];
    final items = <BloodSugarReading>[];
    for (final entry in raw) {
      try {
        items.add(
          BloodSugarReading.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        );
      } catch (_) {}
    }
    items.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return items;
  }

  Future<void> saveBloodSugar(BloodSugarReading reading) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadBloodSugarReadings();
    final updated = [
      reading,
      ...current.where((r) => r.id != reading.id),
    ].take(200).toList();
    await prefs.setStringList(
      _sugarReadingsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> deleteBloodSugar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadBloodSugarReadings();
    final updated = current.where((r) => r.id != id).toList();
    await prefs.setStringList(
      _sugarReadingsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_labReportsKey);
    await prefs.remove(_bpReadingsKey);
    await prefs.remove(_sugarReadingsKey);
  }
}
