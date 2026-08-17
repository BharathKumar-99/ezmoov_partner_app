import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../../l10n/generated/app_localizations.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  List<Map<String, dynamic>> _dbNotifications = [];
  String? _loadedDriverId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    final profileVm = context.read<ProfileViewModel>();
    final driverId = profileVm.driver?.id;
    if (driverId != null && driverId.isNotEmpty) {
      _loadedDriverId = driverId;
      if (mounted) setState(() => _isLoading = true);
      final notifs = await SupabaseService.instance.getDriverNotifications(driverId);
      if (mounted) {
        setState(() {
          _dbNotifications = notifs;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProfileViewModel>(
      builder: (context, profileVm, child) {
        final driver = profileVm.driver;

        // Auto-refetch if driver profile loaded after initState
        if (driver?.id != null && driver!.id!.isNotEmpty && driver.id != _loadedDriverId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadNotifications();
          });
        }

        // Auto-generate dynamic account alerts based on real driver state
        final List<Map<String, dynamic>> dynamicAlerts = [];

        if (driver != null) {
          if (driver.isFullyVerified) {
            dynamicAlerts.add({
              'title': l10n.accountFullyVerifiedTitle,
              'message': l10n.accountFullyVerifiedMsg,
              'created_at': driver.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
              'icon': Icons.verified_user_rounded,
              'icon_color': const Color(0xFF166534),
              'badge_color': const Color(0xFFDCFCE7),
            });
          } else {
            dynamicAlerts.add({
              'title': l10n.verificationInProgressTitle,
              'message': l10n.verificationInProgressMsg,
              'created_at': DateTime.now().toIso8601String(),
              'icon': Icons.hourglass_top_rounded,
              'icon_color': const Color(0xFFD97706),
              'badge_color': const Color(0xFFFEF3C7),
            });
          }
        }

        // Combine DB notifications with dynamic account status alerts
        final allNotifs = [..._dbNotifications, ...dynamicAlerts];

        return RefreshIndicator(
          onRefresh: _loadNotifications,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.partnerNotifications,
                    style: const TextStyle(
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
                      l10n.alertsCount(allNotifs.length),
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

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (allNotifs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noNewNotifications,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.caughtUpMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
