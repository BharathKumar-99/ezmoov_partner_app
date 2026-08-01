import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'supabase_service.dart';

class LocationService {
  LocationService._privateConstructor();
  static final LocationService instance = LocationService._privateConstructor();

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  /// Check location permissions and request if needed
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('⚠️ Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('⚠️ Location permissions are denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('⚠️ Location permissions are permanently denied.');
      return false;
    }

    return true;
  }

  /// Get current device position (with fallback)
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _currentPosition;
    } catch (e) {
      debugPrint('Notice getting current position: $e');
      return null;
    }
  }

  /// Start live continuous location streaming to Supabase for an online driver
  void startLocationTracking({
    required String driverId,
    Function(double lat, double lng)? onLocationChanged,
  }) async {
    stopLocationTracking();

    final hasPermission = await checkPermission();
    if (!hasPermission) return;

    // Fetch initial position
    final initialPos = await getCurrentPosition();
    if (initialPos != null) {
      _currentPosition = initialPos;
      onLocationChanged?.call(initialPos.latitude, initialPos.longitude);
      await SupabaseService.instance.updateDriverLocation(
        driverId,
        initialPos.latitude,
        initialPos.longitude,
      );
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update location every 10 meters moved
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) async {
        _currentPosition = position;
        onLocationChanged?.call(position.latitude, position.longitude);

        try {
          await SupabaseService.instance.updateDriverLocation(
            driverId,
            position.latitude,
            position.longitude,
          );
        } catch (e) {
          debugPrint('Notice streaming driver location: $e');
        }
      },
      onError: (error) {
        debugPrint('⚠️ Location stream error: $error');
      },
    );

    debugPrint('📡 Live GPS Tracking started for driver: $driverId');
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    debugPrint('🛑 Live GPS Tracking stopped.');
  }
}
