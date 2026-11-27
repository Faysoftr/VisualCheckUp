import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuickWidgetType {
  pedometer,
  sobriety,
  vitals,
  alarms,
}

extension QuickWidgetTypeX on QuickWidgetType {
  String get title {
    switch (this) {
      case QuickWidgetType.pedometer:
        return 'Adım Sayar & Yürüyüş Widget’ı';
      case QuickWidgetType.sobriety:
        return 'Sigara & Alkol Bırakma Widget’ı';
      case QuickWidgetType.vitals:
        return 'Şeker & Tansiyon Takip Widget’ı';
      case QuickWidgetType.alarms:
        return 'İlaç & Su Alarmı Widget’ı';
    }
  }

  String get subtitle {
    switch (this) {
      case QuickWidgetType.pedometer:
        return 'Bugünkü adım, hedef ilerlemesi ve anlık yürüyüş kısayolu';
      case QuickWidgetType.sobriety:
        return 'Bugün kazanılan para, kazanılan ömür ve özgürlük günü';
      case QuickWidgetType.vitals:
        return 'Son tansiyon/şeker değerleri ve tek tıkla hızlı ölçüm kaydı';
      case QuickWidgetType.alarms:
        return 'Sıradaki hatırlatıcı saati ve günlük doz durumu';
    }
  }

  IconData get icon {
    switch (this) {
      case QuickWidgetType.pedometer:
        return Icons.directions_walk_rounded;
      case QuickWidgetType.sobriety:
        return Icons.smoke_free_rounded;
      case QuickWidgetType.vitals:
        return Icons.monitor_heart_rounded;
      case QuickWidgetType.alarms:
        return Icons.alarm_on_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case QuickWidgetType.pedometer:
        return const Color(0xFF0D9488);
      case QuickWidgetType.sobriety:
        return const Color(0xFF16A34A);
      case QuickWidgetType.vitals:
        return const Color(0xFFE11D48);
      case QuickWidgetType.alarms:
        return const Color(0xFFD97706);
    }
  }

  static QuickWidgetType? fromName(String? raw) {
    for (final t in QuickWidgetType.values) {
      if (t.name == raw) return t;
    }
    return null;
  }
}

class QuickWidgetsPreferences {
  QuickWidgetsPreferences._();

  static const String _enabledWidgetsKey =
      'visualcheckup_enabled_quick_widgets_v1';
  static const String _hubVisibleKey =
      'visualcheckup_quick_widgets_hub_visible_v1';
  static const String widgetVitalsSummaryKey = 'vcu_widget_vitals_summary';
  static const String widgetAlarmSummaryKey = 'vcu_widget_alarm_summary';

  static const MethodChannel _homeWidgetChannel =
      MethodChannel('com.faysoft.visualcheckup/home_widget');

  static final ValueNotifier<int> revisionNotifier = ValueNotifier<int>(0);

  static const List<QuickWidgetType> defaultEnabled = [
    QuickWidgetType.pedometer,
    QuickWidgetType.sobriety,
    QuickWidgetType.vitals,
    QuickWidgetType.alarms,
  ];

  static Future<bool> isHubVisible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hubVisibleKey) ?? true;
  }

  static Future<void> setHubVisible(bool visible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hubVisibleKey, visible);
    revisionNotifier.value++;
  }

  static Future<List<QuickWidgetType>> loadEnabledWidgets() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_enabledWidgetsKey);
    if (stored == null) {
      return List<QuickWidgetType>.from(defaultEnabled);
    }
    return stored
        .map(QuickWidgetTypeX.fromName)
        .whereType<QuickWidgetType>()
        .toList();
  }

  static Future<void> saveEnabledWidgets(List<QuickWidgetType> widgets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _enabledWidgetsKey,
      widgets.map((w) => w.name).toList(),
    );
    revisionNotifier.value++;
  }

  static Future<void> closeSingleWidget(QuickWidgetType type) async {
    final current = await loadEnabledWidgets();
    current.remove(type);
    await saveEnabledWidgets(current);
  }

  static Future<void> syncVitalsAndAlarmWidgetCache({
    required String vitalsSummary,
    required String alarmSummary,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(widgetVitalsSummaryKey, vitalsSummary);
    await prefs.setString(widgetAlarmSummaryKey, alarmSummary);
    unawaited(_refreshNativeSafe());
  }

  static Future<void> _refreshNativeSafe() async {
    try {
      await _homeWidgetChannel.invokeMethod<void>('refreshWidget');
    } catch (_) {}
  }

  static Future<bool> requestPinNativeHomeWidget({
    String widgetType = 'all',
  }) async {
    try {
      final pinned = await _homeWidgetChannel.invokeMethod<bool>(
        'requestPinWidget',
        <String, dynamic>{'widgetType': widgetType},
      );
      return pinned ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> bindWidgetDeepLinkHandler(
    void Function(String target) onTarget,
  ) async {
    try {
      _homeWidgetChannel.setMethodCallHandler((call) async {
        if (call.method == 'onWidgetTargetOpened' && call.arguments is String) {
          onTarget(call.arguments as String);
        }
      });
      final initial = await _homeWidgetChannel
          .invokeMethod<String>('consumeInitialWidgetTarget');
      if (initial != null && initial.isNotEmpty) {
        onTarget(initial);
      }
    } catch (_) {}
  }
}
