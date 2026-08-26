import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../models/booking_model.dart';
import '../../../viewmodels/ride_request_viewmodel.dart';
import '../../../widgets/gradient_button.dart';
import '../../../widgets/route_location_tile.dart';

void showIncomingRideDialog(
    BuildContext context, BookingModel booking, String driverId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      return IncomingRideDialog(booking: booking, driverId: driverId);
    },
  ).then((_) {
    if (context.mounted) {
      Provider.of<RideRequestViewModel>(context, listen: false).onModalClosed();
    }
  });
}

class IncomingRideDialog extends StatelessWidget {
  final BookingModel booking;
  final String driverId;

  const IncomingRideDialog({
    super.key,
    required this.booking,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RideRequestViewModel>(
      builder: (context, vm, child) {
        final activeBooking = vm.activeBroadcastBooking ?? booking;
        final customerDisplayName = (activeBooking.customerName != null &&
                activeBooking.customerName!.isNotEmpty)
            ? activeBooking.customerName!
            : 'Customer Delivery Request';

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Radar Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Flexible(
                          child: Text(
                            'INCOMING RIDE REQUEST',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Within 3 km',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Total Fare & Customer Info Display
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
                        if (activeBooking.customerPhone != null &&
                            activeBooking.customerPhone!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 13, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                activeBooking.customerPhone!,
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
                            'Standard Delivery Order',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) {
                      final displayFare = activeBooking.fare > 0
                          ? activeBooking.fare
                          : BookingModel.extractFare(activeBooking.toJson());
                      return Text(
                        displayFare > 0
                            ? '₹ ${displayFare.toStringAsFixed(2)}'
                            : '₹ 0.00',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Scrollable Content Section (Stops Badge + Full Route Timeline)
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Multi-Stops Badge Indicator
                      if (activeBooking.hasStops) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.alt_route_rounded,
                                  size: 18, color: Color(0xFFD97706)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${activeBooking.stopsCount} Intermediate Stop${activeBooking.stopsCount > 1 ? 's' : ''} (+₹${activeBooking.stopsCharge > 0 ? activeBooking.stopsCharge.toStringAsFixed(0) : (activeBooking.stopsCount * 25)})',
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

                      // Route Container (Pickup, Intermediate Stops, Drop with Distance Pills)
                      Builder(
                        builder: (context) {
                          final driverPos = LocationService.instance.currentPosition;
                          final driverLat = driverPos?.latitude ?? 0.0;
                          final driverLng = driverPos?.longitude ?? 0.0;

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

                          final dropDistKm = (driverLat != 0.0 &&
                                  driverLng != 0.0 &&
                                  activeBooking.dropLat != 0.0 &&
                                  activeBooking.dropLng != 0.0)
                              ? vm.calculateDistance(
                                  driverLat,
                                  driverLng,
                                  activeBooking.dropLat,
                                  activeBooking.dropLng)
                              : vm.calculateDistance(
                                  activeBooking.pickupLat,
                                  activeBooking.pickupLng,
                                  activeBooking.dropLat,
                                  activeBooking.dropLng);

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
                                    final idx = entry.key + 1;
                                    final stop = entry.value;

                                    final stopDistKm = (driverLat != 0.0 &&
                                            driverLng != 0.0 &&
                                            stop.latitude != 0.0 &&
                                            stop.longitude != 0.0)
                                        ? vm.calculateDistance(
                                            driverLat,
                                            driverLng,
                                            stop.latitude,
                                            stop.longitude)
                                        : (activeBooking.pickupLat != 0.0 &&
                                                activeBooking.pickupLng != 0.0 &&
                                                stop.latitude != 0.0 &&
                                                stop.longitude != 0.0)
                                            ? vm.calculateDistance(
                                                activeBooking.pickupLat,
                                                activeBooking.pickupLng,
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

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons: Decline & Accept (pinned at bottom!)
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
                      onPressed: () {
                        vm.declineRide(booking.id, driverId: driverId);
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
                      text: 'ACCEPT RIDE',
                      isLoading: vm.isAccepting,
                      icon: Icons.check_circle_rounded,
                      onPressed: () {
                        vm.acceptRide(
                          bookingId: booking.id,
                          driverId: driverId,
                          context: context,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
