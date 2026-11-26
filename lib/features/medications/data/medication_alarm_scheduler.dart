import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:visualcheckup/features/medications/data/medication_alarm_audio_player.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';

/// Abstraction for scheduling native alarm notifications with medicine photos.
abstract class MedicationAlarmScheduler {
  Future<void> initialize({
    void Function(String reminderId)? onAlarmNotificationTap,
  });

  Future<bool> requestPermissions();

  Future<String?> getLaunchReminderId();

  Future<void> scheduleReminder(
    MedicationReminder reminder, {
    required String categoryLabel,
    required String mealTimingLabel,
  });

  Future<void> cancelReminder(String reminderId);

  Future<void> scheduleSnooze(
    MedicationReminder reminder, {
    int minutes = 10,
    required String categoryLabel,
    required String snoozeBody,
  });

  Future<void> showImmediateAlarmNotification(
    MedicationReminder reminder, {
    required String categoryLabel,
  });

  Future<void> syncAll(
    List<MedicationReminder> reminders, {
    required String Function(MedicationCategory) categoryLabelBuilder,
    required String Function(MealTiming) mealTimingLabelBuilder,
  });
}

/// Safe no-op implementation used in unit/widget tests or unsupported hosts.
class NoopMedicationAlarmScheduler implements MedicationAlarmScheduler {
  const NoopMedicationAlarmScheduler();

  @override
  Future<void> initialize({
    void Function(String reminderId)? onAlarmNotificationTap,
  }) async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<String?> getLaunchReminderId() async => null;

  @override
  Future<void> scheduleReminder(
    MedicationReminder reminder, {
    required String categoryLabel,
    required String mealTimingLabel,
  }) async {}

  @override
  Future<void> cancelReminder(String reminderId) async {}

  @override
  Future<void> scheduleSnooze(
    MedicationReminder reminder, {
    int minutes = 10,
    required String categoryLabel,
    required String snoozeBody,
  }) async {}

  @override
  Future<void> showImmediateAlarmNotification(
    MedicationReminder reminder, {
    required String categoryLabel,
  }) async {}

  @override
  Future<void> syncAll(
    List<MedicationReminder> reminders, {
    required String Function(MedicationCategory) categoryLabelBuilder,
    required String Function(MealTiming) mealTimingLabelBuilder,
  }) async {}
}

/// Production alarm scheduler backed by [FlutterLocalNotificationsPlugin].
///
/// Schedules high-priority alarm-channel notifications on Android (with
/// dedicated per-sound channels, custom alarm ringtones, `FLAG_INSISTENT`
/// continuous ringing, [BigPictureStyleInformation] displaying the captured
/// medicine photo, and `fullScreenIntent: true` to wake the lock screen) and
/// time-sensitive notifications with custom `.wav` alarm sounds and
/// [DarwinNotificationAttachment] on iOS/macOS.
class LocalMedicationAlarmScheduler implements MedicationAlarmScheduler {
  LocalMedicationAlarmScheduler._();

  static final LocalMedicationAlarmScheduler instance =
      LocalMedicationAlarmScheduler._();

  static const String _silentChannelId = 'visualcheckup_alarm_silent_v2';
  static const String _channelNamePrefix = 'Medication Alarms';
  static const String _channelDesc =
      'High-priority medication and health reminder alarms with medicine photo';
  static const String _payloadPrefix = 'med_alarm:';

  /// Android `Notification.FLAG_INSISTENT` (0x00000004) repeats the alarm
  /// sound continuously until the user opens or dismisses the notification.
  static const int _androidFlagInsistent = 4;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _tzInitialized = false;
  String? _cachedSystemAlarmUri;
  void Function(String reminderId)? _onTapCallback;

  /// Returns the dedicated Android notification channel ID for [reminder].
  /// Using a distinct channel per sound avoids Android's immutable channel
  /// sound cache and replaces the legacy default notification sound channel.
  static String channelIdFor(MedicationReminder reminder) {
    if (!reminder.soundEnabled) return _silentChannelId;
    return reminder.alarmSound.androidChannelId;
  }

  /// Deterministic positive 31-bit base ID for a reminder ID so every weekday
  /// slot (`1..7`) and snooze slot (`9`) has a stable notification ID.
  static int notificationIdFor(String reminderId, int slot) {
    int hash = 5381;
    for (int i = 0; i < reminderId.length; i++) {
      hash = ((hash << 5) + hash + reminderId.codeUnitAt(i)) & 0x07FFFFFF;
    }
    return (hash % 150000000) * 10 + (slot.clamp(0, 9));
  }

