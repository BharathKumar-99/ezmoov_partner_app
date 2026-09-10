import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/language_selector_button.dart';
import '../../l10n/generated/app_localizations.dart';

class MaintenanceView extends StatefulWidget {
  const MaintenanceView({super.key});

  @override
  State<MaintenanceView> createState() => _MaintenanceViewState();
}

class _MaintenanceViewState extends State<MaintenanceView> {
  bool _isChecking = false;

  Future<void> _checkMaintenanceStatus() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
      final config = await profileVm.fetchAppConfig();

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      if (!config.isMaintenance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.maintenanceCompleteMsg),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.maintenanceStillOngoingMsg),
            backgroundColor: const Color(0xFFD97706),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false, // Prevents back navigation during active maintenance
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.systemStatus),
          automaticallyImplyLeading: false,
          actions: const [
            Center(
              child: LanguageSelectorButton(isCompact: true),
            ),
            SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Consumer<ProfileViewModel>(
            builder: (context, vm, child) {
              final config = vm.appConfig;
              final title = config.maintenanceTitle.isNotEmpty && config.maintenanceTitle != 'App Under Maintenance'
                  ? config.maintenanceTitle
                  : l10n.appUnderMaintenance;
              final message = config.maintenanceMessage.isNotEmpty && !config.maintenanceMessage.contains('scheduled maintenance')
                  ? config.maintenanceMessage
                  : l10n.maintenanceInProgressDesc;

              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // 1. Animated / Glowing Maintenance Badge
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 6,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.construction_rounded,
                        color: Color(0xFFD97706),
                        size: 54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Status Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD97706),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.scheduledDowntime,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 3. Title & Description
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 4. Partner Data Safety Info Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.whatYouNeedToKnow,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            icon: Icons.shield_rounded,
                            color: const Color(0xFF10B981),
                            title: l10n.walletAndEarningsSafe,
                            subtitle: l10n.walletAndEarningsSafeDesc,
                          ),
                          const Divider(height: 20, color: AppColors.divider),
                          _buildInfoRow(
                            icon: Icons.electric_rickshaw_rounded,
                            color: AppColors.primaryDark,
                            title: l10n.autoServiceResumption,
                            subtitle: l10n.autoServiceResumptionDesc,
                          ),
                          const Divider(height: 20, color: AppColors.divider),
                          _buildInfoRow(
                            icon: Icons.notifications_active_rounded,
                            color: const Color(0xFF0284C7),
                            title: l10n.realtimeReconnection,
                            subtitle: l10n.realtimeReconnectionDesc,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 5. Refresh Status Primary Button
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: l10n.checkServerStatus,
                        isLoading: _isChecking,
                        icon: Icons.refresh_rounded,
                        onPressed: _checkMaintenanceStatus,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 7. Footer App Version
                    Text(
                      'EZMoov Partner v${config.version}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
