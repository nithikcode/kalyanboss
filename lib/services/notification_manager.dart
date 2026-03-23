import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';
import '../config/routes/route_names.dart';
import '../config/routes/routes.dart';
import '../utils/di/service_locator.dart';
import '../utils/helpers/helpers.dart';
import '../utils/helpers/notification_helper.dart';
import '../utils/network/network_api_service.dart';

class NotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'fcm_token';
  static const String _tokenTimestampKey = 'fcm_token_timestamp';
  static const String _tokenSentKey = 'fcm_token_sent';

  static const AndroidNotificationChannel fcmChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Channel for important Firebase notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
    'order_channel_id',
    'Order Notifications',
    description: 'Notification channel for order confirmations.',
    importance: Importance.max,
  );

  Future<void> init() async {
    await _initLocalNotifications();

    firebaseInit();

    // Clear badges when app starts
    await clearAllBadges();

    // Check and sync token on app start
    await _syncTokenOnStartup();

    // Handle notification taps when app was terminated
    final details = await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      final response = details.notificationResponse;

      // Clear badges when notification is tapped from terminated state
      await clearAllBadges();

      if (response?.payload != null) {
        try {
          final Map<String, dynamic> payloadData =
          json.decode(response!.payload!);

          if (response.actionId == 'track') {
            final orderId = payloadData['orderId'];
            final mobile = payloadData['mobile'];

            Future.delayed(const Duration(milliseconds: 500), () {
              navigatorKey.currentState?.pushNamed(
                RouteNames.orderInfoScreen,
                arguments: {
                  'orderId': orderId,
                  'phone': mobile,
                },
              );
            });
          } else if (response.actionId == 'support') {
            Future.delayed(const Duration(milliseconds: 500), () {
              navigatorKey.currentState?.pushNamed(RouteNames.support);
            });
          } else if (payloadData['type'] == 'order_details') {
            Future.delayed(const Duration(milliseconds: 500), () {
              navigatorKey.currentState?.pushNamed(
                RouteNames.orderInfoScreen,
                arguments: {
                  'orderId': payloadData['orderId'],
                  'phone': payloadData['phone'],
                },
              );
            });
          }
        } catch (e) {
          createLog('Error handling launch payload: $e');
        }
      }
    }

    // Clear badges when notification is tapped from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      createLog('Notification tapped while in background: ${message.data}');
      await clearAllBadges();
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
      if (message != null) {
        createLog('App launched from terminated state by notification: ${message.data}');
        await clearAllBadges();
      }
    });
  }

  /// Clear all notification badges
  Future<void> clearAllBadges() async {
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        // Cancel all notifications to clear badges
        await _flutterLocalNotificationsPlugin.cancelAll();
        createLog("✅ All notification badges cleared (Android)");
      } else if (Platform.isIOS) {
        // For iOS, set badge count to 0
        final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

        // Clear badge count
        await _flutterLocalNotificationsPlugin.cancelAll();

        // Also reset Firebase badge count
        await firebaseMessaging.setAutoInitEnabled(true);
        createLog("✅ All notification badges cleared (iOS)");
      }
    } catch (e) {
      createLog("❌ Error clearing badges: $e");
    }
  }

  /// Sync token on app startup - critical for updates
  Future<void> _syncTokenOnStartup() async {
    try {
      final currentToken = await firebaseMessaging.getToken();
      if (currentToken == null) {
        createLog("Token is null on startup");
        return;
      }

      final storedToken = await _storage.read(key: _tokenKey);
      final tokenSent = await _storage.read(key: _tokenSentKey);

      // Token changed OR never sent successfully
      if (storedToken != currentToken || tokenSent != 'true') {
        createLog("Token needs sync: stored=$storedToken, current=$currentToken, sent=$tokenSent");
        await sendTokenToBackend(currentToken);
        await _storage.write(key: _tokenKey, value: currentToken);
        await _storage.write(
          key: _tokenTimestampKey,
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      } else {
        createLog("Token already synced");
      }
    } catch (e) {
      createLog("Error syncing token on startup: $e");
    }
  }

  /// Verify token periodically (call this from splash or home screen)
  Future<void> verifyAndSyncToken() async {
    try {
      final currentToken = await firebaseMessaging.getToken();
      if (currentToken == null) return;

      final storedToken = await _storage.read(key: _tokenKey);
      final timestampStr = await _storage.read(key: _tokenTimestampKey);

      // If token changed or not synced in last 7 days, re-sync
      final shouldSync = storedToken != currentToken ||
          timestampStr == null ||
          _shouldResyncBasedOnTime(timestampStr);

      if (shouldSync) {
        createLog("Re-syncing token (periodic check)");
        await sendTokenToBackend(currentToken);
        await _storage.write(key: _tokenKey, value: currentToken);
        await _storage.write(
          key: _tokenTimestampKey,
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }
    } catch (e) {
      createLog("Error in periodic token verification: $e");
    }
  }

  bool _shouldResyncBasedOnTime(String timestampStr) {
    try {
      final timestamp = int.parse(timestampStr);
      final lastSync = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final daysSinceSync = DateTime.now().difference(lastSync).inDays;
      return daysSinceSync >= 7; // Re-sync every 7 days
    } catch (e) {
      return true; // If parsing fails, force sync
    }
  }

  Future<void> requestLocalNotificationPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<NotificationSettings> requestNotificationPermissions(
      BuildContext context) async {
    try {
      NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        carPlay: false,
        badge: true,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        createLog("User granted notification permission");
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        createLog("User granted provisional permission");
      } else {
        createLog("User denied permission");
      }
      return settings;
    } catch (e) {
      createLog("Error requesting notification permissions: $e");
      return const NotificationSettings(
        authorizationStatus: AuthorizationStatus.denied,
        alert: AppleNotificationSetting.disabled,
        announcement: AppleNotificationSetting.disabled,
        badge: AppleNotificationSetting.disabled,
        carPlay: AppleNotificationSetting.disabled,
        criticalAlert: AppleNotificationSetting.disabled,
        lockScreen: AppleNotificationSetting.disabled,
        notificationCenter: AppleNotificationSetting.disabled,
        showPreviews: AppleShowPreviewSetting.notSupported,
        sound: AppleNotificationSetting.disabled,
        timeSensitive: AppleNotificationSetting.disabled,
        providesAppNotificationSettings: AppleNotificationSetting.enabled,
      );
    }
  }

  Future<void> _initLocalNotifications() async {
    var androidInitialization =
    const AndroidInitializationSettings("ic_notification");
    var iosInitialization = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        createLog("payload raw = ${response.payload}");

        // Clear badges when any notification is tapped
        await clearAllBadges();

        if (response.payload != null) {
          final data = jsonDecode(response.payload!);

          if (data == null) {
            return;
          }

          final orderId = data['orderId'];
          final mobile = data['mobile'];
          final type = data['type'];

          if(type == "order_details"){
            navigatorKey.currentState?.pushNamed(
              RouteNames.orderInfoScreen,
              arguments: {
                "orderId": orderId,
                "phone": mobile,
              },
            );
          }

          if (response.actionId == 'track') {
            navigatorKey.currentState?.pushNamed(
              RouteNames.orderInfoScreen,
              arguments: {
                "orderId": orderId,
                "phone": mobile,
              },
            );
          }

          if (response.actionId == 'support') {
            navigatorKey.currentState?.pushNamed(RouteNames.support);
          }
        }
      },
    );

    await NotificationHelpers.createNotificationChannels(
      _flutterLocalNotificationsPlugin,
    );
  }

  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        createLog("notification data ========> ${message.data}");
        createLog("notification body ========> ${message.notification?.body}");
      }

      NotificationHelpers.showAdvancedNotification(
        message,
        _flutterLocalNotificationsPlugin,
      );
    });
  }

  Future<void> showAdvancedNotification(RemoteMessage message) async {
    await NotificationHelpers.showAdvancedNotification(
      message,
      _flutterLocalNotificationsPlugin,
    );
  }

  /// Enhanced token sending with better error handling and status tracking
  Future<void> sendTokenToBackend(String token, {String? userId}) async {
    try {
      createLog("Sending FCM token to backend...");

      final result = await sl<NetworkServicesApi>().postApi(
        '${AppUrl.baseUrl}/appToken',
        {
          'token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (result.statusCode == 200 || result.statusCode == 201) {
        // Mark as successfully sent
        await _storage.write(key: _tokenSentKey, value: 'true');
        createLog("FCM Token successfully sent/updated on backend. ${result.body}");
      } else {
        // Failed, mark as not sent
        await _storage.write(key: _tokenSentKey, value: 'false');
        createLog("Backend returned non-success: ${result.statusCode}");
      }
    } catch (e) {
      // Failed, mark as not sent
      await _storage.write(key: _tokenSentKey, value: 'false');
      createLog("Error sending FCM token to backend: $e");

      // Schedule retry
      _scheduleTokenRetry(token);
    }
  }

  /// Schedule a retry for token sending
  void _scheduleTokenRetry(String token) {
    Future.delayed(const Duration(seconds: 30), () async {
      try {
        await sendTokenToBackend(token);
      } catch (e) {
        createLog("Token retry failed: $e");
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    await NotificationHelpers.showBasicNotification(
      message,
      _flutterLocalNotificationsPlugin,
    );
  }

  Future<void> showOrderConfirmationNotification({
    String? orderId,
    String? customerId,
    String? phone,
  }) async {
    final Map<String, dynamic> payloadData = {
      'type': 'order_details',
      'orderId': orderId ?? '',
      'mobile': phone ?? '',
    };

    final String payload = json.encode(payloadData);

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'order_channel_id',
      'Order Notifications',
      channelDescription: 'Notification channel for order confirmations.',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification',
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      99,
      'Order Placed!',
      'Your order #${orderId ?? ''} is being processed.',
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<String?> getDeviceToken() async {
    try {
      String? token = await firebaseMessaging.getToken();
      if (token == null) {
        createLog("FCM token is null");
        return null;
      }
      return token;
    } catch (e) {
      createLog("Error getting device token: $e");
      return null;
    }
  }
}