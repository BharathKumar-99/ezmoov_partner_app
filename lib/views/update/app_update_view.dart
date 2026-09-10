import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/language_selector_button.dart';
import '../../l10n/generated/app_localizations.dart';

class AppUpdateView extends StatelessWidget {
  final bool isForced;

  const AppUpdateView({
    super.key,
    this.isForced = true,
  });

  Future<void> _openStoreUrl(BuildContext context, String url) async {
    final targetUrl = url.isNotEmpty
        ? url
        : 'https://play.google.com/store/apps/details?id=com.ezmoov.partner';

    try {
      final uri = Uri.parse(targetUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open store link. Please search for EZMoov Partner in Google Play.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching update URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProfileViewModel>(
      builder: (context, vm, child) {
        final config = vm.appConfig;
        final isMandatory = config.forceUpdate || isForced;
        final title = config.updateTitle.isNotEmpty && config.updateTitle != 'Update Available'
            ? config.updateTitle
            : l10n.updateAvailable;
        final message = config.updateMessage.isNotEmpty && !config.updateMessage.contains('new version of EZMoov')
            ? config.updateMessage
            : l10n.updateAvailableDesc;
        final latestVersion = config.version.isNotEmpty ? config.version : '1.0.0';

        return PopScope(
          canPop: !isMandatory, // Prevent closing if forced update
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(l10n.appUpdate),
              automaticallyImplyLeading: !isMandatory,
              actions: const [
                Center(
                  child: LanguageSelectorButton(isCompact: true),
                ),
                SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // 1. Glowing Rocket / Update Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 6,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: AppColors.primaryDark,
                        size: 52,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isMandatory ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isMandatory ? const Color(0xFFF87171) : AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMandatory ? Icons.priority_high_rounded : Icons.auto_awesome_rounded,
                            size: 14,
                            color: isMandatory ? const Color(0xFFDC2626) : AppColors.primaryDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isMandatory ? l10n.mandatoryUpdate : l10n.newVersionAvailable,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isMandatory ? const Color(0xFFB91C1C) : AppColors.primaryDark,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. Version Comparison Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.currentVersionLabel('0.0.3'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                          ),
                          Text(
                            l10n.latestVersionLabel(latestVersion),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 4. Title & Description
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

                    // 5. "What's New" Highlights Card
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
                            l10n.whatsNewInThisVersion,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildFeatureRow(
                            icon: Icons.electric_bolt_rounded,
                            color: const Color(0xFFF59E0B),
                            title: l10n.fasterOrderMatching,
                            subtitle: l10n.fasterOrderMatchingDesc,
                          ),
                          const Divider(height: 20, color: AppColors.divider),
                          _buildFeatureRow(
                            icon: Icons.battery_charging_full_rounded,
                            color: const Color(0xFF10B981),
                            title: l10n.batteryGpsOptimization,
                            subtitle: l10n.batteryGpsOptimizationDesc,
                          ),
                          const Divider(height: 20, color: AppColors.divider),
                          _buildFeatureRow(
                            icon: Icons.account_balance_wallet_rounded,
                            color: const Color(0xFF0284C7),
                            title: l10n.realtimeEarningUpdates,
                            subtitle: l10n.realtimeEarningUpdatesDesc,
                          ),
                          const Divider(height: 20, color: AppColors.divider),
                          _buildFeatureRow(
                            icon: Icons.verified_user_rounded,
                            color: AppColors.primaryDark,
                            title: l10n.performanceStabilityPatches,
                            subtitle: l10n.performanceStabilityPatchesDesc,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 6. Primary "UPDATE NOW" Button
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: l10n.updateNow,
                        icon: Icons.system_update_alt_rounded,
                        onPressed: () => _openStoreUrl(context, config.updateUrl),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 7. Secondary / Skip Action
                    if (!isMandatory)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                          child: Text(
                            l10n.remindMeLater,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        l10n.mandatoryUpdateNotice,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow({
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
