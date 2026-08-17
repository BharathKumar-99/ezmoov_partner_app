import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/supabase_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/offline_trip_service.dart';
import '../core/services/notification_service.dart';
import '../models/booking_model.dart';
import '../models/bid_model.dart';
import '../models/vehicle_type_model.dart';
import '../views/home/widgets/incoming_ride_dialog.dart';
import '../views/home/widgets/bidding_outstation_dialog.dart';


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

  // Active Pending Bid State
  BookingModel? _activePendingBidBooking;
  BidModel? _activePendingBid;

  BookingModel? get activePendingBidBooking => _activePendingBidBooking;
  BidModel? get activePendingBid => _activePendingBid;
  bool get hasPendingBid => _activePendingBid != null && _activePendingBidBooking != null;

  void withdrawBid() {
    _activePendingBidBooking = null;
    _activePendingBid = null;
    notifyListeners();
  }

  bool _isAccepting = false;
  bool get isAccepting => _isAccepting;

  bool _isModalOpen = false;

  final Set<String> _declinedBookingIds = {};
  Set<String> get declinedBookingIds => _declinedBookingIds;

  String? _driverVehicleType;
  String? _driverVehicleTypeId;

  String? get driverVehicleType => _driverVehicleType;
  String? get driverVehicleTypeId => _driverVehicleTypeId;

  void setDriverVehicleInfo({String? vehicleType, String? vehicleTypeId}) {
    if (vehicleType != null && vehicleType.isNotEmpty) {
      _driverVehicleType = vehicleType;
    }
    if (vehicleTypeId != null && vehicleTypeId.isNotEmpty) {
      _driverVehicleTypeId = vehicleTypeId;
    }
  }

  Future<void> _fetchDriverVehicleInfo(String driverId) async {
    try {
      final driver = await _supabaseService.getDriverById(driverId);
      if (driver != null && driver.vehicleType != null) {
        _driverVehicleType = driver.vehicleType;
      }
      final vehicle = await _supabaseService.getVehicleByDriverId(driverId);
      if (vehicle != null) {
        if (vehicle.vehicleTypeId != null) {
          _driverVehicleTypeId = vehicle.vehicleTypeId;
        }
        if (_driverVehicleType == null || _driverVehicleType!.isEmpty) {
          _driverVehicleType = vehicle.vehicleTypeName;
        }
      }
    } catch (e) {
      debugPrint('Notice fetching driver vehicle info: $e');
    }
  }

  /// Check if the booking vehicle type matches the partner's vehicle type
  bool _isVehicleTypeMatching(BookingModel booking) {
    final bookingVeh = booking.vehicleTypeId?.trim();

    // If the booking does not specify a vehicle type, allow it for all partners
    if (bookingVeh == null || bookingVeh.isEmpty) {
      return true;
    }

    final dType = _driverVehicleType?.trim() ?? '';
    final dTypeId = _driverVehicleTypeId?.trim() ?? '';

    // If driver's vehicle type is not loaded yet, allow fallback
    if (dType.isEmpty && dTypeId.isEmpty) {
      return true;
    }

    // 1. Direct match (case-insensitive)
    if (bookingVeh.toLowerCase() == dType.toLowerCase() ||
        (dTypeId.isNotEmpty && bookingVeh.toLowerCase() == dTypeId.toLowerCase())) {
      return true;
    }

    // 2. Normalized alphanumeric match (e.g., "3 Wheeler" vs "3wheeler" vs "3")
    final normB = bookingVeh.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final normD = dType.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final normDId = dTypeId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();

    if (normB == normD || (normDId.isNotEmpty && normB == normDId)) {
      return true;
    }

    // 3. Match using VehicleTypeModel catalog (ID to Name & Name to ID mapping)
    for (final vt in VehicleTypeModel.defaultVehicleTypes) {
      final vtId = vt.id.trim();
      final vtNameNorm = vt.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();

      final bookingMatchesVt = (bookingVeh == vtId || normB == vtNameNorm);
      final driverMatchesVt = (dType == vt.name || dTypeId == vtId || normD == vtNameNorm);

      if (bookingMatchesVt && driverMatchesVt) {
        return true;
      }
    }

    return false;
  }

  /// Explicitly decline a ride request so it is never shown again to this driver
  void declineRide(String bookingId, {String? driverId}) {
    if (bookingId.isEmpty) return;
    _declinedBookingIds.add(bookingId);
    _audioService.stopAlert();
    if (_activeBroadcastBooking?.id == bookingId) {
      _activeBroadcastBooking = null;
    }
    _isModalOpen = false;
    notifyListeners();

    if (driverId != null && driverId.isNotEmpty) {
      _supabaseService.recordDriverRejection(driverId);
    }
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

  /// Check status of active pending bid in public.bids and public.bookings. Clear banner if no longer pending (accepted, rejected, closed, cancelled)
  Future<void> checkPendingBidStatus(String driverId, BuildContext context) async {
    if (_activePendingBidBooking == null || _activePendingBid == null) return;
    try {
      final bookingId = _activePendingBidBooking!.id;

      // 1. Check bid status in public.bids
      final bidResponse = await _supabaseService.client
          .from('bids')
          .select()
          .eq('booking_id', bookingId)
          .eq('driver_id', driverId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (bidResponse != null) {
        final bidStatus = (bidResponse['status'] as String?)?.toLowerCase() ?? 'pending';

        if (bidStatus == 'accepted') {
          debugPrint('🎉 Bid accepted by customer!');
          final bidAmount = (bidResponse['driver_bid'] as num?)?.toDouble() ?? 0.0;
          withdrawBid(); // Clear pending floating banner
          await checkActiveDriverTrip(driverId);
          if (context.mounted) {
            _showSnackBar(
              context,
              '🎉 Customer accepted your bid of ₹${bidAmount.toStringAsFixed(0)}!',
              backgroundColor: const Color(0xFF09A234),
            );
          }
          return;
        } else if (bidStatus != 'pending') {
          // 'rejected', 'closed', 'cancelled', etc.
          debugPrint('🔒 Bid status updated to $bidStatus (no longer pending). Clearing banner...');
          withdrawBid();
          if (context.mounted) {
            _showSnackBar(
              context,
              'Outstation bid status: $bidStatus',
              backgroundColor: Colors.black87,
            );
          }
          return;
        }
      }

      // 2. Check booking status in public.bookings
      final currentBooking = await _supabaseService.getBookingById(bookingId);
      if (currentBooking == null || currentBooking.status != 'searching') {
        debugPrint('🔒 Outstation booking #$bookingId is no longer searching (${currentBooking?.status}). Clearing banner...');
        withdrawBid();
        if (context.mounted) {
          _showSnackBar(
            context,
            currentBooking?.status == 'cancelled'
                ? 'Outstation ride was cancelled by customer.'
                : 'Outstation ride closed or accepted.',
            backgroundColor: Colors.black87,
          );
        }
      }
    } catch (e) {
      debugPrint('Notice checking pending bid status: $e');
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
          !['completed', 'cancelled', 'expired', 'rejected', 'searching']
              .contains(bookingToRestore.status)) {
        _activeDriverTrip = bookingToRestore;
        await _offlineTripService.saveActiveTrip(
          bookingId: bookingToRestore.id,
          status: bookingToRestore.status,
          driverId: driverId,
        );
        notifyListeners();

        if (context.mounted) {
          _showSnackBar(context, '⚡ Active trip in progress: Tap Resume Trip to return');
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
    String? driverVehicleType,
    String? driverVehicleTypeId,
  }) {
    stopBroadcastListening();

    if (driverVehicleType != null && driverVehicleType.isNotEmpty) {
      _driverVehicleType = driverVehicleType;
    }
    if (driverVehicleTypeId != null && driverVehicleTypeId.isNotEmpty) {
      _driverVehicleTypeId = driverVehicleTypeId;
    }

    if (_driverVehicleType == null && _driverVehicleTypeId == null) {
      _fetchDriverVehicleInfo(driverId);
    }

    debugPrint(
        '📡 Starting Realtime Broadcast Stream & 3s Polling for driver $driverId at ($driverLat, $driverLng) [Vehicle: ${_driverVehicleType ?? _driverVehicleTypeId}]...');

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
        if (context.mounted) {
          await checkPendingBidStatus(driverId, context);
        }

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
    if (_activePendingBidBooking != null && context.mounted) {
      checkPendingBidStatus(driverId, context);
    }

    BookingModel? matchingBooking;

    for (final booking in bookings) {
      if (booking.status == 'searching' &&
          !_declinedBookingIds.contains(booking.id)) {

        // 1. VEHICLE TYPE MATCHING GUARD:
        // Do NOT show alert dialog if booking's vehicle type does not match partner's vehicle type!
        if (!_isVehicleTypeMatching(booking)) {
          debugPrint(
              '⏩ Skipping booking #${booking.id}: Booking vehicle type (${booking.vehicleTypeId}) does not match partner vehicle type ($_driverVehicleType / $_driverVehicleTypeId)');
          continue;
        }

        final dist = calculateDistance(
            driverLat, driverLng, booking.pickupLat, booking.pickupLng);
        debugPrint(
            '⚡ Booking #${booking.id} searching! Distance to pickup: ${dist.toStringAsFixed(2)} km');

        final serviceName = booking.service?.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_') ?? '';
        final isLocalAdda = serviceName.isEmpty || serviceName == 'local_adda' || serviceName == 'localadda';

        // ONLY alert driver within 3.0 km distance if service is local_adda
        if (isLocalAdda) {
          if (driverLat != 0.0 &&
              driverLng != 0.0 &&
              booking.pickupLat != 0.0 &&
              booking.pickupLng != 0.0) {
            if (dist > 3.0) {
              debugPrint(
                  '⏩ Skipping booking #${booking.id}: Service ($serviceName) is local_adda and distance to pickup is ${dist.toStringAsFixed(2)} km (exceeds 3 km threshold)');
              continue;
            }
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
        _supabaseService.getDriverDailyStatus(driverId).then((status) {
          if (status != null && status.isBlocked) {
            debugPrint('⛔ Driver $driverId is blocked today (${status.blockReason}). Suppressing ride request dialog.');
            return;
          }

          final currentBooking = matchingBooking;
          if (currentBooking != null && !_isModalOpen && context.mounted) {
            debugPrint('🎉 POP-UP TRIGGERED for booking #${currentBooking.id}!');
            _isModalOpen = true;

            // Play audio alert ringtone
            _audioService.playRideRequestAlert();

            // Trigger system heads-up push notification
            NotificationService.instance.showIncomingRideNotification(
              bookingId: currentBooking.id,
              pickupAddress: currentBooking.pickupAddress,
              fare: currentBooking.fare,
              customerName: currentBooking.customerName,
              customerPhone: currentBooking.customerPhone,
            );

            final serviceName = currentBooking.service?.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_') ?? '';
            final isBiddingOutstation = serviceName == 'bidding_outstation' || serviceName == 'biddingoutstation';

            if (isBiddingOutstation) {
              showBiddingOutstationDialog(context, currentBooking, driverId);
            } else {
              showIncomingRideDialog(context, currentBooking, driverId);
            }
          }
        });
      }
    }
  }

  /// Submit driver bid record for bidding_outstation service into public.bids table
  Future<bool> submitBid({
    required String bookingId,
    required String driverId,
    required double currentRate,
    required double driverBid,
    required BuildContext context,
  }) async {
    try {
      _audioService.stopAlert();
      final success = await _supabaseService.submitDriverBid(
        bookingId: bookingId,
        driverId: driverId,
        currentRate: currentRate,
        driverBid: driverBid,
      );

      if (success) {
        _declinedBookingIds.add(bookingId);

        // Store active pending bid state so floating banner shows up on Home screen
        if (_activeBroadcastBooking?.id == bookingId) {
          _activePendingBidBooking = _activeBroadcastBooking;
          _activeBroadcastBooking = null;
        }

        _activePendingBid = BidModel(
          bookingId: bookingId,
          driverId: driverId,
          currentBookingRate: currentRate,
          driverBid: driverBid,
          status: 'pending',
          createdAt: DateTime.now(),
        );

        _isModalOpen = false;
        notifyListeners();

        if (context.mounted) {
          _showSnackBar(
            context,
            '✅ Bid of ₹${driverBid.toStringAsFixed(0)} submitted! Pending customer response...',
            backgroundColor: const Color(0xFF09A234),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'Error submitting bid: $e',
          backgroundColor: Colors.red,
        );
      }
      return false;
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
