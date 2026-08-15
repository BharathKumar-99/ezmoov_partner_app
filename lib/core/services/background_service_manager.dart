import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'notification_service.dart';





class BackgroundServiceManager {
  BackgroundServiceManager._privateConstructor();
  static final BackgroundServiceManager instance = BackgroundServiceManager._privateConstructor();

  final FlutterBackgroundService _service = FlutterBackgroundService();
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  /// Initialize background service configuration
  Future<void> initialize() async {
    try {
      await NotificationService.instance.initialize();

      await _service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: _onStart,
          autoStart: false,
          isForegroundMode: true,
          notificationChannelId: 'ezmoov_driver_online_channel',
          initialNotificationTitle: 'EZMoov Partner Online',
          initialNotificationContent: 'Active & listening for incoming ride requests...',
          foregroundServiceNotificationId: 888,
          foregroundServiceTypes: [AndroidForegroundType.location],
        ),


        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: _onStart,
          onBackground: _onIosBackground,
        ),
      );
      debugPrint('✅ BackgroundServiceManager initialized.');
    } catch (e) {
      debugPrint('Notice initializing BackgroundServiceManager: $e');
    }
  }

  /// Start background service when driver goes ONLINE
  Future<void> startBackgroundService() async {
    try {
      await initialize();
      final isServiceRunning = await _service.isRunning();
      if (!isServiceRunning) {
        await _service.startService();
        _isRunning = true;
        debugPrint('🚀 Background Service started for Online Driver.');
      }
    } catch (e) {
      debugPrint('Notice starting background service: $e');
    }
  }

  /// Stop background service when driver goes OFFLINE
  Future<void> stopBackgroundService() async {
    try {
      final isServiceRunning = await _service.isRunning();
      if (isServiceRunning) {
        _service.invoke('stopService');
        _isRunning = false;
        debugPrint('🛑 Background Service stopped.');
      }
    } catch (e) {
      debugPrint('Notice stopping background service: $e');
    }
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    debugPrint('⚙️ Background isolate execution running...');

    try {
      await NotificationService.instance.initialize();
    } catch (e) {
      debugPrint('Notice initializing NotificationService in background isolate: $e');
    }

    Timer? periodicTimer;

    service.on('stopService').listen((event) {
      periodicTimer?.cancel();
      periodicTimer = null;
      service.stopSelf();
    });

    periodicTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: 'EZMoov Partner Online 🟢',
            content: 'GPS Tracking Active • Listening for ride requests...',
          );
        }
      }
    });
  }


  @pragma('vm:entry-point')
  static bool _onIosBackground(ServiceInstance service) {
    return true;
  }
}
