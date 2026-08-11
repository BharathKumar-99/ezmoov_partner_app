import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/supabase_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/offline_trip_service.dart';
import '../core/services/notification_service.dart';
import '../models/booking_model.dart';

import '../views/home/widgets/incoming_ride_dialog.dart';

class RideRequestViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final AudioService _audioService = AudioService.instance;
  final OfflineTripService _offlineTripService = OfflineTripService.instance;

  StreamSubscription<List<BookingModel>>? _subscription;
  Timer? _pollingTimer;

  BookingModel? _activeBroadcastBooking;
  BookingModel? get activeBroadcastBooking => _activeBroadcastBooking;

  BookingModel? _activeDriverTrip;
  BookingModel? get activeDriverTrip => _activeDriverTrip;

  bool _isAccepting = false;
  bool get isAccepting => _isAccepting;

  bool _isModalOpen = false;

  final Set<String> _declinedBookingIds = {};
  Set<String> get declinedBookingIds => _declinedBookingIds;

  /// Explicitly decline a ride request so it is never shown again to this driver
  void declineRide(String bookingId) {
    if (bookingId.isEmpty) return;
    _declinedBookingIds.add(bookingId);
    _audioService.stopAlert();
    if (_activeBroadcastBooking?.id == bookingId) {
      _activeBroadcastBooking = null;
    }
    _isModalOpen = false;
    notifyListeners();
  }

  /// Haversine formula to calculate distance in km between two GPS coordinates
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    if (lat1 == 0.0 || lon1 == 0.0 || lat2 == 0.0 || lon2 == 0.0) return 0.0;
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R * asin(...)
  }

  /// Clear active driver trip when booking is completed or cancelled
  void clearActiveDriverTrip() {
    _activeDriverTrip = null;
    _offlineTripService.clearActiveTrip();
    notifyListeners();
  }

  /// Check if the driver currently has an active trip ('accepted', 'arrived', 'in_transit', 'drop_complete', 'amount_paid')
  Future<void> checkActiveDriverTrip(String driverId) async {
    if (driverId.isEmpty) return;
    try {
      final activeBooking =
          await _supabaseService.getActiveDriverBooking(driverId);
      if (_activeDriverTrip?.id != activeBooking?.id ||
          _activeDriverTrip?.status != activeBooking?.status) {
        _activeDriverTrip = activeBooking;
        if (activeBooking != null && activeBooking.id.isNotEmpty) {
          await _offlineTripService.saveActiveTrip(
            bookingId: activeBooking.id,
            status: activeBooking.status,
            driverId: driverId,
          );
        } else {
          await _offlineTripService.clearActiveTrip();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Notice checking active driver trip: $e');
    }
  }

  /// Restore active trip on app launch if app was restarted during a trip
  Future<void> restoreActiveTripOnLaunch(
      String driverId, BuildContext context) async {
    if (driverId.isEmpty) return;
    try {
      final offlineTrip = await _offlineTripService.getActiveTrip();
      final activeBooking =
          await _supabaseService.getActiveDriverBooking(driverId);

      final bookingToRestore = activeBooking ??
          (offlineTrip != null
              ? await _supabaseService.getBookingById(offlineTrip['bookingId']!)
              : null);

      if (bookingToRestore != null &&
          ['accepted', 'arrived', 'in_transit', 'drop_complete', 'amount_paid']
              .contains(bookingToRestore.status)) {
        _activeDriverTrip = bookingToRestore;
        await _offlineTripService.saveActiveTrip(
          bookingId: bookingToRestore.id,
          status: bookingToRestore.status,
          driverId: driverId,
        );
        notifyListeners();

        if (context.mounted) {
          _showSnackBar(context, '🔄 Restored active trip navigation');
          GoRouter.of(context).go('/driver/pickup/${bookingToRestore.id}');
        }
      }
    } catch (e) {
      debugPrint('Notice restoring active trip on launch: $e');
    }
  }

  /// Start Realtime Broadcast Stream and 3s Polling Fallback for online driver
  void startBroadcastListening({
    required String driverId,
    required double driverLat,
    required double driverLng,
    required BuildContext context,
  }) {
    stopBroadcastListening();

    debugPrint(
        '📡 Starting Realtime Broadcast Stream & 3s Polling for driver $driverId at ($driverLat, $driverLng)...');

    // Initial check for active driver trip
    checkActiveDriverTrip(driverId);

    // 1. Realtime Stream Subscription
    try {
      _subscription = _supabaseService.subscribeToBookingsStream().listen(
        (bookings) {
          if (context.mounted) {
            _processBookingsList(
                bookings, driverId, driverLat, driverLng, context);
          }
        },
        onError: (error) {
          debugPrint('⚠️ Stream subscription notice: $error');
        },
      );
    } catch (e) {
      debugPrint('⚠️ Error attaching stream: $e');
    }

    // 2. 3-Second Polling Fallback Timer
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        await checkActiveDriverTrip(driverId);

        final searchingBookings = await _supabaseService.getSearchingBookings();
        if (!context.mounted) return;

        if (searchingBookings.isNotEmpty) {
          _processBookingsList(
              searchingBookings, driverId, driverLat, driverLng, context);
        } else if (_activeBroadcastBooking != null) {
          // If active booking was cancelled or taken in DB
          if (_isModalOpen) {
            debugPrint(
                '🔒 Ride no longer searching (cancelled or accepted). Auto-closing pop-up...');
            _audioService.stopAlert();
            Navigator.of(context, rootNavigator: true).pop();
            _isModalOpen = false;
            _showSnackBar(context,
                'Ride request was cancelled or accepted by another driver.');
          }
          _activeBroadcastBooking = null;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Notice in polling timer: $e');
      }
    });
  }

  /// Process incoming bookings and trigger dialog modal if matching
  void _processBookingsList(
    List<BookingModel> bookings,
    String driverId,
    double driverLat,
    double driverLng,
    BuildContext context,
  ) {
    BookingModel? matchingBooking;

    for (final booking in bookings) {
      if (booking.status == 'searching' &&
          !_declinedBookingIds.contains(booking.id)) {
        final dist = calculateDistance(
            driverLat, driverLng, booking.pickupLat, booking.pickupLng);
        debugPrint(
            '⚡ Booking #${booking.id} searching! Distance to pickup: ${dist.toStringAsFixed(2)} km');

        // ONLY alert driver when driver is near (within 3.0 km) from the start (pickup) point
        if (driverLat != 0.0 &&
            driverLng != 0.0 &&
            booking.pickupLat != 0.0 &&
            booking.pickupLng != 0.0) {
          if (dist > 3.0) {
            debugPrint(
                '⏩ Skipping booking #${booking.id}: Distance to pickup is ${dist.toStringAsFixed(2)} km (exceeds 3 km threshold)');
            continue;
          }
        }

        matchingBooking = booking;
        break;
      }
    }

    // Check if active broadcast booking was explicitly cancelled or accepted by another driver
    if (_activeBroadcastBooking != null) {
      BookingModel? currentActiveInStream;
      for (final b in bookings) {
        if (b.id == _activeBroadcastBooking!.id) {
          currentActiveInStream = b;
          break;
        }
      }

      final isCancelled = currentActiveInStream?.status == 'cancelled';
      final isTakenByOther = matchingBooking == null ||
          (currentActiveInStream != null &&
              currentActiveInStream.status != 'searching');

      if (isCancelled || isTakenByOther) {
        if (_isModalOpen && context.mounted) {
          debugPrint(
              '🔒 Booking #${_activeBroadcastBooking!.id} cancelled/taken. Auto-closing pop-up...');
          _audioService.stopAlert();
          Navigator.of(context, rootNavigator: true).pop();
          _isModalOpen = false;
          _showSnackBar(
            context,
            isCancelled
                ? 'Ride request was cancelled by customer.'
                : 'Ride was accepted by another driver.',
          );
        }
        _activeBroadcastBooking = null;
        notifyListeners();
        return;
      }
    }

    // Trigger Pop-Up Dialog whenever matching searching booking is active and modal is not open
    if (matchingBooking != null) {
      _activeBroadcastBooking = matchingBooking;
      notifyListeners();

      if (!_isModalOpen && context.mounted) {
        debugPrint('🎉 POP-UP TRIGGERED for booking #${matchingBooking.id}!');
        _isModalOpen = true;

        // Play audio alert ringtone
        _audioService.playRideRequestAlert();

        // Trigger system heads-up push notification
        NotificationService.instance.showIncomingRideNotification(
          bookingId: matchingBooking.id,
          pickupAddress: matchingBooking.pickupAddress,
          fare: matchingBooking.fare,
          customerName: matchingBooking.customerName,
          customerPhone: matchingBooking.customerPhone,
        );

        showIncomingRideDialog(context, matchingBooking, driverId);
      }
    }
  }

  /// Stop stream listener and polling timer
  void stopBroadcastListening() {
    _audioService.stopAlert();
    _subscription?.cancel();
    _subscription = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _activeBroadcastBooking = null;
    _isModalOpen = false;
    notifyListeners();
  }

  /// ATOMIC RIDE ACCEPTANCE via Supabase RPC function accept_booking_request
  Future<void> acceptRide({
    required String bookingId,
    required String driverId,
    required BuildContext context,
  }) async {
    if (_isAccepting) return;

    _isAccepting = true;
    notifyListeners();

    try {
      _audioService.stopAlert();

      final result = await _supabaseService.acceptBookingRequest(
        bookingId: bookingId,
        driverId: driverId,
      );

      _isAccepting = false;
      notifyListeners();

      if (!context.mounted) return;

      final success = result['success'] as bool? ?? false;
      final message = result['message'] as String? ?? '';

      if (success) {
        if (_isModalOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          _isModalOpen = false;
        }

        if (_activeBroadcastBooking != null) {
          _activeDriverTrip = _activeBroadcastBooking?.copyWith(
              status: 'accepted', driverId: driverId);
        }
        await _offlineTripService.saveActiveTrip(
          bookingId: bookingId,
          status: 'accepted',
          driverId: driverId,
        );
        checkActiveDriverTrip(driverId);

        if (!context.mounted) return;

        _showSnackBar(
          context,
          '🎉 Ride Accepted! Navigating to Pickup...',
          backgroundColor: const Color(0xFF09A234),
        );
        GoRouter.of(context).go('/driver/pickup/$bookingId');
      } else {
        if (_isModalOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          _isModalOpen = false;
        }
        _showSnackBar(
          context,
          message.isNotEmpty
              ? message
              : 'Ride already taken by another driver.',
          backgroundColor: Colors.black87,
        );
      }
    } catch (e) {
      _isAccepting = false;
      notifyListeners();
      if (context.mounted) {
        _showSnackBar(context, 'Error accepting ride: $e',
            backgroundColor: Colors.red);
      }
    }
  }

  void onModalClosed() {
    _audioService.stopAlert();
    if (_activeBroadcastBooking != null) {
      _declinedBookingIds.add(_activeBroadcastBooking!.id);
      _activeBroadcastBooking = null;
    }
    _isModalOpen = false;
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message,
      {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    stopBroadcastListening();
    super.dispose();
  }
}