  static String? parseReminderIdFromPayload(String? payload) {
    if (payload == null || !payload.startsWith(_payloadPrefix)) return null;
    final id = payload.substring(_payloadPrefix.length).trim();
    return id.isEmpty ? null : id;
  }

  void _ensureTimezone() {
    if (_tzInitialized) return;
    tz_data.initializeTimeZones();
    final now = DateTime.now();
    final targetOffset = now.timeZoneOffset;
    tz.Location? matched;
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (loc.currentTimeZone.offset == targetOffset) {
        matched = loc;
        // Prefer standard IANA regional zones over Etc/GMT offsets when available.
        if (!loc.name.startsWith('Etc/')) {
          break;
        }
      }
    }
    tz.setLocalLocation(matched ?? tz.UTC);
    _tzInitialized = true;
  }

  @override
  Future<void> initialize({
    void Function(String reminderId)? onAlarmNotificationTap,
  }) async {
    _onTapCallback = onAlarmNotificationTap ?? _onTapCallback;
    if (_initialized) return;
    _ensureTimezone();

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open',
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          final id = parseReminderIdFromPayload(response.payload);
          if (id != null) {
            _onTapCallback?.call(id);
          }
        },
      );
      _initialized = true;
    } catch (_) {
      // Gracefully ignore on unsupported desktop/test runtimes.
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      await initialize();
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final notifGranted =
            await androidPlugin?.requestNotificationsPermission() ?? true;
        await androidPlugin?.requestExactAlarmsPermission();
        return notifGranted;
      }
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        return await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> getLaunchReminderId() async {
    try {
      await initialize();
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true) {
        return parseReminderIdFromPayload(
          details?.notificationResponse?.payload,
        );
      }
    } catch (_) {
      // Ignore on unsupported runtimes.
    }
    return null;
  }

  Future<AndroidNotificationSound?> _resolveAndroidSound(
    MedicationReminder reminder,
  ) async {
    if (!reminder.soundEnabled) return null;
    if (reminder.alarmSound == MedicationAlarmSound.systemAlarm) {
      _cachedSystemAlarmUri ??=
          await PlatformMedicationAlarmAudioPlayer.instance.getSystemAlarmUri();
      final uri = _cachedSystemAlarmUri;
      if (uri != null && uri.isNotEmpty) {
        return UriAndroidNotificationSound(uri);
      }
      return const RawResourceAndroidNotificationSound('alarm_classic');
    }
    return RawResourceAndroidNotificationSound(
      reminder.alarmSound.rawResourceName,
    );
  }

  String _channelNameFor(MedicationReminder reminder) {
    if (!reminder.soundEnabled) return '$_channelNamePrefix (Silent)';
    return '$_channelNamePrefix (${reminder.alarmSound.name})';
  }

  Future<NotificationDetails> _buildDetails(
    MedicationReminder reminder, {
    required String title,
    required String body,
    required String summaryText,
  }) async {
    final hasPhoto = !kIsWeb &&
        reminder.photoPath != null &&
        reminder.photoPath!.isNotEmpty &&
        File(reminder.photoPath!).existsSync();

    final StyleInformation styleInfo = hasPhoto
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(reminder.photoPath!),
            largeIcon: FilePathAndroidBitmap(reminder.photoPath!),
            contentTitle: title,
            summaryText: body.isNotEmpty ? body : summaryText,
            showBigPictureWhenCollapsed: true,
          )
        : BigTextStyleInformation(
            body.isNotEmpty ? body : summaryText,
            contentTitle: title,
            summaryText: summaryText,
          );

    final androidSound = await _resolveAndroidSound(reminder);

    final androidDetails = AndroidNotificationDetails(
      channelIdFor(reminder),
      _channelNameFor(reminder),
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
      autoCancel: true,
      visibility: NotificationVisibility.public,
      playSound: reminder.soundEnabled,
      sound: androidSound,
      additionalFlags: reminder.soundEnabled
          ? Int32List.fromList([_androidFlagInsistent])
          : null,
      enableVibration: reminder.vibrateEnabled,
      vibrationPattern: reminder.vibrateEnabled
          ? Int64List.fromList([0, 600, 300, 600, 300, 600])
          : null,
      largeIcon: hasPhoto ? FilePathAndroidBitmap(reminder.photoPath!) : null,
      styleInformation: styleInfo,
      color: reminder.category.accentColor,
      ticker: title,
    );

    final darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: reminder.soundEnabled,
      sound: reminder.soundEnabled ? reminder.alarmSound.iosSoundFileName : null,
      interruptionLevel: InterruptionLevel.timeSensitive,
      subtitle: summaryText,
      attachments: hasPhoto
          ? [DarwinNotificationAttachment(reminder.photoPath!)]
          : null,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  String _composeBody(
    MedicationReminder reminder, {
    required String categoryLabel,
    required String mealTimingLabel,
  }) {
    final parts = <String>[
      if (reminder.dosage.trim().isNotEmpty) reminder.dosage.trim(),
      if (reminder.mealTiming != MealTiming.anytime) mealTimingLabel,
      if (reminder.description.trim().isNotEmpty) reminder.description.trim(),
    ];
    if (parts.isEmpty) return categoryLabel;
    return parts.join(' • ');
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  @override
  Future<void> scheduleReminder(
    MedicationReminder reminder, {
    required String categoryLabel,
    required String mealTimingLabel,
  }) async {
    await cancelReminder(reminder.id);
    if (!reminder.enabled) return;

    try {
      await initialize();
      _ensureTimezone();
      final title = '${reminder.formattedTime} • ${reminder.title}';
      final body = _composeBody(
        reminder,
        categoryLabel: categoryLabel,
        mealTimingLabel: mealTimingLabel,
      );
      final details = await _buildDetails(
        reminder,
        title: title,
        body: body,
        summaryText: categoryLabel,
      );
      final days = reminder.weekdays.isEmpty
          ? MedicationReminder.allWeekdays
          : reminder.weekdays;

      for (final day in days) {
        final scheduledDate =
            _nextInstanceOfWeekday(day, reminder.hour, reminder.minute);
        await _plugin.zonedSchedule(
          id: notificationIdFor(reminder.id, day),
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: '$_payloadPrefix${reminder.id}',
        );
      }
    } catch (_) {
      // Fall back silently if exact alarms or platform channels are unavailable.
    }
  }

  @override
  Future<void> cancelReminder(String reminderId) async {
    try {
      await initialize();
      for (int slot = 1; slot <= 9; slot++) {
        await _plugin.cancel(id: notificationIdFor(reminderId, slot));
      }
    } catch (_) {
      // Ignore on unsupported runtimes.
    }
  }

  @override
  Future<void> scheduleSnooze(
    MedicationReminder reminder, {
    int minutes = 10,
    required String categoryLabel,
    required String snoozeBody,
  }) async {
    try {
      await initialize();
      _ensureTimezone();
      final snoozeTime =
          tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));
      final title = reminder.title;
      final body = reminder.description.trim().isNotEmpty
          ? '$snoozeBody — ${reminder.description.trim()}'
          : snoozeBody;
      final details = await _buildDetails(
        reminder,
        title: title,
        body: body,
        summaryText: categoryLabel,
      );
      await _plugin.zonedSchedule(
        id: notificationIdFor(reminder.id, 9),
        title: title,
        body: body,
        scheduledDate: snoozeTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '$_payloadPrefix${reminder.id}',
      );
    } catch (_) {
      // Ignore on unsupported runtimes.
    }
  }

  @override
  Future<void> showImmediateAlarmNotification(
    MedicationReminder reminder, {
    required String categoryLabel,
  }) async {
    try {
      await initialize();
      final title = '${reminder.formattedTime} • ${reminder.title}';
      final body = reminder.description.trim().isNotEmpty
          ? reminder.description.trim()
          : (reminder.dosage.trim().isNotEmpty
              ? reminder.dosage.trim()
              : categoryLabel);
      final details = await _buildDetails(
        reminder,
        title: title,
        body: body,
        summaryText: categoryLabel,
      );
      await _plugin.show(
        id: notificationIdFor(reminder.id, 8),
        title: title,
        body: body,
        notificationDetails: details,
        payload: '$_payloadPrefix${reminder.id}',
      );
    } catch (_) {
      // Ignore on unsupported runtimes.
    }
  }

  @override
  Future<void> syncAll(
    List<MedicationReminder> reminders, {
    required String Function(MedicationCategory) categoryLabelBuilder,
    required String Function(MealTiming) mealTimingLabelBuilder,
  }) async {
    for (final reminder in reminders) {
      await scheduleReminder(
        reminder,
        categoryLabel: categoryLabelBuilder(reminder.category),
        mealTimingLabel: mealTimingLabelBuilder(reminder.mealTiming),
      );
    }
  }
}
