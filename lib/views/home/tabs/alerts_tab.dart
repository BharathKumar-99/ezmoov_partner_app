import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Partner Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '4 New Alerts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const _AlertCard(
            title: '⚡ High Demand Surge Alert!',
            message: 'Surge pricing active in Electronic City & Silk Board. Earn up to ₹50 extra per trip.',
            time: '10 mins ago',
            icon: Icons.bolt_rounded,
            iconColor: Color(0xFFEAB308),
            badgeColor: Color(0xFFFEF9C3),
          ),

          const _AlertCard(
            title: '🎁 Weekend Incentive Bonus',
            message: 'Complete 12 trips between Friday & Sunday to unlock an instant ₹600 cash bonus.',
            time: '2 hours ago',
            icon: Icons.card_giftcard_rounded,
            iconColor: AppColors.primary,
            badgeColor: Color(0xFFDCFCE7),
          ),

          const _AlertCard(
            title: '💳 Payout Successfully Processed',
            message: 'Your weekly payout of ₹4,850.00 has been transferred to your registered bank account.',
            time: '1 day ago',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: Color(0xFF0284C7),
            badgeColor: Color(0xFFE0F2FE),
          ),

          const _AlertCard(
            title: '📄 Vehicle Fitness Reminder',
            message: 'Your Vehicle Fitness Certificate is verified and valid up to Dec 31, 2026.',
            time: '2 days ago',
            icon: Icons.verified_user_rounded,
            iconColor: Color(0xFF166534),
            badgeColor: Color(0xFFDCFCE7),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color badgeColor;

  const _AlertCard({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
