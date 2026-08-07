import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../viewmodels/profile_viewmodel.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVm, child) {
        final List<Map<String, dynamic>> rawNotifications = [];
        final driver = profileVm.driver;

        // Auto-generate dynamic account alerts based on real driver state
        final List<Map<String, dynamic>> dynamicAlerts = [];

        if (driver != null) {
          if (driver.isFullyVerified) {
            dynamicAlerts.add({
              'title': '✅ Account Fully Verified',
              'message': 'Your driver profile, vehicle documents, and bank details are active.',
              'created_at': driver.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
              'icon': Icons.verified_user_rounded,
              'icon_color': const Color(0xFF166534),
              'badge_color': const Color(0xFFDCFCE7),
            });
          } else {
            dynamicAlerts.add({
              'title': '⏳ Verification In Progress',
              'message': 'Your driver documentation is under admin review.',
              'created_at': DateTime.now().toIso8601String(),
              'icon': Icons.hourglass_top_rounded,
              'icon_color': const Color(0xFFD97706),
              'badge_color': const Color(0xFFFEF3C7),
            });
          }
        }

        // Combine DB notifications with dynamic account status alerts
        final allNotifs = [...rawNotifications, ...dynamicAlerts];

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
                    child: Text(
                      '${allNotifs.length} ${allNotifs.length == 1 ? 'Alert' : 'Alerts'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (allNotifs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No New Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'You are all caught up! High demand alerts and account updates will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...allNotifs.map((item) {
                  final title = item['title'] as String? ?? 'Notification';
                  final message = item['message'] as String? ?? item['body'] as String? ?? '';
                  final dateRaw = item['created_at'] as String?;
                  String timeStr = 'Recently';
                  if (dateRaw != null) {
                    try {
                      final dt = DateTime.parse(dateRaw);
                      timeStr = DateFormat('dd MMM, hh:mm a').format(dt);
                    } catch (_) {}
                  }

                  final icon = item['icon'] as IconData? ?? Icons.notifications_active_rounded;
                  final iconColor = item['icon_color'] as Color? ?? AppColors.primary;
                  final badgeColor = item['badge_color'] as Color? ?? const Color(0xFFDCFCE7);

                  return _AlertCard(
                    title: title,
                    message: message,
                    time: timeStr,
                    icon: icon,
                    iconColor: iconColor,
                    badgeColor: badgeColor,
                  );
                }),
            ],
          ),
        );
      },
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
