import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/booking_model.dart';
import '../../../viewmodels/ride_request_viewmodel.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../../widgets/gradient_button.dart';
import '../../../widgets/route_location_tile.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Consumer<RideRequestViewModel>(
      builder: (context, vm, child) {
        final activeBooking = vm.activeBroadcastBooking ?? widget.booking;
        final customerDisplayName = (activeBooking.customerName != null &&
                activeBooking.customerName!.isNotEmpty)
            ? activeBooking.customerName!
            : l10n.outstationCustomer;

        final baseFare = activeBooking.fare > 0
            ? activeBooking.fare
            : BookingModel.extractFare(activeBooking.toJson());

        final estDistanceKm = vm.calculateDistance(
          activeBooking.pickupLat,
          activeBooking.pickupLng,
          activeBooking.dropLat,
          activeBooking.dropLng,
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
                          Flexible(
                            child: Text(
                              l10n.outstationBiddingRideCaps,
                              style: const TextStyle(
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
                            Text(
                              l10n.outstationBooking,
                              style: const TextStyle(
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
                        Text(
                          l10n.baseRate,
                          style: const TextStyle(
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

                // Multi-Stops Badge Indicator
                if (activeBooking.hasStops) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alt_route_rounded, size: 18, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.intermediateStopsBadge(
                              activeBooking.stopsCharge > 0
                                  ? activeBooking.stopsCharge.toStringAsFixed(0)
                                  : (activeBooking.stopsCount * 25).toString(),
                              activeBooking.stopsCount,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 3. Route Container (Pickup, Intermediate Stops, Drop with Distance Pills)
                Builder(
                  builder: (context) {
                    final driverPos = LocationService.instance.currentPosition;
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
                            activeBooking.pickupLat != 0.0 &&
                            activeBooking.pickupLng != 0.0)
                        ? vm.calculateDistance(
                            driverLat,
                            driverLng,
                            activeBooking.pickupLat,
                            activeBooking.pickupLng)
                        : 0.0;

                    double calculatedTotalTripDist = 0.0;
                    if (activeBooking.pickupLat != 0.0 &&
                        activeBooking.pickupLng != 0.0) {
                      if (activeBooking.hasStops &&
                          activeBooking.effectiveIntermediateStops.isNotEmpty) {
                        double currentLat = activeBooking.pickupLat;
                        double currentLng = activeBooking.pickupLng;
                        for (final stop in activeBooking.effectiveIntermediateStops) {
                          if (stop.latitude != 0.0 && stop.longitude != 0.0) {
                            calculatedTotalTripDist += vm.calculateDistance(
                                currentLat, currentLng, stop.latitude, stop.longitude);
                            currentLat = stop.latitude;
                            currentLng = stop.longitude;
                          }
                        }
                        if (activeBooking.dropLat != 0.0 && activeBooking.dropLng != 0.0) {
                          calculatedTotalTripDist += vm.calculateDistance(
                              currentLat, currentLng, activeBooking.dropLat, activeBooking.dropLng);
                        }
                      } else if (activeBooking.dropLat != 0.0 && activeBooking.dropLng != 0.0) {
                        calculatedTotalTripDist = vm.calculateDistance(
                            activeBooking.pickupLat,
                            activeBooking.pickupLng,
                            activeBooking.dropLat,
                            activeBooking.dropLng);
                      }
                    }
                    final dropDistKm = calculatedTotalTripDist;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pickup Location Tile with Distance Pill
                          RouteLocationTile(
                            type: LocationTileType.pickup,
                            address: activeBooking.pickupAddress,
                            distanceKm: pickupDistKm,
                          ),

                          const DashedLineConnector(height: 20, color: Color(0xFF10B981)),

                          // Intermediate Stops Loop
                          if (activeBooking.hasStops)
                            ...activeBooking.effectiveIntermediateStops
                                .asMap()
                                .entries
                                .map((entry) {
                              final i = entry.key;
                              final idx = i + 1;
                              final stop = entry.value;

                              final double prevLat = (i == 0)
                                  ? activeBooking.pickupLat
                                  : activeBooking.effectiveIntermediateStops[i - 1].latitude;
                              final double prevLng = (i == 0)
                                  ? activeBooking.pickupLng
                                  : activeBooking.effectiveIntermediateStops[i - 1].longitude;

                              final stopDistKm = (prevLat != 0.0 &&
                                      prevLng != 0.0 &&
                                      stop.latitude != 0.0 &&
                                      stop.longitude != 0.0)
                                  ? vm.calculateDistance(
                                      prevLat,
                                      prevLng,
                                      stop.latitude,
                                      stop.longitude)
                                  : 0.0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RouteLocationTile(
                                    type: LocationTileType.stop,
                                    address: stop.address,
                                    distanceKm: stopDistKm,
                                    stopIndex: idx,
                                  ),
                                  const DashedLineConnector(
                                      height: 20, color: Color(0xFFF59E0B)),
                                ],
                              );
                            }),

                          // Drop Location Tile with Distance Pill
                          RouteLocationTile(
                            type: LocationTileType.drop,
                            address: activeBooking.dropAddress,
                            distanceKm: dropDistKm,
                          ),
                        ],
                      ),
                    );
                  },
                ),


                const SizedBox(height: 18),

                // 4. Driver Bid Number Input Field
                Text(
                  l10n.enterYourBidAmountCaps,
                  style: const TextStyle(
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
                    hintText: l10n.bidAmountHint,
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
                      return l10n.pleaseEnterBidAmount;
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return l10n.enterValidPositiveBid;
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
                        child: Text(
                          l10n.decline,
                          style: const TextStyle(
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
                        text: l10n.submitBidCaps,
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
