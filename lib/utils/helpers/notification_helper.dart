import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'helpers.dart';

/// Shared notification helper functions that can be used in both
/// foreground (NotificationService) and background (isolate) contexts
@pragma('vm:entry-point')
class NotificationHelpers {

  /// Show advanced notification based on style type
  /// WORKS IN ALL APP STATES: foreground, background, and killed
  static Future<void> showAdvancedNotification(
      RemoteMessage message,
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    try {
      createLog("=== showAdvancedNotification called ===");
      createLog("Has notification object: ${message.notification != null}");
      createLog("Data payload: ${message.data}");

      // CRITICAL: Check if this is a hybrid message (notification + data)
      // If system already showed notification, skip to avoid duplicate
      if (message.notification != null) {
        createLog("âš ï¸ HYBRID message: System notification present - skipping custom to avoid duplicate");
        return;
      }

      final data = message.data;

      // If no data, nothing to show
      if (data.isEmpty) {
        createLog("❌ Empty data payload - nothing to show");
        return;
      }

      final type = data['style'] ?? 'basic';
      createLog("✅ DATA-ONLY message: Showing style='$type'");

      // Show notification with appropriate style
      switch (type) {
        case 'big_text':
          await showBigText(message, plugin);
          break;
        case 'big_picture':
          await showBigPicture(message, plugin);
          break;
        case 'inbox':
          await showInbox(message, plugin);
          break;
        case 'progress':
          await showProgress(message, plugin);
          break;
        case 'messaging':
          await showMessaging(message, plugin);
          break;
        case 'silent':
          await showSilent(message, plugin);
          break;
        case 'actions':
          await showWithActions(message, plugin);
          break;
        default:
          await showBasicNotification(message, plugin);
      }

      createLog("✅ Notification displayed successfully: style='$type'");
    } catch (e, stackTrace) {
      createLog("❌ Error in showAdvancedNotification: $e");
      createLog("Stack trace: $stackTrace");
      // Fallback to basic notification
      try {
        await showBasicNotification(message, plugin);
      } catch (fallbackError) {
        createLog("❌ Fallback notification also failed: $fallbackError");
      }
    }
  }

  /// Helper to get title from notification or data
  static String _getTitle(RemoteMessage message) {
    // Only use data fields, not notification object
    return message.data['title'] ?? 'Notification';
  }

  /// Helper to get body from notification or data
  static String _getBody(RemoteMessage message) {
    // Only use data fields, not notification object
    return message.data['body'] ?? '';
  }

