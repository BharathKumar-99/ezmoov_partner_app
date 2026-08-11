import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../viewmodels/ride_request_viewmodel.dart';
import '../../../widgets/gradient_button.dart';

void showBiddingOutstationDialog(
    BuildContext context, BookingModel booking, String driverId) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom,
        ),
        child: BiddingOutstationDialog(booking: booking, driverId: driverId),
      );
    },
  ).then((_) {
    if (context.mounted) {
      Provider.of<RideRequestViewModel>(context, listen: false).onModalClosed();
    }
  });
}

class BiddingOutstationDialog extends StatefulWidget {
  final BookingModel booking;
  final String driverId;

  const BiddingOutstationDialog({
    super.key,
    required this.booking,
    required this.driverId,
  });

  @override
  State<BiddingOutstationDialog> createState() =>
      _BiddingOutstationDialogState();
}

class _BiddingOutstationDialogState extends State<BiddingOutstationDialog> {
  late TextEditingController _bidController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final baseFare = widget.booking.fare > 0
        ? widget.booking.fare
        : BookingModel.extractFare(widget.booking.toJson());
    _bidController = TextEditingController(
      text: baseFare > 0 ? baseFare.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideRequestViewModel>(
      builder: (context, vm, child) {
        final customerDisplayName = (widget.booking.customerName != null &&
                widget.booking.customerName!.isNotEmpty)
            ? widget.booking.customerName!
            : 'Outstation Customer';

        final baseFare = widget.booking.fare > 0
            ? widget.booking.fare
            : BookingModel.extractFare(widget.booking.toJson());

        final estDistanceKm = vm.calculateDistance(
          widget.booking.pickupLat,
          widget.booking.pickupLng,
          widget.booking.dropLat,
          widget.booking.dropLng,
        );

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header & Outstation Bidding Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.gavel_rounded,
                              color: Color(0xFFD97706),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Flexible(
                            child: Text(
                              'OUTSTATION BIDDING RIDE',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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

                const SizedBox(height: 16),

                // 2. Customer Info & Base Rate Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerDisplayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          if (widget.booking.customerPhone != null &&
                              widget.booking.customerPhone!.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 13, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  widget.booking.customerPhone!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'Outstation Booking',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Base Rate',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          baseFare > 0
                              ? '₹ ${baseFare.toStringAsFixed(2)}'
                              : '₹ 0.00',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. Route Container (Pickup & Drop)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle,
                              color: AppColors.primary, size: 12),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PICKUP LOCATION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.booking.pickupAddress.isNotEmpty
                                      ? widget.booking.pickupAddress
                                      : 'Pickup Location',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 5, top: 4, bottom: 4),
                        height: 16,
                        width: 2,
                        color: AppColors.divider,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.error, size: 14),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DROP LOCATION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.booking.dropAddress.isNotEmpty
                                      ? widget.booking.dropAddress
                                      : 'Drop Location',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 4. Driver Bid Number Input Field
                const Text(
                  'ENTER YOUR BID AMOUNT (₹)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bidController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                    hintText: 'e.g. 1500',
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
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

                const SizedBox(height: 24),

                // 5. Action Buttons: Decline & Submit Bid
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                              color: AppColors.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                vm.declineRide(widget.booking.id);
                                Navigator.of(context).pop();
                              },
                        child: const Text(
                          'Decline',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        text: 'SUBMIT BID',
                        isLoading: _isSubmitting,
                        icon: Icons.send_rounded,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final bidAmount =
                              double.parse(_bidController.text.trim());

                          final navigator = Navigator.of(context);

                          setState(() {
                            _isSubmitting = true;
                          });

                          final success = await vm.submitBid(
                            bookingId: widget.booking.id,
                            driverId: widget.driverId,
                            currentRate: baseFare,
                            driverBid: bidAmount,
                            context: context,
                          );

                          if (!mounted) return;
                          setState(() {
                            _isSubmitting = false;
                          });
                          if (success) {
                            navigator.pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
