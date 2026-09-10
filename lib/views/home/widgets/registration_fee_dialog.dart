import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/razorpay_service.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../../widgets/gradient_button.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Shows an unclosable modal dialog requiring the driver to pay the one-time registration fee.
Future<void> showRegistrationFeeDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (dialogCtx) {
      return const RegistrationFeeDialog();
    },
  );
}

class RegistrationFeeDialog extends StatefulWidget {
  const RegistrationFeeDialog({super.key});

  @override
  State<RegistrationFeeDialog> createState() => _RegistrationFeeDialogState();
}

class _RegistrationFeeDialogState extends State<RegistrationFeeDialog> {
  @override
  void initState() {
    super.initState();
    RazorpayService.instance.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    RazorpayService.instance.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint(
        '💳 Razorpay Registration Fee Payment Success! Payment ID: ${response.paymentId}');
    if (!mounted) return;
    final vm = context.read<ProfileViewModel>();
    final success = await vm.payRegistrationFee(context);
    if (success && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    debugPrint(
        '💳 Razorpay Registration Fee Payment Failed: ${response.code} - ${response.message}');
    if (!mounted) return;
    final msg = (response.message == null ||
            response.message == 'undefined' ||
            response.message!.trim().isEmpty)
        ? "Payment Failed"
        : response.message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: $msg'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External Wallet Selected: ${response.walletName}');
  }

  void _initiatePayment(ProfileViewModel vm, double feeAmount) async {
    final driver = vm.driver;
    if (driver == null || driver.id == null) return;

    if (feeAmount <= 0) {
      final success = await vm.payRegistrationFee(context);
      if (success && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      return;
    }

    RazorpayService.instance.openCheckout(
      amount: feeAmount,
      driverId: driver.id!,
      driverName: driver.name.isNotEmpty ? driver.name : 'EZMoov Partner',
      driverPhone: driver.phone,
      driverEmail: driver.email,
      paymentType: 'registration_fee',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false, // Prevents Android back button or gestures from closing
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        elevation: 16,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Consumer<ProfileViewModel>(
          builder: (context, vm, child) {
            final isPaying = vm.isPayingRegistrationFee;
            final feeAmount = vm.appConfig.registrationFee;
            final buttonText = feeAmount > 0
                ? l10n.payRegistrationFeeAmount(feeAmount.toStringAsFixed(0))
                : l10n.payRegistrationFee;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Icon Header
                  Container(
                    width: 72,
                    height: 72,
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
                              const Color(0xFFF59E0B).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_clock_rounded,
                      color: Color(0xFFD97706),
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2. Title & Badge
                  Text(
                    l10n.registrationFeeRequired,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      l10n.partnerAccountPending,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. Explanation text
                  Text(
                    l10n.registrationFeeExplanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Partner Benefits Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildBenefitRow(
                          icon: Icons.verified_user_rounded,
                          color: const Color(0xFF10B981),
                          text: l10n.verifiedPartnerBadge,
                        ),
                        const SizedBox(height: 10),
                        _buildBenefitRow(
                          icon: Icons.electric_rickshaw_rounded,
                          color: AppColors.primaryDark,
                          text: l10n.instantRideDeliveryAllocation,
                        ),
                        const SizedBox(height: 10),
                        _buildBenefitRow(
                          icon: Icons.payments_rounded,
                          color: const Color(0xFF0284C7),
                          text: l10n.fullDailyEarningsPayouts,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Pay Registration Fee Action Button
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: buttonText,
                      isLoading: isPaying,
                      icon: Icons.credit_card_rounded,
                      onPressed: isPaying
                          ? null
                          : () => _initiatePayment(vm, feeAmount),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 6. Secondary Refresh / Status Check Button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isPaying
                              ? null
                              : () async {
                                  await vm.refreshRegistrationStatus(context);
                                  if (vm.driver?.registrationFeePaid == true &&
                                      context.mounted) {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.sync_rounded,
                              size: 16, color: AppColors.textSecondary),
                          label: Text(
                            l10n.refreshStatus,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: isPaying
                              ? null
                              : () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  vm.clearProfileAndLogout(context);
                                },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.logout_rounded,
                              size: 16, color: AppColors.error),
                          label: Text(
                            l10n.logout,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
