import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages local notifications for incoming community messages, checkup
/// reminders, and health announcements.
class HealthNotificationService {
  HealthNotificationService._();
  static final HealthNotificationService instance =
      HealthNotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel messageChannel =
      AndroidNotificationChannel(
    'visualcheckup_messages',
    'Sağlık Topluluğu Mesajları',
    description: 'Birebir doktor ve üye mesaj bildirimleri',
    importance: Importance.max,
  );

  static const AndroidNotificationChannel reminderChannel =
      AndroidNotificationChannel(
    'visualcheckup_reminders',
    'Sağlık ve İlaç Hatırlatıcıları',
    description: 'İlaç, su ve vital takip hatırlatmaları',
    importance: Importance.high,
  );

  bool _initialized = false;
  String? currentlyActiveChatId;

  /// In-app notification callback hook for snackbars / overlay banners when app is foregrounded
  void Function(String sender, String message, String? chatId)?
      onInAppNotification;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    try {
      await _localNotif.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('[Notification] Clicked: ${response.payload}');
        },
      );

      final androidImpl = _localNotif.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.createNotificationChannel(messageChannel);
        await androidImpl.createNotificationChannel(reminderChannel);
      }
      _initialized = true;
      debugPrint('[Notification] HealthNotificationService initialized.');
    } catch (e) {
      debugPrint('[Notification] Failed to initialize: $e');
    }
  }

  /// Triggers notification for incoming messages. If the user is currently
  /// active in the same chat screen, the notification is suppressed.
  Future<void> showMessageNotification({
    required String senderName,
    required String messageText,
    String? chatId,
  }) async {
    // Suppress if the user is currently viewing this conversation
    if (chatId != null && chatId == currentlyActiveChatId) {
      debugPrint('[Notification] Suppressed: User is currently active in chat $chatId');
      return;
    }

    if (onInAppNotification != null) {
      onInAppNotification!(senderName, messageText, chatId);
    }

    try {
      await initialize();
      const androidDetails = AndroidNotificationDetails(
        'visualcheckup_messages',
        'Sağlık Topluluğu Mesajları',
        channelDescription: 'Birebir doktor ve üye mesaj bildirimleri',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _localNotif.show(
        id: DateTime.now().millisecond,
        title: '💬 $senderName',
        body: messageText,
        notificationDetails: const NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
        ),
        payload: chatId,
      );
    } catch (e) {
      debugPrint('[Notification] Failed to show notification: $e');
    }
  }
}
