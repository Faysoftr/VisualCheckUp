import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderConfig {
  const ReminderConfig({
    this.enabled = false,
    this.hour = 9,
    this.minute = 30,
  });

  final bool enabled;
  final int hour;
  final int minute;

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);
}

/// Persists personal follow-up reminder preferences locally so due checks
/// are highlighted at the user's preferred daily reminder time.
class ReminderPreferencesService {
  const ReminderPreferencesService();

  static const String _enabledKey = 'visualcheckup_reminders_enabled_v1';
  static const String _hourKey = 'visualcheckup_reminders_hour_v1';
  static const String _minuteKey = 'visualcheckup_reminders_minute_v1';

  Future<ReminderConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ReminderConfig(
      enabled: prefs.getBool(_enabledKey) ?? false,
      hour: prefs.getInt(_hourKey) ?? 9,
      minute: prefs.getInt(_minuteKey) ?? 30,
    );
  }

  Future<void> save(ReminderConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, config.enabled);
    await prefs.setInt(_hourKey, config.hour);
    await prefs.setInt(_minuteKey, config.minute);
  }
}
