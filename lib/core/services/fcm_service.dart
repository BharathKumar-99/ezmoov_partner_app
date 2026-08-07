import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'supabase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

class FcmService {
  FcmService._internal();
  static final FcmService instance = FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? _currentUserId;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    try {
      // Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request notification permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User notification permission status: ${settings.authorizationStatus}');

      // Enable foreground notification presentation options
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get initial token
      _fcmToken = await _fcm.getToken();
      debugPrint('Initial FCM Token: $_fcmToken');

      // Listen for token updates
      _fcm.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        debugPrint('FCM Token refreshed: $newToken');
        if (_currentUserId != null) {
          await saveUserFcmToken(_currentUserId!);
        }
      });

      // Listen for foreground messages & show heads-up banner
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground FCM message received: ${message.notification?.title}');
        final notification = message.notification;
        final title = notification?.title ?? message.data['title'] ?? 'EZMoov Partner Alert';
        final body = notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

        if (title.isNotEmpty || body.isNotEmpty) {
          NotificationService.instance.showNotification(
            title: title,
            body: body,
            payload: message.data.toString(),
          );
        }
      });

      // Listen for notification tap / app open
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened from FCM notification: ${message.data}');
      });
    } catch (e) {
      debugPrint('Error initializing FCM service: $e');
    }
  }

  /// Save FCM token to Supabase for given user ID
  Future<void> saveUserFcmToken(String userId) async {
    _currentUserId = userId;

    try {
      _fcmToken ??= await _fcm.getToken();

      if (_fcmToken == null || _fcmToken!.isEmpty) {
        debugPrint('FCM token is empty or null, skipping database save.');
        return;
      }

      final deviceType = kIsWeb
          ? 'web'
          : Platform.isAndroid
              ? 'android'
              : Platform.isIOS
                  ? 'ios'
                  : 'other';

      await SupabaseService.instance.saveUserFcmToken(
        userId: userId,
        fcmToken: _fcmToken!,
        type: 'driver',
        device: deviceType,
      );
    } catch (e) {
      debugPrint('Error in FcmService.saveUserFcmToken: $e');
    }
  }
}
