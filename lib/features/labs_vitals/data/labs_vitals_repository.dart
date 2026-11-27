import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

/// Persists dated hospital/blood lab reports, blood pressure measurements,
/// and blood sugar measurements locally on-device.
class LabsVitalsRepository {
  LabsVitalsRepository({this.profileId = 'self'});

  final String profileId;

  static final ValueNotifier<int> revisionNotifier = ValueNotifier<int>(0);
  static const MethodChannel _homeWidgetChannel =
      MethodChannel('com.faysoft.visualcheckup/home_widget');

  static const String _labReportsBase = 'visualcheckup_lab_reports_v1';
  static const String _bpReadingsBase = 'visualcheckup_bp_readings_v1';
  static const String _sugarReadingsBase = 'visualcheckup_sugar_readings_v1';
  static const String _widgetVitalsSummaryKey = 'vcu_widget_vitals_summary';

  String _scoped(String base) => profileId == 'self' ? base : '${base}_$profileId';
  String get _labReportsKey => _scoped(_labReportsBase);
  String get _bpReadingsKey => _scoped(_bpReadingsBase);
  String get _sugarReadingsKey => _scoped(_sugarReadingsBase);

  Future<void> _notifyAndSyncWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bps = await loadBloodPressureReadings();
      final sugars = await loadBloodSugarReadings();
      final bpText = bps.isNotEmpty ? bps.first.formatted : '--/-- mmHg';
      final sugarText = sugars.isNotEmpty ? sugars.first.formatted : '-- mg/dL';
      await prefs.setString(
        _widgetVitalsSummaryKey,
        'Tansiyon: $bpText | Şeker: $sugarText',
      );
    } catch (_) {}
    revisionNotifier.value++;
    unawaited(_refreshNativeWidgetSafe());
  }

  static Future<void> _refreshNativeWidgetSafe() async {
    try {
      await _homeWidgetChannel.invokeMethod<void>('refreshWidget');
    } catch (_) {}
  }

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
    await _notifyAndSyncWidget();
  }

  Future<void> deleteBloodPressure(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadBloodPressureReadings();
    final updated = current.where((r) => r.id != id).toList();
    await prefs.setStringList(
      _bpReadingsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
    await _notifyAndSyncWidget();
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
    await _notifyAndSyncWidget();
  }

  Future<void> deleteBloodSugar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadBloodSugarReadings();
    final updated = current.where((r) => r.id != id).toList();
    await prefs.setStringList(
      _sugarReadingsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
    await _notifyAndSyncWidget();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_labReportsKey);
    await prefs.remove(_bpReadingsKey);
    await prefs.remove(_sugarReadingsKey);
    await _notifyAndSyncWidget();
  }
}
