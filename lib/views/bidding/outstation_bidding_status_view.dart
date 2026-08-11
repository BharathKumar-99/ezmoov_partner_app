import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../viewmodels/ride_request_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/gradient_button.dart';

class OutstationBiddingStatusView extends StatefulWidget {
  final String bookingId;

  const OutstationBiddingStatusView({
    super.key,
    required this.bookingId,
  });

  @override
  State<OutstationBiddingStatusView> createState() => _OutstationBiddingStatusViewState();
}

class _OutstationBiddingStatusViewState extends State<OutstationBiddingStatusView> {
  late TextEditingController _newBidController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final rideVm = context.read<RideRequestViewModel>();
    final currentBid = rideVm.activePendingBid?.driverBid ?? 0.0;
    _newBidController = TextEditingController(
      text: currentBid > 0 ? currentBid.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _newBidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideRequestViewModel>(
      builder: (context, rideVm, child) {
        final profileVm = context.watch<ProfileViewModel>();
        final driverId = profileVm.driver?.id ?? '';

        final booking = rideVm.activePendingBidBooking;
        final pendingBid = rideVm.activePendingBid;

        if (booking == null || pendingBid == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bidding Status'),
              backgroundColor: AppColors.surface,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    'No active pending bid found.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Return to Home'),
                  ),
                ],
              ),
            ),
          );
        }

        final customerDisplayName = (booking.customerName != null &&
                booking.customerName!.isNotEmpty)
            ? booking.customerName!
            : 'Outstation Customer';

        final baseFare = booking.fare > 0
            ? booking.fare
            : BookingModel.extractFare(booking.toJson());

        final estDistanceKm = rideVm.calculateDistance(
          booking.pickupLat,
          booking.pickupLng,
          booking.dropLat,
          booking.dropLng,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.go('/home'),
            ),
            title: const Text(
              'Bidding Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Status Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CUSTOMER IS DECIDING',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Your bid is being reviewed by the customer. You can update your bid below at any time.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Customer & Fare Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              customerDisplayName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${estDistanceKm.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (booking.customerPhone != null && booking.customerPhone!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            booking.customerPhone!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Base Rate',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${baseFare.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Your Active Bid',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${pendingBid.driverBid.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Route Details Card (Pickup & Drop)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, color: AppColors.primary, size: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PICKUP ADDRESS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.pickupAddress.isNotEmpty
                                        ? booking.pickupAddress
                                        : 'Pickup Location',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5, top: 4, bottom: 4),
                          height: 18,
                          width: 2,
                          color: AppColors.divider,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.error, size: 14),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DROP ADDRESS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.dropAddress.isNotEmpty
                                        ? booking.dropAddress
                                        : 'Drop Location',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Update / Re-Bid Input Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SUBMIT A NEW BID AMOUNT (₹)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Submit a lower or competitive price to increase your chances.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _newBidController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            hintText: 'Enter new bid amount',
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a bid amount';
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid positive bid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        GradientButton(
                          text: 'UPDATE BID',
                          isLoading: _isSubmitting,
                          icon: Icons.send_rounded,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            final newBid = double.parse(_newBidController.text.trim());

                            final router = GoRouter.of(context);

                            setState(() {
                              _isSubmitting = true;
                            });

                            final success = await rideVm.submitBid(
                              bookingId: booking.id,
                              driverId: driverId,
                              currentRate: baseFare,
                              driverBid: newBid,
                              context: context,
                            );

                            if (!mounted) return;
                            setState(() {
                              _isSubmitting = false;
                            });

                            if (success) {
                              router.go('/home');
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Withdraw / Cancel Bid Action
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 18),
                      label: const Text(
                        'Withdraw / Cancel Bid',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        rideVm.withdrawBid();
                        context.go('/home');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
