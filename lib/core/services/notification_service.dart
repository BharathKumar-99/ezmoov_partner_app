import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize local notification channels
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('🔔 Notification tapped: ${response.payload}');
        },
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        const AndroidNotificationChannel onlineChannel = AndroidNotificationChannel(
          'ezmoov_driver_online_channel',
          'EZMoov Driver Online Service',
          description: 'Persistent notification for active online driver background service',
          importance: Importance.low,
        );

        const AndroidNotificationChannel incomingRideChannel = AndroidNotificationChannel(
          'incoming_ride_channel',
          'Incoming Ride Requests',
          description: 'High-priority notifications for incoming driver ride requests',
          importance: Importance.max,
        );

        await androidPlugin.createNotificationChannel(onlineChannel);
        await androidPlugin.createNotificationChannel(incomingRideChannel);
        await androidPlugin.requestNotificationsPermission();
      }

      _isInitialized = true;
      debugPrint('✅ Local Notification Service initialized with channels.');
    } catch (e) {
      debugPrint('Notice initializing NotificationService: $e');
    }
  }



  /// Trigger heads-up notification for FCM message
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'incoming_ride_channel',
      'Incoming Ride Requests',
      channelDescription: 'High-priority notifications for incoming driver ride requests',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
      debugPrint('🔔 System Heads-Up Notification triggered: $title');
    } catch (e) {
      debugPrint('Notice showing FCM notification: $e');
    }
  }

  /// Trigger high-priority heads-up notification for an incoming ride request
  Future<void> showIncomingRideNotification({
    required String bookingId,
    required String pickupAddress,
    required double fare,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'incoming_ride_channel',
      'Incoming Ride Requests',
      channelDescription: 'High-priority notifications for incoming driver ride requests',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.call,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        bookingId.hashCode,
        '⚡ INCOMING RIDE REQUEST (₹${fare.toStringAsFixed(0)})',
        'Pickup: $pickupAddress',
        details,
        payload: bookingId,
      );
      debugPrint('🔔 System Heads-Up Notification triggered for booking #$bookingId');
    } catch (e) {
      debugPrint('Notice showing incoming ride notification: $e');
    }
  }

  /// Cancel all active notifications
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Notice cancelling notifications: $e');
    }
  }
}
