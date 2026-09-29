import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/services/supabase_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/offline_trip_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/google_directions_service.dart';
import '../models/booking_model.dart';
import '../models/bid_model.dart';
import '../models/vehicle_type_model.dart';
import '../models/intermediate_stop_model.dart';
import 'package:provider/provider.dart';
import '../views/home/widgets/incoming_ride_dialog.dart';
import '../views/home/widgets/local_adda_bidding_dialog.dart';
import 'profile_viewmodel.dart';

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
  StreamSubscription<List<BidModel>>? _bidSubscription;

  BookingModel? get activePendingBidBooking => _activePendingBidBooking;
  BidModel? get activePendingBid => _activePendingBid;
  bool get hasPendingBid =>
      _activePendingBid != null && _activePendingBidBooking != null;

  void withdrawBid() {
    _bidSubscription?.cancel();
    _bidSubscription = null;
    _activePendingBidBooking = null;
    _activePendingBid = null;
    notifyListeners();
  }

  bool _isAccepting = false;
  bool get isAccepting => _isAccepting;

  bool _isModalOpen = false;
  bool get isModalOpen => _isModalOpen;

  String? _activeShowingBookingId;
  String? get activeShowingBookingId => _activeShowingBookingId;

  final Set<String> _declinedBookingIds = {};
  Set<String> get declinedBookingIds => _declinedBookingIds;

  int _forward8ftTo9ftDelaySeconds = AppConstants.vehicleTierForwardDelaySeconds;
  int get forward8ftTo9ftDelaySeconds => _forward8ftTo9ftDelaySeconds;
  void setForward8ftTo9ftDelaySeconds(int seconds) {
    _forward8ftTo9ftDelaySeconds = seconds;
    notifyListeners();
  }

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

  List<VehicleTypeModel> _vehicleTypes = [];
  List<VehicleTypeModel> get vehicleTypes => _vehicleTypes;

  void setVehicleTypes(List<VehicleTypeModel> types) {
    _vehicleTypes = types;
    notifyListeners();
  }

  /// Checks whether a given vehicle type string/id corresponds to a 7 Feet / 4 Wheeler vehicle (Tata Ace / 750 Kg)
  bool is7FeetVehicle(String? vehType, [String? vehTypeId]) {
    final typeStr = vehType?.trim().toLowerCase() ?? '';
    final typeIdStr = vehTypeId?.trim().toLowerCase() ?? '';
    final combined = '$typeStr $typeIdStr'.trim();
    final norm = combined.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    if (combined.contains('7ft') ||
        combined.contains('7 ft') ||
        combined.contains('7feet') ||
        combined.contains('7 feet') ||
        combined.contains('4 wheeler') ||
        combined.contains('4wheeler') ||
        combined.contains('4w') ||
        combined.contains('tata ace') ||
        combined.contains('ace') ||
        combined.contains('750') ||
        norm == '4' ||
        norm == '4w' ||
        norm == '4wheeler' ||
        norm == '7' ||
        norm == '7ft' ||
        norm == '7feet' ||
        norm == '7feet750kg' ||
        norm == '750kgs' ||
        norm == '750kg') {
      return true;
    }

    // Check catalog IDs/Capacities for 4 Wheeler / 7ft (750 Kgs)
    for (final vt in _vehicleTypes) {
      if (vt.id.trim() == vehTypeId?.trim() ||
          vt.id.trim() == vehType?.trim() ||
          vt.name.trim().toLowerCase() == typeStr) {
        final vtNorm = vt.name.toLowerCase();
        final vtCap = vt.capacity.toLowerCase();
        if (vt.id.trim() == '4' ||
            vtNorm.contains('4 wheeler') ||
            vtNorm.contains('7') ||
            vtNorm.contains('ace') ||
            vtCap.contains('750') ||
            vt.capacityKg == 750.0) {
          return true;
        }
      }
    }
    return false;
  }

  /// Checks whether a given vehicle type string/id corresponds to an 8 Feet vehicle (1.2 Ton / 1200 Kg)
  bool is8FeetVehicle(String? vehType, [String? vehTypeId]) {
    final typeStr = vehType?.trim().toLowerCase() ?? '';
    final typeIdStr = vehTypeId?.trim().toLowerCase() ?? '';
    final combined = '$typeStr $typeIdStr'.trim();
    final norm = combined.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    if (combined.contains('8ft') ||
        combined.contains('8 ft') ||
        combined.contains('8feet') ||
        combined.contains('8 feet') ||
        combined.contains('8 ft vehicle') ||
        combined.contains('8ft vehicle') ||
        combined.contains('pickup 8') ||
        combined.contains('8pickup') ||
        combined.contains('1200') ||
        combined.contains('1.2 ton') ||
        combined.contains('1.2ton') ||
        norm == '5' ||
        norm == '8' ||
        norm == '8ft' ||
        norm == '8feet' ||
        norm == '8ftvehicle' ||
        norm == '8feet12ton' ||
        norm == '1200kgs' ||
        norm == '1200kg') {
      return true;
    }

    // Check catalog IDs/Capacities for 8ft (1200 Kgs / 1.2 Ton)
    for (final vt in _vehicleTypes) {
      if (vt.id.trim() == vehTypeId?.trim() ||
          vt.id.trim() == vehType?.trim() ||
          vt.name.trim().toLowerCase() == typeStr) {
        final vtNorm = vt.name.toLowerCase();
        final vtCap = vt.capacity.toLowerCase();
        if (vt.id.trim() == '5' ||
            vtNorm.contains('8') ||
            vtCap.contains('1200') ||
            vt.capacityKg == 1200.0) {
          return true;
        }
      }
    }
    return false;
  }

  /// Checks whether a given vehicle type string/id corresponds to a 9 Feet vehicle (1.7 Ton / 1700 Kg)
  bool is9FeetVehicle(String? vehType, [String? vehTypeId]) {
    final typeStr = vehType?.trim().toLowerCase() ?? '';
    final typeIdStr = vehTypeId?.trim().toLowerCase() ?? '';
    final combined = '$typeStr $typeIdStr'.trim();
    final norm = combined.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    if (combined.contains('9ft') ||
        combined.contains('9 ft') ||
        combined.contains('9feet') ||
        combined.contains('9 feet') ||
        combined.contains('9 ft vehicle') ||
        combined.contains('9ft vehicle') ||
        combined.contains('pickup 9') ||
        combined.contains('9pickup') ||
        combined.contains('1700') ||
        combined.contains('1.7 ton') ||
        combined.contains('1.7ton') ||
        combined.contains('9-10ft') ||
        combined.contains('9-10 feet') ||
        norm == '6' ||
        norm == '9ft' ||
        norm == '9feet' ||
        norm == '9ftvehicle' ||
        norm == '9feet17ton' ||
        norm == '1700kgs' ||
        norm == '1700kg') {
      return true;
    }

    // Check catalog IDs/Capacities for 9ft (1700 Kgs / 1.7 Ton)
    for (final vt in _vehicleTypes) {
      if (vt.id.trim() == vehTypeId?.trim() ||
          vt.id.trim() == vehType?.trim() ||
          vt.name.trim().toLowerCase() == typeStr) {
        final vtNorm = vt.name.toLowerCase();
        final vtCap = vt.capacity.toLowerCase();
        if (vt.id.trim() == '6' ||
            vtNorm.contains('9') ||
            vtCap.contains('1700') ||
            vt.capacityKg == 1700.0) {
          return true;
        }
      }
    }
    return false;
  }

  /// Checks whether a given vehicle type string/id corresponds to a 10 Feet vehicle (2 Tons / 2000 Kg)
  bool is10FeetVehicle(String? vehType, [String? vehTypeId]) {
    final typeStr = vehType?.trim().toLowerCase() ?? '';
    final typeIdStr = vehTypeId?.trim().toLowerCase() ?? '';
    final combined = '$typeStr $typeIdStr'.trim();
    final norm = combined.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    if (combined.contains('10ft') ||
        combined.contains('10 ft') ||
        combined.contains('10 feet') ||
        combined.contains('10feet') ||
        combined.contains('10 ft vehicle') ||
        combined.contains('10ft vehicle') ||
        combined.contains('pickup 10') ||
        combined.contains('10pickup') ||
        combined.contains('2000') ||
        combined.contains('2 ton') ||
        combined.contains('2ton') ||
        combined.contains('2 tons') ||
        combined.contains('2tons') ||
        norm == '7' ||
        norm == '10ft' ||
        norm == '10feet' ||
        norm == '10ftvehicle' ||
        norm == '10feet2tons' ||
        norm == '2000kgs' ||
        norm == '2000kg') {
      return true;
    }

    // Check catalog IDs/Capacities for 10ft (2000 Kgs / 2 Tons)
    for (final vt in _vehicleTypes) {
      if (vt.id.trim() == vehTypeId?.trim() ||
          vt.id.trim() == vehType?.trim() ||
          vt.name.trim().toLowerCase() == typeStr) {
        final vtNorm = vt.name.toLowerCase();
        final vtCap = vt.capacity.toLowerCase();
        if (vt.id.trim() == '7' ||
            vtNorm.contains('10') ||
            vtCap.contains('2000') ||
            vt.capacityKg == 2000.0) {
          return true;
        }
      }
    }
    return false;
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
        (dTypeId.isNotEmpty &&
            bookingVeh.toLowerCase() == dTypeId.toLowerCase())) {
      return true;
    }

    // 2. Normalized alphanumeric match (e.g., "3 Wheeler" vs "3wheeler" vs "3")
    final normB =
        bookingVeh.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final normD = dType.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final normDId =
        dTypeId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();

    if (normB == normD || (normDId.isNotEmpty && normB == normDId)) {
      return true;
    }

    // 3. Match using dynamic VehicleTypeModel catalog from database
    if (_vehicleTypes.isEmpty) {
      _supabaseService.fetchVehicleTypes().then((types) {
        if (types.isNotEmpty) _vehicleTypes = types;
      });
    }

    for (final vt in _vehicleTypes) {
      final vtId = vt.id.trim();
      final vtNameNorm =
          vt.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();

      final bookingMatchesVt = (bookingVeh == vtId || normB == vtNameNorm);
      final driverMatchesVt =
          (dType == vt.name || dTypeId == vtId || normD == vtNameNorm);

      if (bookingMatchesVt && driverMatchesVt) {
        return true;
      }
    }

    // 4. Vehicle Tier Escalation / 30-Second Forwarding Fallback:
    // • 7 Feet booking -> after 30s forwarded to 8 Feet driver
    // • 8 Feet booking -> after 30s forwarded to 9 Feet driver
    // • 9 Feet booking -> after 30s forwarded to 10 Feet driver
    // (All without modifying the bookings table in database)
    final isBooking7Ft = is7FeetVehicle(bookingVeh);
    final isBooking8Ft = is8FeetVehicle(bookingVeh);
    final isBooking9Ft = is9FeetVehicle(bookingVeh);

    final isDriver8Ft = is8FeetVehicle(dType, dTypeId);
    final isDriver9Ft = is9FeetVehicle(dType, dTypeId);
    final isDriver10Ft = is10FeetVehicle(dType, dTypeId);

    bool isForwardCandidate = false;
    String forwardTier = '';

    if (isBooking7Ft && isDriver8Ft) {
      isForwardCandidate = true;
      forwardTier = '7ft -> 8ft';
    } else if (isBooking8Ft && isDriver9Ft) {
      isForwardCandidate = true;
      forwardTier = '8ft -> 9ft';
    } else if (isBooking9Ft && isDriver10Ft) {
      isForwardCandidate = true;
      forwardTier = '9ft -> 10ft';
    }

    if (isForwardCandidate) {
      final createdAt = booking.createdAt;
      if (createdAt != null) {
        final elapsedSeconds = DateTime.now().difference(createdAt).inSeconds;
        if (elapsedSeconds < _forward8ftTo9ftDelaySeconds && booking.farDriver != true) {
          debugPrint(
              '⏳ $forwardTier Delay: Booking #${booking.id} was created ${elapsedSeconds}s ago. Waiting until ${_forward8ftTo9ftDelaySeconds}s before forwarding to next tier.');
          return false;
        }
      }

      debugPrint(
          '⏩ $forwardTier Forwarding (30s elapsed): Booking #${booking.id} (Vehicle: $bookingVeh) forwarded to driver ($dType / $dTypeId)');
      return true;
    }

    return false;
  }

  /// Explicitly decline a ride request so it is never shown again to this driver
  void declineRide(
    String bookingId, {
    String? driverId,
    BookingModel? booking,
    String? reason,
  }) {
    if (bookingId.isEmpty) return;
    _declinedBookingIds.add(bookingId);
    _audioService.stopAlert();
    final currentBooking = booking ??
        (_activeBroadcastBooking?.id == bookingId
            ? _activeBroadcastBooking
            : null);
    if (_activeBroadcastBooking?.id == bookingId) {
      _activeBroadcastBooking = null;
    }
    _isModalOpen = false;
    _activeShowingBookingId = null;
    notifyListeners();

    if (driverId != null && driverId.isNotEmpty) {
      _supabaseService.recordDriverRejection(driverId);
      _supabaseService.recordDriverRideAction(
        driverId: driverId,
        bookingId: bookingId,
        action: 'declined',
        reason: reason,
        pickupAddress: currentBooking?.pickupAddress,
        dropAddress: currentBooking?.dropAddress,
        fare: currentBooking?.fare,
        vehicleTypeId: currentBooking?.vehicleTypeId,
        customerId: currentBooking?.customerId,
        customerName: currentBooking?.customerName,
      );
    }
  }

  final Map<String, double> _roadDistances = {};
  double? getCachedRoadDistance(String bookingId) => _roadDistances[bookingId];
  void setCachedRoadDistance(String bookingId, double distanceKm) {
    _roadDistances[bookingId] = distanceKm;
    notifyListeners();
  }

  /// Haversine straight-line distance formula
  double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    return GoogleDirectionsService.calculateHaversineDistance(lat1, lon1, lat2, lon2);
  }

  /// Calculates segment distance between two consecutive points with 1.3x city road factor
  double calculateSegmentDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    double fallbackKm = 2.5,
  }) {
    return GoogleDirectionsService.calculateSegmentDistance(
      lat1,
      lon1,
      lat2,
      lon2,
      fallbackKm: fallbackKm,
    );
  }

  /// Calculates total delivery trip distance along [Pickup -> Stops -> Drop] with 1.3x city road factor
  double calculateRouteDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    List<IntermediateStopModel>? stops,
    double fallbackKm = 12.4,
    String? bookingId,
  }) {
    if (bookingId != null && _roadDistances.containsKey(bookingId)) {
      return _roadDistances[bookingId]!;
    }
    return GoogleDirectionsService.calculateRouteDistance(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      stops: stops,
      fallbackKm: fallbackKm,
    );
  }

  /// Convenience method to calculate total route distance for a given BookingModel
  double calculateTripDistance(BookingModel booking) {
    if (_roadDistances.containsKey(booking.id)) {
      return _roadDistances[booking.id]!;
    }
    return calculateRouteDistance(
      startLat: booking.pickupLat,
      startLng: booking.pickupLng,
      endLat: booking.dropLat,
      endLng: booking.dropLng,
      stops: booking.effectiveIntermediateStops,
      bookingId: booking.id,
    );
  }

  /// Asynchronously fetches real road distance (from Google Directions API if available)
  Future<double> fetchBookingRoadDistance(BookingModel booking) async {
    if (_roadDistances.containsKey(booking.id)) {
      return _roadDistances[booking.id]!;
    }
    final dist = await GoogleDirectionsService.fetchRoadDistance(
      startLat: booking.pickupLat,
      startLng: booking.pickupLng,
      endLat: booking.dropLat,
      endLng: booking.dropLng,
      stops: booking.effectiveIntermediateStops,
    );
    _roadDistances[booking.id] = dist;
    notifyListeners();
    return dist;
  }

  /// Distance in km between two GPS coordinates (with optional 1.3x road factor)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    bool applyRoadFactor = false,
  }) {
    if (lat1 == 0.0 || lon1 == 0.0 || lat2 == 0.0 || lon2 == 0.0) return 0.0;
    final km = GoogleDirectionsService.calculateHaversineDistance(lat1, lon1, lat2, lon2);
    if (applyRoadFactor) {
      return double.parse((km * 1.3).toStringAsFixed(1));
    }
    return double.parse(km.toStringAsFixed(1));
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
  Future<void> checkPendingBidStatus(
      String driverId, BuildContext context) async {
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
        final bidStatus =
            (bidResponse['status'] as String?)?.toLowerCase() ?? 'pending';

        if (bidStatus == 'accepted') {
          debugPrint('🎉 Bid accepted by customer!');
          final bidAmount =
              (bidResponse['driver_bid'] as num?)?.toDouble() ?? 0.0;
          withdrawBid(); // Clear pending floating banner
          unawaited(_supabaseService.deductDriverWalletForBookingAcceptance(
            driverId: driverId,
            bookingId: bookingId,
            amount: 100.0,
          ));
          await checkActiveDriverTrip(driverId);
          if (context.mounted) {
            _showSnackBar(
              context,
              '🎉 Customer accepted your bid of ₹${bidAmount.toStringAsFixed(0)}! ₹100 deducted from wallet.',
              backgroundColor: const Color(0xFF09A234),
            );
          }
          return;
        } else if (bidStatus != 'pending') {
          // 'rejected', 'closed', 'cancelled', etc.
          debugPrint(
              '🔒 Bid status updated to $bidStatus (no longer pending). Clearing banner...');
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
        debugPrint(
            '🔒 Outstation booking #$bookingId is no longer searching (${currentBooking?.status}). Clearing banner...');
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
          _showSnackBar(
              context, '⚡ Active trip in progress: Tap Resume Trip to return');
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

  /// Validates if an incoming booking meets vehicle match, distance & service criteria for a driver
  bool isBookingEligibleForDriver({
    required BookingModel booking,
    required double driverLat,
    required double driverLng,
    bool isOutstationBookingEnabled = false,
  }) {
    // 1. VEHICLE TYPE MATCHING GUARD:
    // Do NOT show alert dialog if booking's vehicle type does not match partner's vehicle type!
    if (!_isVehicleTypeMatching(booking)) {
      return false;
    }

    final dist = calculateDistance(
        driverLat, driverLng, booking.pickupLat, booking.pickupLng);

    final serviceName = booking.service
            ?.toLowerCase()
            .trim()
            .replaceAll('-', '_')
            .replaceAll(' ', '_') ??
        '';
    final isLocalAdda = serviceName.isEmpty ||
        serviceName == 'local_adda' ||
        serviceName == 'bidding_local_adda' ||
        serviceName == 'biddinglocaladda' ||
        serviceName == 'localadda' ||
        serviceName.contains('local_adda');
    final isOutstation = serviceName.contains('outstation') ||
        serviceName == 'bidding_outstation' ||
        serviceName == 'biddingoutstation';

    // 1. Local Adda distance check: ONLY alert driver within localAddaDistanceKm
    if (isLocalAdda) {
      if (driverLat != 0.0 &&
          driverLng != 0.0 &&
          booking.pickupLat != 0.0 &&
          booking.pickupLng != 0.0) {
        if (dist > AppConstants.localAddaDistanceKm) {
          return false;
        }
      }
      return true;
    }

    // 2. Outstation booking checks:
    // Requirements:
    // - driver outstation_booking must be true
    // - driver within outstationDistanceKm from pickup location
    if (isOutstation) {
      if (!isOutstationBookingEnabled) {
        return false;
      }

      final outstationDistanceThresholdKm = AppConstants.outstationDistanceKm;
      if (driverLat != 0.0 &&
          driverLng != 0.0 &&
          booking.pickupLat != 0.0 &&
          booking.pickupLng != 0.0) {
        if (dist > outstationDistanceThresholdKm) {
          return false;
        }
      }
      return true;
    }

    // 3. Far Driver distance check (for other standard services):
    // - if far_driver is null or false: within initialStandardDistanceKm (default 3.0 km)
    // - if far_driver is true: distance increases to farDriverDistanceKm (default 10.0 km)
    final isFarDriver = booking.farDriver == true;
    final distanceThresholdKm = isFarDriver
        ? AppConstants.farDriverDistanceKm
        : AppConstants.initialStandardDistanceKm;

    if (driverLat != 0.0 &&
        driverLng != 0.0 &&
        booking.pickupLat != 0.0 &&
        booking.pickupLng != 0.0) {
      if (dist > distanceThresholdKm) {
        return false;
      }
    }

    return true;
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

    bool isOutstationEnabled = false;
    if (context.mounted) {
      try {
        final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
        isOutstationEnabled = profileVm.driver?.outstationBooking ?? false;
      } catch (_) {}
    }

    BookingModel? matchingBooking;

    for (final booking in bookings) {
      if (booking.status == 'searching' &&
          !_declinedBookingIds.contains(booking.id)) {
        final dist = calculateDistance(
            driverLat, driverLng, booking.pickupLat, booking.pickupLng);
        debugPrint(
            '⚡ Booking #${booking.id} searching! Distance to pickup: ${dist.toStringAsFixed(2)} km');

        if (!isBookingEligibleForDriver(
          booking: booking,
          driverLat: driverLat,
          driverLng: driverLng,
          isOutstationBookingEnabled: isOutstationEnabled,
        )) {
          final sName = booking.service ?? '';
          debugPrint(
              '⏩ Skipping booking #${booking.id}: Ineligible for driver (Service: $sName, Distance: ${dist.toStringAsFixed(2)} km, OutstationEnabled: $isOutstationEnabled)');
          continue;
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
          _activeShowingBookingId = null;
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

      // Guard: Do NOT open another modal or trigger duplicate alerts if a modal is already open or this order is currently being shown
      if (_isModalOpen || _activeShowingBookingId == matchingBooking.id) {
        return;
      }

      // Synchronously lock state to prevent race conditions from 3s polling & stream updates
      _isModalOpen = true;
      _activeShowingBookingId = matchingBooking.id;

      if (context.mounted) {
        _supabaseService.getDriverDailyStatus(driverId).then((status) {
          if (status != null && status.isBlocked) {
            debugPrint(
                '⛔ Driver $driverId is blocked today (${status.blockReason}). Suppressing ride request dialog.');
            _isModalOpen = false;
            _activeShowingBookingId = null;
            return;
          }

          final currentBooking = matchingBooking;
          if (currentBooking != null && context.mounted) {
            debugPrint(
                '🎉 POP-UP TRIGGERED for booking #${currentBooking.id}!');

            // Play audio alert ringtone
            _audioService.playRideRequestAlert();

            final double baseFare = currentBooking.fare;
            final double incentive =
                (currentBooking.farDriverIncentive != null &&
                        currentBooking.farDriverIncentive! > 0)
                    ? currentBooking.farDriverIncentive!
                    : 0.0;

            // Trigger system heads-up push notification
            NotificationService.instance.showIncomingRideNotification(
              bookingId: currentBooking.id,
              pickupAddress: currentBooking.pickupAddress,
              fare: baseFare + incentive,
              customerName: currentBooking.customerName,
              customerPhone: currentBooking.customerPhone,
            );

            final sName = currentBooking.service
                    ?.toLowerCase()
                    .trim()
                    .replaceAll('-', '_')
                    .replaceAll(' ', '_') ??
                '';
            final isLocalAddaBidding = sName == 'local_adda' ||
                sName == 'bidding_local_adda' ||
                sName == 'localadda' ||
                sName == 'bidding_outstation';

            if (isLocalAddaBidding) {
              showLocalAddaBiddingDialog(context, currentBooking, driverId);
            } else {
              showIncomingRideDialog(context, currentBooking, driverId);
            }
          } else {
            _isModalOpen = false;
            _activeShowingBookingId = null;
          }
        }).catchError((e) {
          debugPrint('Notice in getDriverDailyStatus: $e');
          _isModalOpen = false;
          _activeShowingBookingId = null;
        });
      } else {
        _isModalOpen = false;
        _activeShowingBookingId = null;
      }
    }
  }

  /// Submit driver bid record for local_adda / bidding services into public.bids table
  Future<bool> submitBid({
    required String bookingId,
    required String driverId,
    required double currentRate,
    required double driverBid,
    required BuildContext context,
  }) async {
    try {
      _audioService.stopAlert();
      final createdBid = await _supabaseService.submitDriverBid(
        bookingId: bookingId,
        driverId: driverId,
        currentRate: currentRate,
        driverBid: driverBid,
      );

      if (createdBid != null) {
        _declinedBookingIds.add(bookingId);

        // Store active pending bid state so floating banner shows up on Home screen
        if (_activeBroadcastBooking?.id == bookingId) {
          _activePendingBidBooking = _activeBroadcastBooking;
          _activeBroadcastBooking = null;
        }

        _activePendingBid = createdBid;
        _isModalOpen = false;
        _activeShowingBookingId = null;
        notifyListeners();

        // Start realtime listener on bids stream
        if (context.mounted) {
          _startBidRealtimeListener(bookingId, driverId, context);
        }

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

  /// Subscribe to realtime updates for this driver's bid
  void _startBidRealtimeListener(
    String bookingId,
    String driverId,
    BuildContext context,
  ) {
    _bidSubscription?.cancel();
    _bidSubscription = _supabaseService
        .streamDriverBids(bookingId: bookingId, driverId: driverId)
        .listen((bids) {
      if (bids.isNotEmpty) {
        final latestBid = bids.first;
        final status = latestBid.status.toLowerCase();
        if (status == 'accepted') {
          if (context.mounted) {
            _onBidAccepted(bookingId, driverId, context, latestBid);
          }
        } else if (status == 'closed' || status == 'rejected') {
          if (context.mounted) {
            _onBidClosed(bookingId, status, context);
          }
        }
      }
    }, onError: (e) {
      debugPrint('Notice in bid stream listener: $e');
    });
  }

  Future<void> _onBidAccepted(
    String bookingId,
    String driverId,
    BuildContext context,
    BidModel bid,
  ) async {
    _bidSubscription?.cancel();
    _bidSubscription = null;

    _audioService.stopAlert();
    _audioService.playRideRequestAlert();

    withdrawBid();

    final booking = await _supabaseService.getBookingById(bookingId);
    if (booking != null) {
      _activeDriverTrip = booking.copyWith(
        status: 'accepted',
        driverId: driverId,
      );
    }

    await _offlineTripService.saveActiveTrip(
      bookingId: bookingId,
      status: 'accepted',
      driverId: driverId,
    );
    await checkActiveDriverTrip(driverId);

    if (context.mounted) {
      _showSnackBar(
        context,
        '🎉 Bid Accepted by Customer (₹${bid.driverBid.toStringAsFixed(0)})! Navigating to Pickup...',
        backgroundColor: const Color(0xFF09A234),
      );
      GoRouter.of(context).go('/driver/pickup/$bookingId');
    }
  }

  void _onBidClosed(
    String bookingId,
    String status,
    BuildContext context,
  ) {
    _bidSubscription?.cancel();
    _bidSubscription = null;
    withdrawBid();
    if (context.mounted) {
      _showSnackBar(
        context,
        'Local Adda trip was closed or awarded to another driver.',
        backgroundColor: Colors.black87,
      );
    }
  }

  /// Stop stream listener and polling timer
  void stopBroadcastListening() {
    _audioService.stopAlert();
    _bidSubscription?.cancel();
    _bidSubscription = null;
    _subscription?.cancel();
    _subscription = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _activeBroadcastBooking = null;
    _isModalOpen = false;
    _activeShowingBookingId = null;
    notifyListeners();
  }

  /// ATOMIC RIDE ACCEPTANCE via Supabase RPC function accept_booking_request
  Future<void> acceptRide({
    required String bookingId,
    required String driverId,
    required BuildContext context,
    BookingModel? booking,
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
        final targetBooking = booking ?? _activeBroadcastBooking;
        final serviceName = targetBooking?.service
                ?.toLowerCase()
                .trim()
                .replaceAll('-', '_')
                .replaceAll(' ', '_') ??
            '';
        final isOutstation = serviceName.contains('outstation');

        // If outstation ride, reduce ₹100 from driver's wallet upon acceptance
        if (isOutstation) {
          unawaited(_supabaseService.deductDriverWalletForBookingAcceptance(
            driverId: driverId,
            bookingId: bookingId,
            amount: 100.0,
          ));
        }

        if (_isModalOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          _isModalOpen = false;
          _activeShowingBookingId = null;
        }

        if (_activeBroadcastBooking != null) {
          _activeDriverTrip = _activeBroadcastBooking?.copyWith(
              status: 'accepted', driverId: driverId);
        } else if (booking != null) {
          _activeDriverTrip =
              booking.copyWith(status: 'accepted', driverId: driverId);
        }
        await _offlineTripService.saveActiveTrip(
          bookingId: bookingId,
          status: 'accepted',
          driverId: driverId,
        );
        checkActiveDriverTrip(driverId);

        if (!context.mounted) return;

        final snackMessage = isOutstation
            ? '🎉 Outstation Ride Accepted! ₹100 deducted from wallet. Navigating to Pickup...'
            : '🎉 Ride Accepted! Navigating to Pickup...';

        _showSnackBar(
          context,
          snackMessage,
          backgroundColor: const Color(0xFF09A234),
        );
        GoRouter.of(context).go('/driver/pickup/$bookingId');
      } else {
        if (_isModalOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          _isModalOpen = false;
          _activeShowingBookingId = null;
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
    _activeShowingBookingId = null;
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
