import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/audio_service.dart';
import '../../models/booking_model.dart';
import '../../models/intermediate_stop_model.dart';
import '../../models/vehicle_type_model.dart';

import '../../viewmodels/ride_request_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/route_location_tile.dart';
import '../../widgets/waiting_time_widget.dart';

class DriverPickupView extends StatefulWidget {
  final String bookingId;

  const DriverPickupView({
    super.key,
    required this.bookingId,
  });

  @override
  State<DriverPickupView> createState() => _DriverPickupViewState();
}

class _DriverPickupViewState extends State<DriverPickupView> {
  BookingModel? _booking;
  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  File? _pickupImageFile;
  bool _isUploadingPickup = false;
  File? _podImageFile;
  bool _isUploadingPod = false;
  Map<String, dynamic> _driverExtraCharges = {};
  Timer? _statusCheckTimer;
  Timer? _liveUiTimer;
  DateTime? _localArrivedAtPickupAt;
  DateTime? _localArrivedAtDropoffAt;
  List<VehicleTypeModel> _vehicleTypes = [];

  @override
  void initState() {
    super.initState();
    _loadVehicleTypes();
    _loadBookingDetails();
    _startStatusCheckTimer();
    _startLiveTimer();
  }

  Future<void> _loadVehicleTypes() async {
    try {
      final types = await SupabaseService.instance.fetchVehicleTypes();
      if (mounted && types.isNotEmpty) {
        setState(() {
          _vehicleTypes = types;
        });
      }
    } catch (e) {
      debugPrint('Error loading vehicle types: $e');
    }
  }

