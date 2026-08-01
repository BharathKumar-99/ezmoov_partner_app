import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../viewmodels/profile_viewmodel.dart';


class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, child) {
        final driver = vm.driver;
        final vehicle = vm.vehicle;
        final bank = vm.bankDetails;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: (driver?.profilePicUrl != null && driver!.profilePicUrl!.isNotEmpty)
                          ? NetworkImage(driver.profilePicUrl!)
                          : null,
                      child: (driver?.profilePicUrl == null || driver!.profilePicUrl!.isEmpty)
                          ? const Icon(Icons.person, color: AppColors.primary, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                driver?.name ?? 'EZMoov Partner',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: AppColors.primary, size: 18),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            driver?.phone ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            driver?.email ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Vehicle & Equipment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.directions_car_rounded,
                iconColor: AppColors.primary,
                title: 'Vehicle Registration',
                subtitle: vehicle != null
                    ? '${vehicle.vehicleNumber} (RC: ${vehicle.rcNumber})'
                    : 'Vehicle Details Verified',
              ),

              const SizedBox(height: 12),

              const _ProfileTile(
                icon: Icons.verified_user_rounded,
                iconColor: Color(0xFF0284C7),
                title: 'Driver Certificates',
                subtitle: 'PUC, Permit, Fitness, Police Clearance (Verified)',
              ),

              const SizedBox(height: 24),

              const Text(
                'Payouts & Banking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFFD97706),
                title: bank?.bankName ?? 'Bank Account',
                subtitle: bank != null
                    ? 'A/C: **** ${bank.accountNumber.length > 4 ? bank.accountNumber.substring(bank.accountNumber.length - 4) : bank.accountNumber} | IFSC: ${bank.ifscCode}'
                    : 'Bank Details Verified',
              ),

              const SizedBox(height: 24),

              const Text(
                'Support & Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              const _ProfileTile(
                icon: Icons.translate_rounded,
                iconColor: AppColors.primary,
                title: 'App Language',
                subtitle: 'English / हिन्दी',
              ),
              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.headset_mic_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Partner Support Desk',
                subtitle: '24/7 Priority Driver Support Hotline • Tap to Call',
                onTap: () async {
                  final Uri url = Uri.parse('tel:+9118001234567');
                  try {
                    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                    if (!launched) {
                      await launchUrl(url);
                    }
                  } catch (e) {
                    debugPrint('Notice launching phone call: $e');
                  }
                },
              ),

              const SizedBox(height: 28),


              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => vm.clearProfileAndLogout(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  label: const Text(
                    'Log Out of Account',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
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
                      ),
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
