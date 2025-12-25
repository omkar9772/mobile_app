import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();

  String? _fcmToken;
  bool _notificationsEnabled = true;
  bool _isRegistered = false;

  String? get fcmToken => _fcmToken;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isRegistered => _isRegistered;

  /// Initialize notifications
  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      _fcmToken = _notificationService.fcmToken;

      // Set up token refresh listener
      _notificationService.setTokenRefreshCallback((newToken) {
        _fcmToken = newToken;
        registerDeviceToken(); // Auto-register when token refreshes
        notifyListeners();
      });

      // Auto-register device token after initialization
      if (_fcmToken != null) {
        await registerDeviceToken();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Register device token with backend
  Future<void> registerDeviceToken() async {
    if (_fcmToken == null) {
      debugPrint('⚠️ No FCM token available');
      return;
    }

    try {
      debugPrint('📤 Registering device token with backend...');

      // Determine platform
      String platform = 'web';
      if (!kIsWeb) {
        platform = Platform.isAndroid ? 'android' : 'ios';
      }

      final response = await _apiService.post(
        '/notifications/register-device',
        {
          'device_token': _fcmToken,
          'platform': platform,
        },
        withAuth: false, // Works for both authenticated and anonymous users
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _isRegistered = true;
        debugPrint('✅ Device token registered with backend (platform: $platform)');
        notifyListeners();
      } else {
        debugPrint('⚠️ Failed to register device token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error registering device token: $e');
      // Don't throw error - registration failure shouldn't break the app
    }
  }

  /// Unregister device token (call on logout)
  Future<void> unregisterDeviceToken() async {
    if (_fcmToken == null) return;

    try {
      debugPrint('📤 Unregistering device token from backend...');

      // Call backend to unregister the token using DELETE
      final response = await _apiService.delete(
        '/notifications/unregister-device',
        body: {
          'device_token': _fcmToken,
        },
        withAuth: false,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ Device token unregistered from backend');
      }

      // Delete token from Firebase
      await _notificationService.deleteToken();
      _fcmToken = null;
      _isRegistered = false;
      debugPrint('✅ FCM token deleted locally');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error unregistering device token: $e');
      // Still delete local token even if backend call fails
      await _notificationService.deleteToken();
      _fcmToken = null;
      _isRegistered = false;
      notifyListeners();
    }
  }

  /// Toggle notifications on/off
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();

    if (enabled) {
      // Subscribe to all races topic
      _notificationService.subscribeToTopic('all_races');
    } else {
      // Unsubscribe from all races topic
      _notificationService.unsubscribeFromTopic('all_races');
    }
  }

  /// Subscribe to race notifications
  Future<void> subscribeToRaceNotifications() async {
    await _notificationService.subscribeToTopic('all_races');
    debugPrint('✅ Subscribed to race notifications');
  }

  /// Unsubscribe from race notifications
  Future<void> unsubscribeFromRaceNotifications() async {
    await _notificationService.unsubscribeFromTopic('all_races');
    debugPrint('✅ Unsubscribed from race notifications');
  }
}
