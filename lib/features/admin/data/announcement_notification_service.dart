import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';

/// Dispatches on-device system notifications for published [GlobalAnnouncement]s
/// and deduplicates them in [SharedPreferences] so each announcement notifies
/// the device once.
class AnnouncementNotificationService {
  AnnouncementNotificationService._();

  static final AnnouncementNotificationService instance =
      AnnouncementNotificationService._();

  static const String _notifiedIdsKey = 'visualcheckup_notified_ann_ids_v1';
  static const String _channelId = 'visualcheckup_announcements_v1';
  static const String _channelName = 'Health Announcements & Tips';
  static const String _channelDesc =
      'Important health announcements and useful wellness tips from VisualCheckUp';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Optional test hook invoked whenever an announcement notification fires.
  @visibleForTesting
  void Function(GlobalAnnouncement announcement)? onNotifyForTest;

  int _notificationIdFor(String announcementId) {
    int hash = 5381;
    for (int i = 0; i < announcementId.length; i++) {
      hash = ((hash << 5) + hash + announcementId.codeUnitAt(i)) & 0x07FFFFFF;
    }
    return 900000 + (hash % 90000);
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
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
      await _plugin.initialize(settings: settings);
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
      }
      _initialized = true;
    } catch (_) {
      // Gracefully ignore in widget tests or unsupported desktop environments.
    }
  }

  /// Displays a local notification for [announcement] if this device has not
  /// yet been notified about its ID (or if [force] is true).
  Future<bool> notifyIfNew(
    GlobalAnnouncement announcement, {
    bool force = false,
  }) async {
    if (!announcement.isActive || announcement.id.trim().isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final notified =
        (prefs.getStringList(_notifiedIdsKey) ?? const <String>[]).toSet();
    if (!force && notified.contains(announcement.id)) {
      return false;
    }

    notified.add(announcement.id);
    // Keep only the most recent 60 IDs to avoid unbounded preference growth.
    final trimmed = notified.toList();
    if (trimmed.length > 60) {
      trimmed.removeRange(0, trimmed.length - 60);
    }
    await prefs.setStringList(_notifiedIdsKey, trimmed);

    onNotifyForTest?.call(announcement);

    final formattedTitle =
        '${announcement.effectiveEmoji} ${announcement.title}'.trim();
    final body = announcement.message.trim();

    try {
      await _ensureInitialized();
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: formattedTitle,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      await _plugin.show(
        id: _notificationIdFor(announcement.id),
        title: formattedTitle,
        body: body,
        notificationDetails: details,
        payload: 'announcement:${announcement.id}',
      );
    } catch (_) {
      // Platform channel unavailable in tests; test hook & prefs already ran.
    }
    return true;
  }

  /// Notifies the device about the newest active announcement if unseen.
  Future<bool> notifyLatestActive(List<GlobalAnnouncement> activeList) async {
    if (activeList.isEmpty) return false;
    final active = activeList.where((a) => a.isActive).toList();
    if (active.isEmpty) return false;
    return notifyIfNew(active.first);
  }
}
