import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineTripService {
  static const String _keyActiveBookingId = 'active_booking_id';
  static const String _keyActiveTripStatus = 'active_trip_status';
  static const String _keyActiveDriverId = 'active_driver_id';

  OfflineTripService._privateConstructor();
  static final OfflineTripService instance = OfflineTripService._privateConstructor();

  /// Save active trip state locally
  Future<void> saveActiveTrip({
    required String bookingId,
    required String status,
    required String driverId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyActiveBookingId, bookingId);
      await prefs.setString(_keyActiveTripStatus, status);
      await prefs.setString(_keyActiveDriverId, driverId);
      debugPrint('💾 Offline active trip saved: #$bookingId (Status: $status)');
    } catch (e) {
      debugPrint('Notice saving offline trip state: $e');
    }
  }

  /// Get active trip details if saved
  Future<Map<String, String>?> getActiveTrip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingId = prefs.getString(_keyActiveBookingId);
      final status = prefs.getString(_keyActiveTripStatus);
      final driverId = prefs.getString(_keyActiveDriverId);

      if (bookingId != null && bookingId.isNotEmpty) {
        return {
          'bookingId': bookingId,
          'status': status ?? 'accepted',
          'driverId': driverId ?? '',
        };
      }
    } catch (e) {
      debugPrint('Notice reading offline trip state: $e');
    }
    return null;
  }

  /// Clear offline trip state when completed or cancelled
  Future<void> clearActiveTrip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyActiveBookingId);
      await prefs.remove(_keyActiveTripStatus);
      await prefs.remove(_keyActiveDriverId);
      debugPrint('🗑️ Offline active trip cleared.');
    } catch (e) {
      debugPrint('Notice clearing offline trip state: $e');
    }
  }
}
