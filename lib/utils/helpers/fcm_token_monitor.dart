import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kalyanboss/utils/helpers/helpers.dart';

/// Utility class to monitor and manage FCM token lifecycle
class FCMTokenMonitor {
  static final FCMTokenMonitor _instance = FCMTokenMonitor._internal();
  factory FCMTokenMonitor() => _instance;
  FCMTokenMonitor._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'fcm_token';
  static const String _tokenTimestampKey = 'fcm_token_timestamp';
  static const String _tokenSentKey = 'fcm_token_sent';
  static const String _appVersionKey = 'app_version';
  static const String _appBuildKey = 'app_version_build';

  /// Check if token needs to be re-sent (useful after app updates)
  Future<bool> shouldResendToken() async {
    try {
      final tokenSent = await _storage.read(key: _tokenSentKey);
      final storedToken = await _storage.read(key: _tokenKey);
      final currentToken = await FirebaseMessaging.instance.getToken();

      // Need to resend if:
      // 1. Never sent successfully
      // 2. Token changed
      // 3. Token is null in storage but exists now
      if (tokenSent != 'true') {
        createLog("Token never sent successfully");
        return true;
      }

      if (storedToken != currentToken) {
        createLog("Token changed: $storedToken -> $currentToken");
        return true;
      }

      if (storedToken == null && currentToken != null) {
        createLog("New token available");
        return true;
      }

      return false;
    } catch (e) {
      createLog("Error checking token status: $e");
      return true; // Safe default: resend if unsure
    }
  }

  /// Mark app version to detect updates
  /// Tracks both version name AND build number for complete detection
  Future<void> markAppVersion(String version, String buildNumber) async {
    try {
      final storedVersion = await _storage.read(key: _appVersionKey);
      final storedBuildKey = '${_appVersionKey}_build';
      final storedBuild = await _storage.read(key: storedBuildKey);

      final currentVersionInfo = '$version+$buildNumber';
      final storedVersionInfo = storedVersion != null && storedBuild != null
          ? '$storedVersion+$storedBuild'
          : null;

      // Check if EITHER version name OR build number changed
      if (storedVersion != version || storedBuild != buildNumber) {
        createLog("App updated: $storedVersionInfo -> $currentVersionInfo");
        createLog("Version change: $storedVersion -> $version");
        createLog("Build change: $storedBuild -> $buildNumber");

        // Mark token as needing resend after update
        await _storage.write(key: _tokenSentKey, value: 'false');
      } else {
        createLog("App version unchanged: $currentVersionInfo");
      }

      await _storage.write(key: _appVersionKey, value: version);
      await _storage.write(key: storedBuildKey, value: buildNumber);
    } catch (e) {
      createLog("Error marking app version: $e");
    }
  }

  /// Get token statistics for debugging
  Future<Map<String, dynamic>> getTokenStats() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final timestamp = await _storage.read(key: _tokenTimestampKey);
      final sent = await _storage.read(key: _tokenSentKey);
      final version = await _storage.read(key: _appVersionKey);
      final buildNumber = await _storage.read(key: _appBuildKey);
      final currentToken = await FirebaseMessaging.instance.getToken();

      return {
        'stored_token': token?.substring(0, 20) ?? 'null', // First 20 chars
        'current_token': currentToken?.substring(0, 20) ?? 'null',
        'tokens_match': token == currentToken,
        'timestamp': timestamp,
        'sent_successfully': sent == 'true',
        'app_version': version ?? 'unknown',
        'build_number': buildNumber ?? 'unknown',
        'version_info': '${version ?? 'unknown'}+${buildNumber ?? 'unknown'}',
        'last_sync': timestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp))
            .toString()
            : 'never',
      };
    } catch (e) {
      createLog("Error getting token stats: $e");
      return {'error': e.toString()};
    }
  }

  /// Force token refresh and resend
  Future<String?> forceTokenRefresh() async {
    try {
      createLog("Forcing token refresh...");

      // Delete existing token
      await FirebaseMessaging.instance.deleteToken();

      // Wait a bit
      await Future.delayed(const Duration(seconds: 2));

      // Get new token
      final newToken = await FirebaseMessaging.instance.getToken();

      if (newToken != null) {
        createLog("New token obtained: ${newToken.substring(0, 20)}...");

        // Mark as not sent so it will be sent again
        await _storage.write(key: _tokenSentKey, value: 'false');
        await _storage.write(key: _tokenKey, value: newToken);
        await _storage.write(
          key: _tokenTimestampKey,
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }

      return newToken;
    } catch (e) {
      createLog("Error forcing token refresh: $e");
      return null;
    }
  }

  /// Clear token data (useful for debugging)
  Future<void> clearTokenData() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _tokenTimestampKey);
      await _storage.delete(key: _tokenSentKey);
      createLog("Token data cleared");
    } catch (e) {
      createLog("Error clearing token data: $e");
    }
  }

  /// Perform complete token health check and sync
  Future<void> performTokenHealthCheck() async {
    try {
      createLog("=== FCM Token Health Check ===");

      // Get stats
      final stats = await getTokenStats();
      createLog("Token Stats: $stats");

      // Check if resend needed
      final shouldResend = await shouldResendToken();

      if (shouldResend) {
        createLog("âš ï¸ Token needs to be resent to backend");
        return; // The notification service will handle the actual sending
      } else {
        createLog("âœ… Token is up to date");
      }
    } catch (e) {
      createLog("Error in token health check: $e");
    }
  }
}