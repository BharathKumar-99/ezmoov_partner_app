import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';

class ActiveTripFloatingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const ActiveTripFloatingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final isTransit = status == 'in_transit';
    final isArrived = status == 'arrived';

    final statusText = isTransit
        ? 'IN TRANSIT TO DROPOFF'
        : (isArrived ? 'ARRIVED AT PICKUP' : 'HEADING TO PICKUP');

    final targetAddress = isTransit
        ? (booking.dropAddress.isNotEmpty
              ? booking.dropAddress
              : 'Dropoff Location')
        : (booking.pickupAddress.isNotEmpty
              ? booking.pickupAddress
              : 'Pickup Location');

    final statusBgColor = isTransit
        ? const Color(0xFF0284C7)
        : (isArrived ? const Color(0xFFD97706) : AppColors.primary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark slate floating card
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: statusBgColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Pulse/Navigation Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusBgColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusBgColor, width: 1.5),
                ),
                child: Icon(
                  isTransit
                      ? Icons.local_shipping_rounded
                      : (isArrived
                            ? Icons.location_city_rounded
                            : Icons.navigation_rounded),
                  color: statusBgColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Booking status & destination snippet
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusBgColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      targetAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Return to Navigation Pill Button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'RESUME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