  static Future<void> showWithActions(
      RemoteMessage message,
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    final actionsData = message.data['actions'];
    List<AndroidNotificationAction> actionButtons = [];

    if (actionsData != null) {
      try {
        final List<dynamic> parsed = jsonDecode(actionsData);
        for (var a in parsed) {
          actionButtons.add(
            AndroidNotificationAction(
              a['id'],
              a['title'],
              showsUserInterface: true,
              cancelNotification: true,
            ),
          );
        }
      } catch (e) {
        createLog("Error parsing actions: $e");
      }
    }

    final android = AndroidNotificationDetails(
      'action_channel',
      'Action Notifications',
      actions: actionButtons,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      // CRITICAL: Prevent auto-cancel to avoid ghost notifications
      autoCancel: true,
      ongoing: false,
    );

    await plugin.show(
      Random().nextInt(99999),
      _getTitle(message),
      _getBody(message),
      NotificationDetails(android: android),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showSilent(
      RemoteMessage message,
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    const android = AndroidNotificationDetails(
      'silent_channel',
      'Silent Notifications',
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
      enableVibration: false,
      icon: 'ic_notification',
      autoCancel: true,
      ongoing: false,
    );

    await plugin.show(
      Random().nextInt(99999),
      _getTitle(message),
      _getBody(message),
      const NotificationDetails(android: android),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showMessaging(
      RemoteMessage message,
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    final person = Person(name: message.data['sender'] ?? "User");

    final msg = Message(
      _getBody(message),
      DateTime.now(),
      person,
    );

    final messagingStyle = MessagingStyleInformation(person, messages: [msg]);

    final android = AndroidNotificationDetails(
      'msg_channel',
      'Messages',
      styleInformation: messagingStyle,
      priority: Priority.max,
      importance: Importance.max,
      icon: 'ic_notification',
      autoCancel: true,
      ongoing: false,
    );

    await plugin.show(
      Random().nextInt(99999),
      _getTitle(message),
      _getBody(message),
      NotificationDetails(android: android),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showInbox(
      RemoteMessage message,
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    createLog("Showing inbox ${message.data}");

    List<String> lines = [];

    try {
      if (message.data['lines'] != null) {
        String rawLines = message.data['lines'];
        var decodedLines = jsonDecode(rawLines);
        lines = List<String>.from(decodedLines);
      }
    } catch (e) {
      createLog("Error parsing inbox lines: $e");
      lines = ["New update available"];
    }

    final inbox = InboxStyleInformation(lines);

    final android = AndroidNotificationDetails(
      'inbox_channel',
      'Inbox Notifications',
      styleInformation: inbox,
      importance: Importance.high,
      priority: Priority.max,
      icon: 'ic_notification',
      autoCancel: true,
      ongoing: false,
    );

    await plugin.show(
      Random().nextInt(99999),
      _getTitle(message),
      _getBody(message),
      NotificationDetails(android: android),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showProgress(
      RemoteMessage message,
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    final progress = int.tryParse(message.data['progress'] ?? '0') ?? 0;

    final android = AndroidNotificationDetails(
      'progress_channel',
      'Progress Notifications',
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      indeterminate: false,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      autoCancel: true,
      ongoing: false,
    );

    await plugin.show(
      500, // static ID to update same notification
      _getTitle(message),
      _getBody(message),
      NotificationDetails(android: android),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showBigPicture(
      RemoteMessage message,
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    final imageUrl = message.data['image'];
    if (imageUrl == null) {
      return showBasicNotification(message, plugin);
    }

    try {
      final file = await _downloadAndSaveFile(imageUrl, 'banner.jpg');

      final bigPicture = BigPictureStyleInformation(
        FilePathAndroidBitmap(file),
      );

      final android = AndroidNotificationDetails(
        'big_picture_channel',
        'Image Notifications',
        styleInformation: bigPicture,
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notification',
        autoCancel: true,
        ongoing: false,
      );

      await plugin.show(
        Random().nextInt(99999),
        _getTitle(message),
        _getBody(message),
        NotificationDetails(android: android),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      createLog("Error showing big picture notification: $e");
      return showBasicNotification(message, plugin);
    }
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = Directory.systemTemp;
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    final response = await HttpClient().getUrl(Uri.parse(url));
    final bytes = await (await response.close())
        .fold<List<int>>([], (p, e) => p..addAll(e));
    await file.writeAsBytes(bytes);

    return filePath;
  }

  static Future<void> showBigText(
      RemoteMessage message,
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    final bigText = BigTextStyleInformation(
      _getBody(message),
    );

    final android = AndroidNotificationDetails(
      'big_text_channel',
      'Big Text Notifications',
      styleInformation: bigText,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      autoCancel: true,
      ongoing: false,
    );

    await plugin.show(
      Random().nextInt(99999),
      _getTitle(message),
      _getBody(message),
      NotificationDetails(android: android),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showBasicNotification(
      RemoteMessage message,
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Channel for important Firebase notifications.',
      importance: Importance.high,
    );

    int notificationId = Random.secure().nextInt(100000);

    final android = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.max,
      ticker: 'ticker',
      icon: 'ic_notification',
      // CRITICAL FIX: Add these properties to prevent ghost notifications
      autoCancel: true,
      ongoing: false,
      // Only vibrate and sound if not a silent notification
      playSound: true,
      enableVibration: true,
    );

    await plugin.show(
      notificationId,
      _getTitle(message),
      _getBody(message),
      NotificationDetails(android: android),
      payload: jsonEncode(message.data),
    );
  }

  /// Create all notification channels
  static Future<void> createNotificationChannels(
      FlutterLocalNotificationsPlugin plugin,
      ) async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Channel for important Firebase notifications.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        // CRITICAL: Don't show badge to avoid confusion
        showBadge: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'order_channel_id',
        'Order Notifications',
        description: 'Notification channel for order confirmations.',
        importance: Importance.max,
        showBadge: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'big_text_channel',
        'Big Text Notifications',
        importance: Importance.high,
        showBadge: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'big_picture_channel',
        'Image Notifications',
        importance: Importance.max,
        showBadge: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'inbox_channel',
        'Inbox Notifications',
        importance: Importance.high,
        showBadge: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'progress_channel',
        'Progress Notifications',
        importance: Importance.high,
        showBadge: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'msg_channel',
        'Messages',
        importance: Importance.max,
        showBadge: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'silent_channel',
        'Silent Notifications',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'action_channel',
        'Action Notifications',
        importance: Importance.high,
        showBadge: true,
      ),
    );
  }
}