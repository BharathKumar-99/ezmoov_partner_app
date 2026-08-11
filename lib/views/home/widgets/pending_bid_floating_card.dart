import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';
import '../../../models/bid_model.dart';

class PendingBidFloatingCard extends StatelessWidget {
  final BookingModel booking;
  final BidModel bid;
  final VoidCallback onTap;

  const PendingBidFloatingCard({
    super.key,
    required this.booking,
    required this.bid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const statusBgColor = Color(0xFFF59E0B); // Amber / Gold color for pending bid

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
              color: statusBgColor.withValues(alpha: 0.8),
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
              // Gavel / Hourglass Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusBgColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusBgColor, width: 1.5),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  color: statusBgColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Bidding Status & Details
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
                          decoration: const BoxDecoration(
                            color: statusBgColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'BID PENDING • ₹ ${bid.driverBid.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusBgColor,
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Customer deciding... Tap to update bid',
                      style: TextStyle(
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

              // View Bid Button
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
                      'VIEW BID',
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
