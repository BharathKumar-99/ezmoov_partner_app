import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint('Error launching call: $e');
    }
  }

  void _showSupportDetailModal(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Map<String, String>> faqs,
    String? hotline,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
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
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),
              ...faqs.map((faq) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                faq['q'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          faq['a'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _makeCall(hotline ?? '+9118001234567');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                  label: Text(
                    l10n.speakToAgent,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grey soft background matching reference design
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              const SizedBox(height: 20),

              // Header Banner with Title & Illustration
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.howCanWeHelpYou,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.getInTouchHelp,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Illustration Container matching screenshot artwork
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Chat Bubble Graphic
                      Container(
                        width: 110,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE), // Light blue background
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF93C5FD),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF93C5FD),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Character Avatar
                      Positioned(
                        right: 4,
                        bottom: 0,
                        child: SizedBox(
                          width: 80,
                          height: 95,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D4ED8), // Royal blue uniform
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E40AF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.pin_drop, color: Colors.white, size: 10),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.thumb_up_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Option 1: Update my account details
              _SupportOptionTile(
                icon: Icons.person_rounded,
                title: l10n.updateAccountDetails,
                subtitle: l10n.updateAccountSubtitle,
                onTap: () {
                  _showSupportDetailModal(
                    context,
                    title: l10n.updateAccountDetails,
                    subtitle: l10n.updateAccountSubtitle,
                    icon: Icons.person_rounded,
                    faqs: [
                      {
                        'q': 'How can I change my registered phone number?',
                        'a': 'To update your phone number, please contact support with a copy of your Driving License and government ID verification.'
                      },
                      {
                        'q': 'How do I update vehicle or bank information?',
                        'a': 'You can re-submit updated RC or Bank passbook documents via the Profile tab or submit a ticket here.'
                      },
                    ],
                  );
                },
              ),

              const SizedBox(height: 14),

              // Option 2: Know more about the pricing
              _SupportOptionTile(
                icon: Icons.payments_rounded,
                title: l10n.knowMorePricing,
                subtitle: l10n.pricingSubtitle,
                onTap: () {
                  _showSupportDetailModal(
                    context,
                    title: l10n.knowMorePricing,
                    subtitle: l10n.pricingSubtitle,
                    icon: Icons.payments_rounded,
                    faqs: [
                      {
                        'q': 'How are trip fares calculated?',
                        'a': 'Fares are calculated based on base fare, total distance travelled, ride duration, vehicle type, and active peak surge multipliers.'
                      },
                      {
                        'q': 'What if customer cancels the trip?',
                        'a': 'A standard cancellation fee is automatically credited to your EZMoov wallet if the customer cancels after driver assignment.'
                      },
                    ],
                  );
                },
              ),

              const SizedBox(height: 14),

              // Option 3: Learn more about my wallet
              _SupportOptionTile(
                icon: Icons.account_balance_wallet_rounded,
                title: l10n.learnMoreWallet,
                subtitle: l10n.walletSubtitle,
                onTap: () {
                  _showSupportDetailModal(
                    context,
                    title: l10n.learnMoreWallet,
                    subtitle: l10n.walletSubtitle,
                    icon: Icons.account_balance_wallet_rounded,
                    faqs: [
                      {
                        'q': 'When are weekly payouts deposited?',
                        'a': 'Earnings are automatically processed and transferred directly to your linked bank account every Tuesday morning.'
                      },
                      {
                        'q': 'How does instant withdrawal work?',
                        'a': 'Instant withdrawal transfers your available wallet balance directly to your bank account via UPI/IMPS within minutes.'
                      },
                    ],
                  );
                },
              ),

              const SizedBox(height: 14),

              // Option 4: Learn about EZMoov services
              _SupportOptionTile(
                icon: Icons.local_shipping_rounded,
                title: l10n.learnEzmoovServices,
                subtitle: l10n.servicesSubtitle,
                onTap: () {
                  _showSupportDetailModal(
                    context,
                    title: l10n.learnEzmoovServices,
                    subtitle: l10n.servicesSubtitle,
                    icon: Icons.local_shipping_rounded,
                    faqs: [
                      {
                        'q': 'What goods transport services are supported?',
                        'a': 'EZMoov connects partners offering 2-wheeler, 3-wheeler, Tata Ace, Pickup, and Heavy vehicle logistics services across cities.'
                      },
                      {
                        'q': 'What are partner quality standards?',
                        'a': 'Partners are expected to maintain clean vehicles, follow safety rules, provide accurate loading updates, and arrive promptly.'
                      },
                    ],
                  );
                },
              ),

              const SizedBox(height: 14),

              // Option 5: Understand safety procedures
              _SupportOptionTile(
                icon: Icons.shield_rounded,
                title: l10n.understandSafety,
                subtitle: l10n.safetySubtitle,
                onTap: () {
                  _showSupportDetailModal(
                    context,
                    title: l10n.understandSafety,
                    subtitle: l10n.safetySubtitle,
                    icon: Icons.shield_rounded,
                    faqs: [
                      {
                        'q': 'Is my trip covered under insurance?',
                        'a': 'Yes, all active trips on EZMoov include partner accident insurance cover. Ensure you hit "Start Trip" on the app.'
                      },
                      {
                        'q': 'What should I do in an emergency?',
                        'a': 'Tap the Emergency SOS button in the trip screen to alert local authorities and our emergency response team immediately.'
                      },
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // Bottom Hotline Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _makeCall('+9118001234567'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 22),
                  label: Text(
                    l10n.callSupportHotline,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9), // Subtle light circle for icon
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1E293B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