  void _startLiveTimer() {
    _liveUiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final status = _booking?.status.toLowerCase();
      if (status == 'arrived' || status == 'arrived_at_dropoff') {
        setState(() {});
      }
    });
  }

  void _startStatusCheckTimer() {
    _statusCheckTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) return;
      final updatedBooking = await SupabaseService.instance
          .getBookingById(widget.bookingId, bookingIdx: _booking?.idx);
      if (!mounted) return;
      if (updatedBooking != null) {
        if (updatedBooking.status == 'cancelled') {
          timer.cancel();
          _statusCheckTimer = null;
          if (mounted) {
            context.read<RideRequestViewModel>().clearActiveDriverTrip();
            context.read<ProfileViewModel>().setTripActive(false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Ride was cancelled by customer'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 4),
              ),
            );
            context.go('/home');
          }
          return;
        }
        if (mounted) {
          setState(() {
            _booking = updatedBooking;
          });
        }
      }
    });
  }

  Future<void> _loadBookingDetails() async {
    final booking = await SupabaseService.instance
        .getBookingById(widget.bookingId, bookingIdx: _booking?.idx);
    if (mounted) {
      if (booking?.status == 'cancelled') {
        context.read<RideRequestViewModel>().clearActiveDriverTrip();
        context.read<ProfileViewModel>().setTripActive(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Ride was cancelled by customer'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
        context.go('/home');
        return;
      }
      setState(() {
        _booking = booking;
        _isLoading = false;
      });
      // Enable active trip location tracking (5-second interval + SnackBar)
      context.read<ProfileViewModel>().setTripActive(true, context);
    }
  }

  ProfileViewModel? _profileViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
    _liveUiTimer?.cancel();
    _liveUiTimer = null;
    _profileViewModel?.setTripActive(false);
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer phone number not available'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    final Uri url = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make call: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _callAmbulance() async {
    final Uri url = Uri.parse('tel:108');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch dialer for 108: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSosConfirmationModal() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actionsOverflowDirection: VerticalDirection.up,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services_rounded,
                  color: Colors.red, size: 28),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'EMERGENCY SOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you in an emergency situation?',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              SizedBox(height: 8),
              Text(
                'Tapping "Call Ambulance 108" will open your phone dialer to directly call Emergency Ambulance Services (108).',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.phone_in_talk_rounded,
                color: Colors.white, size: 18),
            label: const Text('CALL AMBULANCE (108)',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _callAmbulance();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendSms(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer phone number not available'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    final Uri url = Uri.parse('sms:$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open SMS: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openGoogleMaps({
    required double lat,
    required double lng,
    required String fallbackAddress,
    List<IntermediateStopModel>? waypoints,
  }) async {
    Uri url;
    if (lat != 0.0 && lng != 0.0) {
      String waypointsParam = '';
      if (waypoints != null && waypoints.isNotEmpty) {
        final validWaypoints = waypoints
            .where((w) => w.latitude != 0.0 && w.longitude != 0.0)
            .map((w) => '${w.latitude},${w.longitude}')
            .join('|');
        if (validWaypoints.isNotEmpty) {
          waypointsParam = '&waypoints=${Uri.encodeComponent(validWaypoints)}';
        }
      }
      url = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng$waypointsParam&travelmode=driving');
    } else if (fallbackAddress.isNotEmpty) {
      final encoded = Uri.encodeComponent(fallbackAddress);
      url = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$encoded&travelmode=driving');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location coordinates or address not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Google Maps: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showFareBreakdownModal() {
    final booking = _booking;
    if (booking == null) return;

    final amountMap = booking.amount ?? {};
    final baseFare =
        (amountMap['base_fare'] ?? booking.baseFare ?? 0.0).toDouble();
    final distanceCharges =
        (amountMap['distance_charges'] ?? booking.distanceCharges ?? 0.0)
            .toDouble();
    final stopsCharge = (amountMap['stops_charge'] ??
            booking.stopsCharge ??
            (booking.stopsCount * 25.0))
        .toDouble();
    final waitingCharges =
        (amountMap['waiting_charges'] ?? booking.waitingCharges ?? 0.0)
            .toDouble();
    final rawTripPrice =
        (amountMap['total_price'] ?? booking.fare ?? 0.0).toDouble();
    final totalPrice = rawTripPrice + waitingCharges;

    final calcBaseFare = baseFare > 0
        ? baseFare
        : (rawTripPrice > 0
            ? (rawTripPrice - distanceCharges - stopsCharge)
            : 0.0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'TRIP FARE BREAKDOWN',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _FareItemRow(
                  label: 'Base Fare (Includes 1st KM)',
                  amount: calcBaseFare > 0 ? calcBaseFare : 0.0),
              const SizedBox(height: 10),
              _FareItemRow(
                  label: 'Distance Charges (beyond 1 KM)',
                  amount: distanceCharges),
              const SizedBox(height: 10),
              _FareItemRow(
                label:
                    'Stops Charge (${booking.stopsCount} stop${booking.stopsCount != 1 ? 's' : ''} @ ₹25 each)',
                amount: stopsCharge,
                isHighlight: booking.hasStops,
              ),
              const SizedBox(height: 10),
              _FareItemRow(
                label: 'Waiting Charges',
                amount: waitingCharges,
                isHighlight: waitingCharges > 0,
              ),
              const SizedBox(height: 10),
              const _FareItemRow(
                  label: 'Taxes & GST', amount: 0.0, isZero: true),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Delivery Fee',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Text('₹ ${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(modalContext),
                  child: const Text('CLOSE',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveWaitingTimerCard(BookingModel booking) {
    final currentStatus = booking.status.toLowerCase();
    final isAtPickup =
        currentStatus == 'arrived' || currentStatus == 'arrived_at_pickup';
    final isAtDropoff = currentStatus == 'arrived_at_dropoff' ||
        currentStatus == 'arrived_at_drop_off';

    if (!isAtPickup && !isAtDropoff) return const SizedBox.shrink();

    int graceTimeMins =
        (booking.graceTimeMinutes ?? 0) > 0 ? booking.graceTimeMinutes! : 15;
    double waitFeePerMin =
        booking.waitFeePerMin > 0 ? booking.waitFeePerMin : 0.0;

    final vehicleTypeId = booking.vehicleTypeId;
    if (vehicleTypeId != null && vehicleTypeId.isNotEmpty) {
      for (final vt in _vehicleTypes) {
        if (vt.id == vehicleTypeId ||
            vt.name.toLowerCase() == vehicleTypeId.toLowerCase()) {
          graceTimeMins = vt.graceTime;
          waitFeePerMin = vt.waitTime.toDouble();
          break;
        }
      }
    }

    final rateText =
        '₹ ${waitFeePerMin.toStringAsFixed(0)}/min after $graceTimeMins mins free grace period';

    return WaitingTimeWidget(
      type: booking.status,
      rateText: rateText,
      graceMins: graceTimeMins,
      pickupWaitSeconds: booking.pickupWaitSeconds,
      arrivedAtPickup: booking.arrivedAtPickupAt ?? _localArrivedAtPickupAt,
      arrivedAtDropOff: booking.arrivedAtDropoffAt ?? _localArrivedAtDropoffAt,
    );
  }

  Map<String, dynamic> _buildStatusExtraData(String newStatus) {
    final now = DateTime.now();
    final nowUtcIso = now.toUtc().toIso8601String();

    if (newStatus == 'arrived') {
      final arrivedTime =
          _booking?.arrivedAtPickupAt ?? _localArrivedAtPickupAt ?? now;
      return {'arrived_at_pickup_at': arrivedTime.toUtc().toIso8601String()};
    } else if (newStatus == 'in_transit') {
      final arrivedAtPickupAt =
          _booking?.arrivedAtPickupAt ?? _localArrivedAtPickupAt;
      int pickupWaitSeconds = 0;
      if (arrivedAtPickupAt != null) {
        pickupWaitSeconds = max(0, now.difference(arrivedAtPickupAt).inSeconds);
      } else if (_booking?.pickupWaitSeconds != null &&
          _booking!.pickupWaitSeconds! > 0) {
        pickupWaitSeconds = _booking!.pickupWaitSeconds!;
      }

      return {
        'pickup_wait_seconds': pickupWaitSeconds,
        'trip_started_at': nowUtcIso,
      };
    } else if (newStatus == 'arrived_at_dropoff') {
      final arrivedTime =
          _booking?.arrivedAtDropoffAt ?? _localArrivedAtDropoffAt ?? now;
      return {'arrived_at_dropoff_at': arrivedTime.toUtc().toIso8601String()};
    } else if (newStatus == 'drop_complete' || newStatus == 'completed') {
      final arrivedAtDropoffAt =
          _booking?.arrivedAtDropoffAt ?? _localArrivedAtDropoffAt;
      int dropWaitSeconds = 0;
      final pickupWaitSecs = _booking?.pickupWaitSeconds ?? 0;
      if (arrivedAtDropoffAt != null) {
        dropWaitSeconds = max(0, now.difference(arrivedAtDropoffAt).inSeconds) -
            pickupWaitSecs;
        if (dropWaitSeconds < 0) dropWaitSeconds = 0;
      }

      final totalWaitSeconds = dropWaitSeconds + pickupWaitSecs;
      final totalWaitMinutes = (totalWaitSeconds / 60).floor();

      int graceTimeMins = _booking?.graceTimeMinutes ?? 15;
      if (graceTimeMins <= 0) graceTimeMins = 15;
      double waitFeePerMin = _booking?.waitFeePerMin ?? 0.0;

      final vehicleTypeId = _booking?.vehicleTypeId;
      if (vehicleTypeId != null && vehicleTypeId.isNotEmpty) {
        for (final vt in _vehicleTypes) {
          if (vt.id == vehicleTypeId ||
              vt.name.toLowerCase() == vehicleTypeId.toLowerCase()) {
            graceTimeMins = vt.graceTime;
            waitFeePerMin = vt.waitTime.toDouble();
            break;
          }
        }
      }
      final chargeableWaitMinutes = max(0, totalWaitMinutes - graceTimeMins);
      final waitingCharges = chargeableWaitMinutes * waitFeePerMin;

      return {
        'dropoff_wait_seconds': dropWaitSeconds,
        'total_wait_minutes': totalWaitMinutes,
        'grace_time_minutes': graceTimeMins,
        'chargeable_wait_minutes': chargeableWaitMinutes,
        'wait_fee_per_min': waitFeePerMin,
        'waiting_charges': waitingCharges,
        'trip_completed_at': nowUtcIso,
      };
    }

    return {};
  }

  Future<void> _updateStatus(String newStatus, String successMessage) async {
    if (_isUpdatingStatus) return;

    final now = DateTime.now();
    if (newStatus == 'arrived') {
      _localArrivedAtPickupAt ??= now;
    } else if (newStatus == 'arrived_at_dropoff') {
      _localArrivedAtDropoffAt ??= now;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final extraData = _buildStatusExtraData(newStatus);

      await SupabaseService.instance.updateBookingStatus(
        widget.bookingId,
        newStatus,
        bookingIdx: _booking?.idx,
        extraData: extraData,
      );
      final reloadedBooking = await SupabaseService.instance
          .getBookingById(widget.bookingId, bookingIdx: _booking?.idx);

      if (mounted) {
        setState(() {
          final effectiveBooking = reloadedBooking ?? _booking;
          _booking = effectiveBooking?.copyWith(
            status: newStatus,
            arrivedAtPickupAt:
                effectiveBooking.arrivedAtPickupAt ?? _localArrivedAtPickupAt,
            arrivedAtDropoffAt:
                effectiveBooking.arrivedAtDropoffAt ?? _localArrivedAtDropoffAt,
          );
          _isUpdatingStatus = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (newStatus == 'completed') {
          context.read<ProfileViewModel>().setTripActive(false);
          context.read<RideRequestViewModel>().clearActiveDriverTrip();
          final driverId = _booking?.driverId;
          if (driverId != null && driverId.isNotEmpty) {
            context.read<ProfileViewModel>().fetchProfile(driverId, context);
            context.read<HomeViewModel>().loadDashboard(driverId);
          }
          _showCustomerRatingModal();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleReceivedPaymentClick() {
    final modeStr = (_booking?.paymentMode ?? '').toLowerCase();
    final isOnlinePayment =
        modeStr.contains('online') || modeStr.contains('razorpay');

    // If online payment selected by customer and status is not yet amount_paid
    if (isOnlinePayment && _booking?.status != 'amount_paid') {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          actionsOverflowDirection: VerticalDirection.up,
          title: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded,
                  color: Color(0xFFF59E0B), size: 26),
              SizedBox(width: 10),
              Flexible(
                child: Text('Online Payment Pending',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'The customer selected Online Payment (Razorpay). The payment has not been confirmed yet.\n\nPlease ask the customer to complete payment on their phone. The status will automatically update to "Payment Received" once paid.',
              style: TextStyle(
                  fontSize: 13, height: 1.4, color: AppColors.textSecondary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('WAIT FOR PAYMENT',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                _confirmCashPaymentModal();
              },
              child: const Text('RECEIVED CASH INSTEAD',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      _confirmCashPaymentModal();
    }
  }

  void _confirmCashPaymentModal() {
    final double tripFare =
        (_booking?.amount?['total_price'] ?? _booking?.fare ?? 0.0).toDouble() +
            (_booking?.waitingCharges ?? 0);
    final double incentive = (_booking?.farDriverIncentive != null &&
            (_booking!.farDriverIncentive!) > 0)
        ? _booking!.farDriverIncentive!
        : 0.0;
    final double totalFare = tripFare + incentive;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actionsOverflowDirection: VerticalDirection.up,
        title: const Row(
          children: [
            Icon(Icons.payments_rounded, color: Color(0xFF10B981), size: 26),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Confirm Cash Payment',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Did you collect ₹${totalFare.toStringAsFixed(0)} cash directly from the customer?',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              if (incentive > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border:
                        Border.all(color: const Color(0xFF10B981), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trip Fare',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          Text('₹${tripFare.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Far Driver Incentive 🎁',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold)),
                          Text('+ ₹${incentive.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total to Collect',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          Text('₹${totalFare.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _updateStatus(
                'amount_paid',
                'Cash Payment Received! Please confirm trip completion.',
              );
            },
            child: const Text('YES, RECEIVED CASH',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleIntermediateStopAction({
    required int stopIndex,
    required String action,
  }) async {
    final booking = _booking;
    if (booking == null) return;

    final currentStops = booking.effectiveIntermediateStops;
    final List<Map<String, dynamic>> updatedStopsJson = [];

    for (int i = 0; i < currentStops.length; i++) {
      final s = currentStops[i];
      if (i == stopIndex) {
        updatedStopsJson.add({
          'latitude': s.latitude,
          'longitude': s.longitude,
          'address': s.address,
          'is_completed': action == 'completed',
          'status': action,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        updatedStopsJson.add(s.toJson());
      }
    }

    try {
      await SupabaseService.instance.updateIntermediateStopStatus(
        bookingId: booking.id,
        bookingIdx: booking.idx,
        stopIndex: stopIndex,
        stopStatus: action,
        updatedStopsJson: updatedStopsJson,
      );

      final stopNum = stopIndex + 1;
      final msg = action == 'reached'
          ? 'Reached Stop $stopNum!'
          : 'Completed Stop $stopNum!';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: action == 'completed'
                ? const Color(0xFF10B981)
                : Colors.amber.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await _loadBookingDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating stop status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showTripCancellationModal() {
    String selectedReason = 'Customer No-Show at Pickup';
    bool isCancelling = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final List<String> reasons = [
              'Customer No-Show at Pickup',
              'Oversized Goods',
              'Vehicle Breakdown',
              'Customer Requested Cancellation',
              'Other Issue',
            ];

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CANCEL TRIP REQUEST',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Please select a cancellation reason',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...reasons.map((reason) {
                    final isSelected = selectedReason == reason;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedReason = reason;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.error.withValues(alpha: 0.08)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.error : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? AppColors.error
                                  : AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: isCancelling
                          ? null
                          : () async {
                              setModalState(() {
                                isCancelling = true;
                              });

                              try {
                                await SupabaseService.instance
                                    .cancelBookingWithReason(
                                  bookingId: widget.bookingId,
                                  reason: selectedReason,
                                );

                                if (context.mounted) {
                                  Navigator.of(modalContext).pop();
                                  context
                                      .read<RideRequestViewModel>()
                                      .clearActiveDriverTrip();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Trip cancelled.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  context.go('/home');
                                }
                              } catch (e) {
                                setModalState(() {
                                  isCancelling = false;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error cancelling trip: $e')),
                                  );
                                }
                              }
                            },
                      child: isCancelling
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'CONFIRM CANCELLATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddExtraChargesPopup(
      BuildContext dialogContext, StateSetter setParentModalState) {
    final chargeNameController = TextEditingController();
    final chargeAmountController = TextEditingController();
    Map<String, dynamic> tempChargesMap =
        Map<String, dynamic>.from(_driverExtraCharges);

    showDialog(
      context: dialogContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'ADD EXTRA CHARGES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add extra trip expenses (e.g. Toll, Gas, Parking):',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: chargeNameController,
                      decoration: InputDecoration(
                        labelText: 'Charge Name',
                        hintText: 'e.g. toll',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: chargeAmountController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[0-9]+(?:[.,][0-9]{1,2})?$')),
                      ],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Charge Number / Amount (₹)',
                        hintText: 'e.g. 55',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // + ADD Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('ADD',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        onPressed: () {
                          final name =
                              chargeNameController.text.trim().toLowerCase();
                          final amountText = chargeAmountController.text.trim();
                          final numVal = double.tryParse(amountText);

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please enter a charge name (e.g., toll)')),
                            );
                            return;
                          }
                          if (numVal == null || numVal <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please enter a valid numeric charge amount')),
                            );
                            return;
                          }

                          setDialogState(() {
                            tempChargesMap[name] =
                                numVal % 1 == 0 ? numVal.toInt() : numVal;
                            chargeNameController.clear();
                            chargeAmountController.clear();
                          });
                        },
                      ),
                    ),

                    if (tempChargesMap.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Added Charges List:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tempChargesMap.entries.map((entry) {
                          return Chip(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            label: Text(
                              '${entry.key}: ₹${entry.value}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            deleteIcon: const Icon(Icons.close,
                                size: 16, color: AppColors.error),
                            onDeleted: () {
                              setDialogState(() {
                                tempChargesMap.remove(entry.key);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setParentModalState(() {
                      _driverExtraCharges =
                          Map<String, dynamic>.from(tempChargesMap);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('SUBMIT',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCargoPickupPhotoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARGO PICKUP PHOTO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Photo of loaded cargo is MANDATORY to start trip',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Image Preview Box
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _pickupImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_pickupImageFile!,
                                fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: AppColors.primary,
                                size: 42,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Tap Camera or Gallery below to capture pickup photo',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.camera_alt_rounded,
                              color: AppColors.primary),
                          label: const Text('Camera'),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                                source: ImageSource.camera, imageQuality: 80);
                            if (picked != null) {
                              setModalState(() {
                                _pickupImageFile = File(picked.path);
                              });
                              setState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.photo_library_rounded,
                              color: AppColors.textSecondary),
                          label: const Text('Gallery'),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                                source: ImageSource.gallery, imageQuality: 80);
                            if (picked != null) {
                              setModalState(() {
                                _pickupImageFile = File(picked.path);
                              });
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  GradientButton(
                    text: 'CONFIRM PHOTO & START TRIP',
                    isLoading: _isUploadingPickup || _isUpdatingStatus,
                    icon: Icons.play_arrow_rounded,
                    onPressed: () async {
                      if (_pickupImageFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please capture or select a pickup photo first!'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setModalState(() {
                        _isUploadingPickup = true;
                      });

                      try {
                        final pickupUrl =
                            await SupabaseService.instance.uploadImage(
                          bucket: 'bookings',
                          filePath: _pickupImageFile!.path,
                          fileName:
                              'pickup_${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                        );

                        await SupabaseService.instance.updateBookingPickupUrl(
                          widget.bookingId,
                          pickupUrl,
                          bookingIdx: _booking?.idx,
                        );

                        if (modalContext.mounted) {
                          Navigator.pop(modalContext);
                        }

                        await _updateStatus(
                          'in_transit',
                          'Cargo pickup photo saved! Trip started.',
                        );
                        // 🔔 Play pickup start sound when ride begins
                        AudioService.instance.playPickupStartAlert();
                      } catch (e) {
                        setModalState(() {
                          _isUploadingPickup = false;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Failed to upload pickup photo: $e'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showProofOfDeliveryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROOF OF DELIVERY (POD)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Take a photo of delivered goods (MANDATORY)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Image Preview Box
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _podImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:
                                Image.file(_podImageFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined,
                                size: 44,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Proof of Delivery photo is MANDATORY',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon:
                                        const Icon(Icons.camera_alt, size: 16),
                                    label: const Text('Camera'),
                                    onPressed: () async {
                                      final picked =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 70,
                                      );
                                      if (picked != null) {
                                        setModalState(() {
                                          _podImageFile = File(picked.path);
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppColors.border),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.photo_library,
                                        size: 16, color: AppColors.textPrimary),
                                    label: const Text('Gallery',
                                        style: TextStyle(
                                            color: AppColors.textPrimary)),
                                    onPressed: () async {
                                      final picked =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 70,
                                      );
                                      if (picked != null) {
                                        setModalState(() {
                                          _podImageFile = File(picked.path);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),

                  if (!(_booking?.service?.toLowerCase().contains('bidding') ??
                      false)) ...[
                    const SizedBox(height: 16),

                    // Add Extra Charges Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          color: AppColors.primary),
                      label: const Text(
                        'ADD EXTRA CHARGES',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      onPressed: () {
                        _showAddExtraChargesPopup(modalContext, setModalState);
                      },
                    ),

                    if (_driverExtraCharges.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Driver Extra Charges:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showAddExtraChargesPopup(
                                        modalContext, setModalState);
                                  },
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: _driverExtraCharges.entries.map((e) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    '${e.key}: ₹${e.value}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 20),

                  GradientButton(
                    text: 'SUBMIT POD & UNLOAD CARGO',
                    icon: Icons.task_alt_rounded,
                    isLoading: _isUploadingPod,
                    onPressed: () async {
                      if (_podImageFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Proof of Delivery photo is MANDATORY before completing delivery.'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setModalState(() {
                        _isUploadingPod = true;
                      });
                      try {
                        if (_driverExtraCharges.isNotEmpty) {
                          await SupabaseService.instance.saveDriverCharges(
                            bookingId: widget.bookingId,
                            driverCharges: _driverExtraCharges,
                            bookingIdx: _booking?.idx,
                          );
                        }

                        await SupabaseService.instance.uploadPodImage(
                          bookingId: widget.bookingId,
                          file: _podImageFile!,
                          bookingIdx: _booking?.idx,
                        );
                      } catch (e) {
                        debugPrint('Notice uploading POD photo/charges: $e');
                      }

                      if (!modalContext.mounted) return;
                      Navigator.of(modalContext).pop();
                      await _loadBookingDetails();
                      await _updateStatus('drop_complete',
                          '📦 Cargo unloaded & POD submitted! Awaiting payment.');
                      // 🔔 Play drop complete sound when cargo is unloaded
                      AudioService.instance.playDropCompleteAlert();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomerRatingModal() {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Column(
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFEAB308), size: 48),
                  SizedBox(height: 8),
                  Text(
                    'RATE THE CUSTOMER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'How was your experience with this trip?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      return IconButton(
                        icon: Icon(
                          starValue <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFEAB308),
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = starValue;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Add optional comment...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    GoRouter.of(context).go('/home');
                  },
                  child: const Text('SKIP'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final driverId =
                        context.read<ProfileViewModel>().driver?.id ?? '';
                    if (driverId.isNotEmpty && _booking != null) {
                      await SupabaseService.instance.submitCustomerRating(
                        bookingId: widget.bookingId,
                        customerId: _booking!.customerId,
                        driverId: driverId,
                        rating: selectedRating,
                        comment: commentController.text.trim(),
                      );
                    }
                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                      GoRouter.of(context).go('/home');
                    }
                  },
                  child: const Text('SUBMIT RATING',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = _booking?.status ?? 'accepted';
    final isTransit = currentStatus == 'in_transit' ||
        currentStatus == 'drop_complete' ||
        currentStatus == 'amount_paid';

    final navLat =
        isTransit ? (_booking?.dropLat ?? 0.0) : (_booking?.pickupLat ?? 0.0);
    final navLng =
        isTransit ? (_booking?.dropLng ?? 0.0) : (_booking?.pickupLng ?? 0.0);
    final navAddress = isTransit
        ? (_booking?.dropAddress ?? '')
        : (_booking?.pickupAddress ?? '');
    final navTargetLabel =
        isTransit ? 'Dropoff Location' : 'Customer Pickup Location';

    final customerPhone = _booking?.customerPhone ?? '';
    final customerName = _booking?.customerName ?? 'Customer';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentStatus == 'amount_paid'
              ? 'Payment Confirmed'
              : (currentStatus == 'drop_complete'
                  ? 'Awaiting Payment'
                  : (currentStatus == 'in_transit'
                      ? 'Trip in Transit'
                      : (currentStatus == 'arrived'
                          ? 'Arrived at Pickup'
                          : 'Pickup Navigation'))),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.medical_services_rounded,
                  color: Colors.white, size: 16),
              label: const Text(
                'SOS (108)',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              onPressed: _showSosConfirmationModal,
            ),
          ),
          IconButton(
            tooltip: 'Cancel Trip',
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
            onPressed: _showTripCancellationModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: currentStatus == 'amount_paid'
                          ? const Color(0xFFDCFCE7)
                          : (currentStatus == 'drop_complete'
                              ? const Color(0xFFFEF3C7)
                              : (currentStatus == 'arrived'
                                  ? const Color(0xFFFEF3C7)
                                  : (currentStatus == 'in_transit'
                                      ? const Color(0xFFE0F2FE)
                                      : const Color(0xFFDCFCE7)))),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: currentStatus == 'amount_paid'
                            ? const Color(0xFF10B981)
                            : (currentStatus == 'drop_complete'
                                ? const Color(0xFFF59E0B)
                                : (currentStatus == 'arrived'
                                    ? const Color(0xFFF59E0B)
                                    : (currentStatus == 'in_transit'
                                        ? const Color(0xFF0284C7)
                                        : AppColors.primary))),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          currentStatus == 'amount_paid'
                              ? Icons.check_circle_rounded
                              : (currentStatus == 'drop_complete'
                                  ? Icons.payments_rounded
                                  : (currentStatus == 'arrived'
                                      ? Icons.location_city_rounded
                                      : (currentStatus == 'in_transit'
                                          ? Icons.local_shipping_rounded
                                          : Icons.navigation_rounded))),
                          color: currentStatus == 'amount_paid'
                              ? const Color(0xFF10B981)
                              : (currentStatus == 'drop_complete'
                                  ? const Color(0xFFD97706)
                                  : (currentStatus == 'arrived'
                                      ? const Color(0xFFD97706)
                                      : (currentStatus == 'in_transit'
                                          ? const Color(0xFF0284C7)
                                          : AppColors.primary))),
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentStatus == 'amount_paid'
                                    ? 'PAYMENT RECEIVED'
                                    : (currentStatus == 'drop_complete'
                                        ? 'UNLOADED / AWAITING PAYMENT'
                                        : (currentStatus == 'arrived_at_dropoff'
                                            ? 'ARRIVED AT DROP-OFF LOCATION'
                                            : (currentStatus == 'arrived'
                                                ? 'ARRIVED AT PICKUP LOCATION'
                                                : (currentStatus == 'in_transit'
                                                    ? 'TRIP IN TRANSIT TO DROP POINT'
                                                    : 'HEADING TO PICKUP')))),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: currentStatus == 'amount_paid'
                                      ? const Color(0xFF15803D)
                                      : (currentStatus == 'drop_complete'
                                          ? const Color(0xFFB45309)
                                          : (currentStatus ==
                                                  'arrived_at_dropoff'
                                              ? const Color(0xFF9333EA)
                                              : (currentStatus == 'arrived'
                                                  ? const Color(0xFFB45309)
                                                  : (currentStatus ==
                                                          'in_transit'
                                                      ? const Color(0xFF0369A1)
                                                      : AppColors
                                                          .primaryDark)))),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentStatus == 'amount_paid'
                                    ? 'Payment confirmed! Tap below to finalize trip completion.'
                                    : (currentStatus == 'drop_complete'
                                        ? 'Collect cash payment or wait for customer online payment.'
                                        : (currentStatus == 'arrived_at_dropoff'
                                            ? 'Unloading timer active! Submit POD once unloading is complete.'
                                            : (currentStatus == 'arrived'
                                                ? 'Loading timer active! Tap START TRIP once loaded.'
                                                : (currentStatus == 'in_transit'
                                                    ? 'On the way to dropoff destination'
                                                    : 'Follow GPS route to customer location')))),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // SOS Emergency Banner Button
                  InkWell(
                    onTap: _showSosConfirmationModal,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.medical_services_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EMERGENCY SOS',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Tap to call Ambulance (108) from dialer',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.call, color: Colors.red, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  '108',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_booking != null) _buildLiveWaitingTimerCard(_booking!),

                  // Customer Contact Quick Actions Card (Call / SMS)

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.person,
                                    color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      customerPhone,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Call Customer',
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                              ),
                              icon: const Icon(Icons.call_rounded,
                                  color: AppColors.primary),
                              onPressed: () => _makePhoneCall(customerPhone),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Send SMS',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7)
                                    .withValues(alpha: 0.1),
                              ),
                              icon: const Icon(Icons.message_rounded,
                                  color: Color(0xFF0284C7)),
                              onPressed: () => _sendSms(customerPhone),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prominent Google Maps Navigation Card
                  InkWell(
                    onTap: () => _openGoogleMaps(
                      lat: navLat,
                      lng: navLng,
                      fallbackAddress: navAddress,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A73E8), Color(0xFF1557B0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF1A73E8).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.near_me_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'OPEN GOOGLE MAPS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Navigate to $navTargetLabel',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'GO',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A73E8),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Color(0xFF1A73E8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Booking Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'BOOKING #${widget.bookingId.length > 8 ? widget.bookingId.substring(0, 8).toUpperCase() : widget.bookingId}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                currentStatus.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Route Timeline (Pickup, Intermediate Stops, Drop with Distance Pills)
                        Builder(
                          builder: (context) {
                            final rideVm = Provider.of<RideRequestViewModel>(
                                context,
                                listen: false);
                            final driverPos =
                                LocationService.instance.currentPosition;
                            double driverLat = driverPos?.latitude ?? 0.0;
                            double driverLng = driverPos?.longitude ?? 0.0;

                            if (driverLat == 0.0 || driverLng == 0.0) {
                              try {
                                final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
                                if (profileVm.latitude != 0.0 && profileVm.longitude != 0.0) {
                                  driverLat = profileVm.latitude;
                                  driverLng = profileVm.longitude;
                                }
                              } catch (_) {}
                            }

                            final pickupDistKm = (driverLat != 0.0 &&
                                    driverLng != 0.0 &&
                                    _booking != null &&
                                    _booking!.pickupLat != 0.0 &&
                                    _booking!.pickupLng != 0.0)
                                ? rideVm.calculateDistance(driverLat, driverLng,
                                    _booking!.pickupLat, _booking!.pickupLng)
                                : 0.0;

                            double calculatedTotalTripDist = 0.0;
                            if (_booking != null &&
                                _booking!.pickupLat != 0.0 &&
                                _booking!.pickupLng != 0.0) {
                              if (_booking!.hasStops &&
                                  _booking!
                                      .effectiveIntermediateStops.isNotEmpty) {
                                double currentLat = _booking!.pickupLat;
                                double currentLng = _booking!.pickupLng;
                                for (final stop
                                    in _booking!.effectiveIntermediateStops) {
                                  if (stop.latitude != 0.0 &&
                                      stop.longitude != 0.0) {
                                    calculatedTotalTripDist +=
                                        rideVm.calculateDistance(
                                            currentLat,
                                            currentLng,
                                            stop.latitude,
                                            stop.longitude);
                                    currentLat = stop.latitude;
                                    currentLng = stop.longitude;
                                  }
                                }
                                if (_booking!.dropLat != 0.0 &&
                                    _booking!.dropLng != 0.0) {
                                  calculatedTotalTripDist +=
                                      rideVm.calculateDistance(
                                          currentLat,
                                          currentLng,
                                          _booking!.dropLat,
                                          _booking!.dropLng);
                                }
                              } else if (_booking!.dropLat != 0.0 &&
                                  _booking!.dropLng != 0.0) {
                                calculatedTotalTripDist =
                                    rideVm.calculateDistance(
                                        _booking!.pickupLat,
                                        _booking!.pickupLng,
                                        _booking!.dropLat,
                                        _booking!.dropLng);
                              }
                            }
                            final dropDistKm = calculatedTotalTripDist;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: RouteLocationTile(
                                        type: LocationTileType.pickup,
                                        address: _booking?.pickupAddress
                                                    .isNotEmpty ==
                                                true
                                            ? _booking!.pickupAddress
                                            : 'Customer Pickup Point',
                                        distanceKm: pickupDistKm,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Navigate to Pickup in GMaps',
                                      icon: const Icon(
                                          Icons.directions_outlined,
                                          color: Color(0xFF1A73E8)),
                                      onPressed: () => _openGoogleMaps(
                                        lat: _booking?.pickupLat ?? 0.0,
                                        lng: _booking?.pickupLng ?? 0.0,
                                        fallbackAddress:
                                            _booking?.pickupAddress ?? '',
                                      ),
                                    ),
                                  ],
                                ),

                                const DashedLineConnector(
                                    height: 18, color: Color(0xFF10B981)),

                                // Intermediate Stops Loop with Per-Stop Status Buttons & Distance Pills
                                if (_booking != null && _booking!.hasStops)
                                  ..._booking!.effectiveIntermediateStops
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final i = entry.key;
                                    final idx = i + 1;
                                    final stop = entry.value;
                                    final currentStatus =
                                        _booking!.status.toLowerCase();
                                    final isThisStopReached =
                                        currentStatus == 'stop_${idx}_reached';
                                    final isThisStopCompleted =
                                        stop.isCompleted ||
                                            currentStatus ==
                                                'stop_${idx}_completed';
                                    final isPrevStopCompleted = i == 0 ||
                                        _booking!
                                            .effectiveIntermediateStops[i - 1]
                                            .isCompleted;

                                    final double prevLat = (i == 0)
                                        ? (_booking?.pickupLat ?? 0.0)
                                        : (_booking
                                                ?.effectiveIntermediateStops[
                                                    i - 1]
                                                .latitude ??
                                            0.0);
                                    final double prevLng = (i == 0)
                                        ? (_booking?.pickupLng ?? 0.0)
                                        : (_booking
                                                ?.effectiveIntermediateStops[
                                                    i - 1]
                                                .longitude ??
                                            0.0);

                                    final stopDistKm = (prevLat != 0.0 &&
                                            prevLng != 0.0 &&
                                            stop.latitude != 0.0 &&
                                            stop.longitude != 0.0)
                                        ? rideVm.calculateDistance(
                                            prevLat,
                                            prevLng,
                                            stop.latitude,
                                            stop.longitude)
                                        : 0.0;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isThisStopCompleted
                                                ? const Color(0xFFECFDF5)
                                                : (isThisStopReached
                                                    ? const Color(0xFFFFFBEB)
                                                    : AppColors.background),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isThisStopCompleted
                                                  ? const Color(0xFF10B981)
                                                  : (isThisStopReached
                                                      ? Colors.amber.shade700
                                                      : AppColors.border),
                                              width: isThisStopReached ||
                                                      isThisStopCompleted
                                                  ? 1.5
                                                  : 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: RouteLocationTile(
                                                      type:
                                                          LocationTileType.stop,
                                                      address: stop.address
                                                              .isNotEmpty
                                                          ? stop.address
                                                          : 'Intermediate Stop $idx',
                                                      distanceKm: stopDistKm,
                                                      stopIndex: idx,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    tooltip:
                                                        'Navigate to Stop $idx in GMaps',
                                                    icon: const Icon(
                                                        Icons
                                                            .directions_outlined,
                                                        color:
                                                            Color(0xFFD97706)),
                                                    onPressed: () =>
                                                        _openGoogleMaps(
                                                      lat: stop.latitude,
                                                      lng: stop.longitude,
                                                      fallbackAddress:
                                                          stop.address,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Per-Stop Action Button
                                              if (_booking!.status !=
                                                      'completed' &&
                                                  _booking!.status !=
                                                      'cancelled') ...[
                                                const SizedBox(height: 8),
                                                if (isThisStopCompleted) ...[
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFF10B981)
                                                          .withValues(
                                                              alpha: 0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      '✓ STOP $idx COMPLETED',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF047857),
                                                      ),
                                                    ),
                                                  ),
                                                ] else if (isThisStopReached) ...[
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton.icon(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFF10B981),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8),
                                                      ),
                                                      icon: const Icon(
                                                          Icons
                                                              .done_all_rounded,
                                                          color: Colors.white,
                                                          size: 16),
                                                      label: Text(
                                                        'Complete Stop $idx',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13),
                                                      ),
                                                      onPressed: () =>
                                                          _handleIntermediateStopAction(
                                                              stopIndex: i,
                                                              action:
                                                                  'completed'),
                                                    ),
                                                  ),
                                                ] else if (isPrevStopCompleted) ...[
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton.icon(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Colors
                                                            .amber.shade800,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8),
                                                      ),
                                                      icon: const Icon(
                                                          Icons
                                                              .pin_drop_rounded,
                                                          color: Colors.white,
                                                          size: 16),
                                                      label: Text(
                                                        'Reached Stop $idx',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13),
                                                      ),
                                                      onPressed: () =>
                                                          _handleIntermediateStopAction(
                                                              stopIndex: i,
                                                              action:
                                                                  'reached'),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ],
                                          ),
                                        ),
                                        const DashedLineConnector(
                                            height: 18,
                                            color: Color(0xFFF59E0B)),
                                      ],
                                    );
                                  }),

                                Row(
                                  children: [
                                    Expanded(
                                      child: RouteLocationTile(
                                        type: LocationTileType.drop,
                                        address:
                                            _booking?.dropAddress.isNotEmpty ==
                                                    true
                                                ? _booking!.dropAddress
                                                : 'Customer Dropoff Point',
                                        distanceKm: dropDistKm,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Navigate to Dropoff in GMaps',
                                      icon: const Icon(
                                          Icons.directions_outlined,
                                          color: Color(0xFF1A73E8)),
                                      onPressed: () => _openGoogleMaps(
                                        lat: _booking?.dropLat ?? 0.0,
                                        lng: _booking?.dropLng ?? 0.0,
                                        fallbackAddress:
                                            _booking?.dropAddress ?? '',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        if (_booking != null && _booking!.fare > 0) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Delivery Fare:',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary),
                                    ),
                                    InkWell(
                                      onTap: _showFareBreakdownModal,
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'View Fare Breakdown',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          Icon(Icons.chevron_right_rounded,
                                              size: 14,
                                              color: AppColors.primary),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    () {
                                      final double cardBase =
                                          ((_booking!.amount?['total_price'] ??
                                                      _booking!.fare ??
                                                      0.0) +
                                                  _booking!.waitingCharges)
                                              .toDouble();
                                      final double cardIncentive = (_booking!
                                                      .farDriverIncentive !=
                                                  null &&
                                              _booking!.farDriverIncentive! > 0)
                                          ? _booking!.farDriverIncentive!
                                          : 0.0;
                                      return '₹ ${(cardBase + cardIncentive).toStringAsFixed(2)}';
                                    }(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  if ((_booking!.farDriverIncentive ?? 0) > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        'Incl. ₹${_booking!.farDriverIncentive!.toStringAsFixed(0)} far driver incentive 🎁',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF10B981),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progressive Action Button (ARRIVED -> START TRIP -> INTERMEDIATE STOPS -> FINAL DROPOFF -> POD -> CASH -> COMPLETE)
                  Builder(
                    builder: (context) {
                      final effectiveStops =
                          _booking?.effectiveIntermediateStops ?? [];
                      final firstUncompletedIndex =
                          effectiveStops.indexWhere((s) => !s.isCompleted);
                      final hasPendingStops = _booking?.hasStops == true &&
                          firstUncompletedIndex != -1;

                      if (currentStatus == 'accepted') {
                        return GradientButton(
                          text: 'ARRIVED AT PICKUP',
                          isLoading: _isUpdatingStatus,
                          icon: Icons.check_circle_outline_rounded,
                          onPressed: () => _updateStatus(
                            'arrived',
                            'Customer notified: Driver arrived at pickup location! Loading timer started.',
                          ),
                        );
                      }

                      if (currentStatus == 'arrived') {
                        return GradientButton(
                          text: 'TAKE PICKUP PHOTO & START TRIP',
                          isLoading: _isUpdatingStatus,
                          icon: Icons.camera_alt_rounded,
                          onPressed: _showCargoPickupPhotoModal,
                        );
                      }

                      // If trip has pending intermediate stops
                      if (hasPendingStops &&
                          (currentStatus == 'in_transit' ||
                              currentStatus.startsWith('stop_'))) {
                        final stopIdx = firstUncompletedIndex;
                        final stopNum = stopIdx + 1;
                        final isReached =
                            currentStatus == 'stop_${stopNum}_reached';

                        if (isReached) {
                          return GradientButton(
                            text: 'COMPLETE STOP $stopNum',
                            isLoading: _isUpdatingStatus,
                            icon: Icons.done_all_rounded,
                            onPressed: () => _handleIntermediateStopAction(
                              stopIndex: stopIdx,
                              action: 'completed',
                            ),
                          );
                        } else {
                          return GradientButton(
                            text: 'REACHED STOP $stopNum',
                            isLoading: _isUpdatingStatus,
                            icon: Icons.pin_drop_rounded,
                            onPressed: () => _handleIntermediateStopAction(
                              stopIndex: stopIdx,
                              action: 'reached',
                            ),
                          );
                        }
                      }

                      // All intermediate stops completed (or no stops) & in transit -> Ready for Final Dropoff!
                      if (currentStatus == 'in_transit' ||
                          currentStatus.startsWith('stop_')) {
                        return GradientButton(
                          text: 'REACHED FINAL DESTINATION',
                          isLoading: _isUpdatingStatus,
                          icon: Icons.location_on_rounded,
                          onPressed: () => _updateStatus(
                            'arrived_at_dropoff',
                            'Arrived at final drop-off location! Unloading timer started.',
                          ),
                        );
                      }

                      if (currentStatus == 'arrived_at_dropoff') {
                        return GradientButton(
                          text: 'UNLOAD CARGO & SUBMIT POD',
                          isLoading: _isUpdatingStatus,
                          icon: Icons.task_alt_rounded,
                          onPressed: _showProofOfDeliveryModal,
                        );
                      }

                      if (currentStatus == 'drop_complete') {
                        final double dropIncentive =
                            (_booking?.farDriverIncentive != null &&
                                    (_booking!.farDriverIncentive!) > 0)
                                ? _booking!.farDriverIncentive!
                                : 0.0;
                        final double dropTripFare =
                            ((_booking?.amount?['total_price'] ?? 0) +
                                    (_booking?.waitingCharges ?? 0))
                                .toDouble();
                        final double dropTotal = dropTripFare + dropIncentive;
                        return GradientButton(
                          text: 'Collect Cash Payment (₹${dropTotal.toStringAsFixed(0)})',
                          isLoading: _isUpdatingStatus,
                          icon: Icons.payments_rounded,
                          onPressed: _handleReceivedPaymentClick,
                        );
                      }

                      if (currentStatus == 'amount_paid') {
                        return GradientButton(
                          text: 'Confirm Trip Completed',
                          isLoading: _isUpdatingStatus,
                          icon: Icons.check_circle_rounded,
                          onPressed: () => _updateStatus(
                            'completed',
                            '🎉 Delivery Completed Successfully!',
                          ),
                        );
                      }

                      return GradientButton(
                        text: 'BACK TO HOME',
                        icon: Icons.home_rounded,
                        onPressed: () => context.go('/home'),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.cancel_outlined,
                              color: AppColors.error, size: 18),
                          label: const Text(
                            'Cancel Trip',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _showTripCancellationModal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => context.go('/home'),
                          child: const Text(
                            'Dashboard',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _FareItemRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isHighlight;
  final bool isZero;

  const _FareItemRow({
    required this.label,
    required this.amount,
    this.isHighlight = false,
    this.isZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight
                  ? const Color(0xFFB45309)
                  : AppColors.textSecondary,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Text(
          isZero ? '₹ 0.00' : '₹ ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlight
                ? const Color(0xFFD97706)
                : (isZero ? AppColors.textMuted : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
