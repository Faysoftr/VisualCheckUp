import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/sobriety/domain/sobriety_models.dart';

class SobrietyRepository {
  SobrietyRepository({this.profileId = 'self'});

  final String profileId;

  static const String _baseKey = 'visualcheckup_sobriety_state_v1';
  static const String widgetDaysKey = 'vcu_widget_sobriety_days';
  static const String widgetTodayTryKey = 'vcu_widget_sobriety_today_try';
  static const String widgetTotalTryKey = 'vcu_widget_sobriety_total_try';
  static const String widgetLifeKey = 'vcu_widget_sobriety_life';
  static const String widgetActiveKey = 'vcu_widget_sobriety_active';

  static final ValueNotifier<int> revisionNotifier = ValueNotifier<int>(0);
  static const MethodChannel _homeWidgetChannel =
      MethodChannel('com.faysoft.visualcheckup/home_widget');

  String get _storageKey =>
      profileId == 'self' ? _baseKey : '${_baseKey}_$profileId';

  Future<SobrietyState> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const SobrietyState();
    }
    try {
      return SobrietyState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const SobrietyState();
    }
  }

  Future<void> saveState(SobrietyState state, {DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));

    final ref = now ?? DateTime.now();
    await prefs.setBool(widgetActiveKey, state.isAnyActive);
    await prefs.setInt(widgetDaysKey, state.maxActiveDayNumber(ref));
    await prefs.setString(
      widgetTodayTryKey,
      SobrietyState.formatTry(state.todayMoneySavedAt(ref)),
    );
    await prefs.setString(
      widgetTotalTryKey,
      SobrietyState.formatTry(state.totalMoneySavedAt(ref)),
    );
    await prefs.setString(
      widgetLifeKey,
      SobrietyState.formatLifeRegained(state.lifeRegainedAt(ref)),
    );

    revisionNotifier.value++;
    await _notifyNativeHomeWidget();
  }

  static Future<void> _notifyNativeHomeWidget() async {
    try {
      await _homeWidgetChannel.invokeMethod<void>('refreshWidget');
    } catch (_) {
      // Safe no-op in tests or unsupported platforms.
    }
  }
}
