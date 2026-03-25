import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kalyanboss/features/auth/domain/usecases/update_user_use_case.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/services/session_manager.dart';
import '../config/constants.dart';
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

  /// Pass AuthBloc here so we can update the backend if the token refreshes
  Future<void> init({required AuthBloc authBloc}) async {
    await _initLocalNotifications();

    firebaseInit(authBloc: authBloc);

    // Clear badges when app starts
    await clearAllBadges();

    // Check and sync token on app start
    await _syncTokenOnStartup();

    // 1. Handle notification taps when app is launched from TERMINATED state
    final details = await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      final response = details.notificationResponse;
      await clearAllBadges();

      if (response?.payload != null) {
        _handleNotificationClick(response!.payload);
      }
    }

    // 2. Handle notification taps when app is in BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      createLog('Notification tapped while in background: ${message.data}');
      await clearAllBadges();

      // Pass the data map as a JSON string to our unified handler
      _handleNotificationClick(jsonEncode(message.data));
    });

    // 3. Fallback for terminated state from Firebase directly
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
      if (message != null) {
        createLog('App launched from terminated state by Firebase: ${message.data}');
        await clearAllBadges();
        _handleNotificationClick(jsonEncode(message.data));
      }
    });
  }

  /// Unified Handler for ALL Notification Clicks using GoRouter
  void _handleNotificationClick(String? payload) {
    if (payload == null) return;

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final String? type = data['type'];

      createLog('Handling notification click with payload: $data');

      // // Use GoRouter for navigation
      // if (type == 'order_details' || type == 'track') {
      //   // Example of passing arguments via GoRouter 'extra'
      //   // Ensure your GoRoute is set up to receive this map
      //   AppRouter.router.pushNamed(
      //     RouteNames.orderInfoScreen, // Make sure this matches your router
      //     extra: {
      //       'orderId': data['orderId'],
      //       'phone': data['mobile'] ?? data['phone'],
      //     },
      //   );
      // } else if (type == 'support' || data['actionId'] == 'support') {
      //   AppRouter.router.pushNamed(RouteNames.support); // Match your GoRoute name
      // } else if (type == 'game_update') {
      //   AppRouter.router.pushNamed(RouteNames.gameScreen);
      // }

    } catch (e) {
      createLog('Error parsing notification payload: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    var androidInitialization = const AndroidInitializationSettings("@mipmap/ic_launcher");    var iosInitialization = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // 4. Handle notification taps when app is in FOREGROUND
      onDidReceiveNotificationResponse: (response) async {
        createLog("Foreground notification tapped. Payload raw = ${response.payload}");
        await clearAllBadges();
        _handleNotificationClick(response.payload);
      },
    );

    await NotificationHelpers.createNotificationChannels(
        _flutterLocalNotificationsPlugin);
  }

  void firebaseInit({AuthBloc? authBloc}) {
    // Listen for Token Refresh from Firebase
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      createLog("FCM Token Refreshed: $newToken");

      // Keep the local generic backend updated
      sendTokenToBackend(newToken);

      // Also update the specific user's entity via BLoC if logged in
      if (authBloc != null) {
        authBloc.add(UpdateUserEvent(fcm: newToken, fullName: null));
      }
    });

    // Listen for messages while app is open and in foreground
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

  /// Clear all notification badges
  Future<void> clearAllBadges() async {
    try {
      if (Platform.isAndroid) {
        await _flutterLocalNotificationsPlugin.cancelAll();
        createLog("✅ All notification badges cleared (Android)");
      } else if (Platform.isIOS) {
        await _flutterLocalNotificationsPlugin.cancelAll();
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

      if (storedToken != currentToken || tokenSent != 'true') {
        createLog("Token needs sync");
        await sendTokenToBackend(currentToken);
        await _storage.write(key: _tokenKey, value: currentToken);
        await _storage.write(
          key: _tokenTimestampKey,
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }
    } catch (e) {
      createLog("Error syncing token on startup: $e");
    }
  }

  /// Verify token periodically
  Future<void> verifyAndSyncToken() async {
    try {
      final currentToken = await firebaseMessaging.getToken();
      if (currentToken == null) return;

      final storedToken = await _storage.read(key: _tokenKey);
      final timestampStr = await _storage.read(key: _tokenTimestampKey);

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
      return daysSinceSync >= 7;
    } catch (e) {
      return true;
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

  Future<NotificationSettings> requestNotificationPermissions(BuildContext context) async {
    try {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        carPlay: false,
        badge: true,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
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

  Future<void> showAdvancedNotification(RemoteMessage message) async {
    await NotificationHelpers.showAdvancedNotification(
      message,
      _flutterLocalNotificationsPlugin,
    );
  }

  Future<void> sendTokenToBackend(String token, {String? userId}) async {
    try {
      createLog("Sending FCM token to backend...");

      // 1. Prepare the data (only sending what's needed)
      final requestData = {
        // 'id': userId ?? sl<SessionManager>().getUserId,
        'fcm': token,
        // 'platform': Platform.isAndroid ? 'android' : 'ios',
      };

      // 2. Call the UseCase directly (sl should have UpdateUserUseCase registered)
      final result = await sl<UpdateUserUseCase>().call(requestData);

      // 3. Handle the Either (Left: Success, Right: Failure)
      await result.fold(
            (successResponse) async {
          await _storage.write(key: _tokenSentKey, value: 'true');
          createLog("✅ FCM Token successfully synced via UseCase.");

          // Optional: Trigger a fetch profile in the Bloc to keep UI in sync
          sl<AuthBloc>().add(FetchProfileEvent());
        },
            (failure) async {
          await _storage.write(key: _tokenSentKey, value: 'false');
          createLog("❌ Failed to sync token: ${failure.message}");
          _scheduleTokenRetry(token);
        },
      );
    } catch (e) {
      createLog("❌ Exception in sendTokenToBackend: $e");
      await _storage.write(key: _tokenSentKey, value: 'false');
      _scheduleTokenRetry(token);
    }
  }

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
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
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
      return await firebaseMessaging.getToken();
    } catch (e) {
      createLog("Error getting device token: $e");
      return null;
    }
  }
}