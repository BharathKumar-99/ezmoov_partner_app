import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../../viewmodels/locale_viewmodel.dart';
import '../../../l10n/generated/app_localizations.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _showLanguageSelectionModal(BuildContext context, LocaleViewModel localeVM) {
    final l10n = AppLocalizations.of(context)!;
    final currentCode = localeVM.locale.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.translate_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    l10n.selectLanguage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 8),

              // English Option
              _LanguageOptionTile(
                title: 'English',
                subtitle: 'English',
                code: 'en',
                isSelected: currentCode == 'en',
                onTap: () {
                  localeVM.changeLocale('en');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),

              // Hindi Option
              _LanguageOptionTile(
                title: 'हिन्दी',
                subtitle: 'Hindi',
                code: 'hi',
                isSelected: currentCode == 'hi',
                onTap: () {
                  localeVM.changeLocale('hi');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),

              // Telugu Option
              _LanguageOptionTile(
                title: 'తెలుగు',
                subtitle: 'Telugu',
                code: 'te',
                isSelected: currentCode == 'te',
                onTap: () {
                  localeVM.changeLocale('te');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeVM = Provider.of<LocaleViewModel>(context);

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
                    GestureDetector(
                      onTap: () => context.push('/edit-profile'),
                      child: Stack(
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
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 12),
                            ),
                          ),
                        ],
                      ),
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
                    IconButton(
                      tooltip: 'Edit Profile',
                      onPressed: () => context.push('/edit-profile'),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.vehicleAndEquipment,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.directions_car_rounded,
                iconColor: AppColors.primary,
                title: l10n.vehicleRegistration,
                subtitle: vehicle != null
                    ? '${vehicle.vehicleNumber} (RC: ${vehicle.rcNumber})'
                    : l10n.vehicleDetailsVerified,
              ),

              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.verified_user_rounded,
                iconColor: const Color(0xFF0284C7),
                title: l10n.driverCertificates,
                subtitle: l10n.certificatesSubtitle,
              ),

              const SizedBox(height: 24),

              Text(
                l10n.payoutsAndBanking,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFF09A234),
                title: 'Driver Wallet & Daily Fee',
                subtitle: 'Manage wallet balance, pay daily vehicle fee & view payouts',
                onTap: () {
                  context.push('/wallet?driverId=${driver?.id ?? ''}');
                },
              ),

              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.card_giftcard_rounded,
                iconColor: const Color(0xFFE11D48),
                title: 'Refer & Earn ₹25 Bonus',
                subtitle: 'Invite partner drivers & get ₹25 for every referral',
                onTap: () {
                  context.push('/referral?driverId=${driver?.id ?? ''}');
                },
              ),

              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFFD97706),
                title: bank?.bankName ?? l10n.bankAccount,
                subtitle: bank != null
                    ? 'A/C: **** ${bank.accountNumber.length > 4 ? bank.accountNumber.substring(bank.accountNumber.length - 4) : bank.accountNumber} | IFSC: ${bank.ifscCode}'
                    : l10n.bankDetailsVerified,
              ),

              const SizedBox(height: 24),

              Text(
                l10n.supportAndPreferences,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.translate_rounded,
                iconColor: AppColors.primary,
                title: l10n.appLanguage,
                subtitle: localeVM.currentLanguageName,
                onTap: () => _showLanguageSelectionModal(context, localeVM),
              ),
              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.headset_mic_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: l10n.helpAndSupportDesk,
                subtitle: l10n.supportDeskSubtitle,
                onTap: () {
                  context.push('/support');
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
                  label: Text(
                    l10n.logOutOfAccount,
                    style: const TextStyle(
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

class _LanguageOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($subtitle)',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
              else
                const Icon(Icons.circle_outlined, color: AppColors.textMuted, size: 22),
            ],
          ),
        ),
      ),
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
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
