import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/razorpay_service.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/recharge_result_dialog.dart';

class WalletView extends StatefulWidget {
  final String? driverId;

  const WalletView({super.key, this.driverId});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  double _pendingRechargeAmount = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profileVm = context.read<ProfileViewModel>();
      final effectiveDriverId = widget.driverId ?? profileVm.driver?.id ?? '';
      if (effectiveDriverId.isNotEmpty && mounted) {
        context.read<WalletViewModel>().fetchWalletData(effectiveDriverId);
      }
    });

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
        '💳 Razorpay Payment Success! Payment ID: ${response.paymentId}. Wallet balance update will be processed asynchronously via Edge Function Webhook.');
    if (!mounted) return;
    final profileVm = context.read<ProfileViewModel>();
    final walletVm = context.read<WalletViewModel>();
    final driverId = widget.driverId ?? profileVm.driver?.id ?? '';

    final rechargedAmt = _pendingRechargeAmount;
    _pendingRechargeAmount = 0.0;

    // Refresh wallet UI and schedule a short delayed refresh for when Edge Function webhook completes
    if (driverId.isNotEmpty && mounted) {
      walletVm.fetchWalletData(driverId, showLoading: false);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          walletVm.fetchWalletData(driverId, showLoading: false);
        }
      });
    }

    if (mounted) {
      RechargeResultDialog.show(
        context: context,
        isSuccess: true,
        amount: rechargedAmt > 0 ? rechargedAmt : 0.0,
      );
    }
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    debugPrint(
        '💳 Razorpay Payment Failed: ${response.code} - ${response.message}');
    if (!mounted) return;
    final msg = (response.message == null ||
            response.message == 'undefined' ||
            response.message!.trim().isEmpty)
        ? "Payment Failed"
        : response.message;

    if (mounted) {
      RechargeResultDialog.show(
        context: context,
        isSuccess: false,
        errorMessage: msg,
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External Wallet Selected: ${response.walletName}');
  }

  void _payDailyFeeWithoutWallet(BuildContext context, String driverId) {
    final walletVm = context.read<WalletViewModel>();
    final profile = context.read<ProfileViewModel>().driver;
    final dailyFee = walletVm.vehicleDailyFee;

    _pendingRechargeAmount = dailyFee;

    RazorpayService.instance.openCheckout(
      amount: dailyFee,
      driverId: driverId,
      driverName: profile?.name ?? 'EZMoov Partner',
      driverPhone: profile?.phone ?? '',
      driverEmail: profile?.email ?? '',
      paymentType: 'direct_daily_fee',
    );
  }

  void _showAddMoneyBottomSheet(BuildContext context, String driverId) {
    final walletVm = context.read<WalletViewModel>();
    final amountController = TextEditingController(text: '200');
    double selectedAmount = 200.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    const Text(
                      'Add Money to Wallet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recharge your wallet to pay daily vehicle fees and stay active for orders.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Select Amount Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [100.0, 200.0, 500.0, 1000.0].map((amt) {
                        final isSelected = selectedAmount == amt;
                        return ChoiceChip(
                          label: Text('+₹${amt.toInt()}'),
                          selected: isSelected,
                          selectedColor: const Color(0xFF09A234),
                          backgroundColor: AppColors.background,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF09A234)
                                  : AppColors.border,
                            ),
                          ),
                          onSelected: (_) {
                            setStateModal(() {
                              selectedAmount = amt;
                              amountController.text = amt.toInt().toString();
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Amount Text Field
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF09A234),
                            ),
                          ),
                        ),
                        labelText: 'Enter Custom Amount',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFF09A234), width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null) {
                          setStateModal(() {
                            selectedAmount = parsed;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF09A234),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: walletVm.isRecharging
                            ? null
                            : () {
                                final amt =
                                    double.tryParse(amountController.text) ??
                                        selectedAmount;
                                if (amt <= 0) return;

                                _pendingRechargeAmount = amt;
                                final profile =
                                    context.read<ProfileViewModel>().driver;

                                Navigator.of(modalContext).pop();

                                RazorpayService.instance.openCheckout(
                                  amount: amt,
                                  driverId: driverId,
                                  driverName: profile?.name ?? 'EZMoov Partner',
                                  driverPhone: profile?.phone ?? '',
                                  driverEmail: profile?.email ?? '',
                                );
                              },
                        child: walletVm.isRecharging
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'RECHARGE ₹${selectedAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF09A234),
                          side: const BorderSide(
                              color: Color(0xFF09A234), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(modalContext).pop();
                          _payDailyFeeWithoutWallet(context, driverId);
                        },
                        icon: const Icon(Icons.flash_on_rounded, size: 20),
                        label: Text(
                          'Recharge without Wallet (₹${walletVm.vehicleDailyFee.toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWithdrawBottomSheet(
      BuildContext context, String driverId, double walletBalance) {
    final amountController = TextEditingController(
      text: walletBalance > 0 ? walletBalance.toStringAsFixed(0) : '',
    );
    String? amountError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final walletVm = context.watch<WalletViewModel>();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF09A234)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.north_east_rounded,
                                color: Color(0xFF09A234),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Withdraw Funds 💸',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalCtx),
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Transfer your available earnings balance directly to your linked bank account / UPI.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Available Balance Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF09A234).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF09A234).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Available Balance:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '₹${walletBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF09A234),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1-2 Days Timeline Banner Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              color: Colors.blue, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Payout Timeline: Funds will be credited to your bank account / UPI within 1 - 2 business days.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [100, 500, 1000, 2000].map((amt) {
                          final isAvailable = walletBalance >= amt;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('₹$amt'),
                              selected: amountController.text == '$amt',
                              onSelected: isAvailable
                                  ? (selected) {
                                      setModalState(() {
                                        amountController.text = '$amt';
                                        amountError = null;
                                      });
                                    }
                                  : null,
                              selectedColor: const Color(0xFF09A234),
                              disabledColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: amountController.text == '$amt'
                                    ? Colors.white
                                    : (isAvailable
                                        ? AppColors.textPrimary
                                        : Colors.grey),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TextField Amount
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Withdrawal Amount (₹)',
                        hintText: 'Enter amount (e.g. 500)',
                        errorText: amountError,
                        prefixIcon: const Icon(Icons.currency_rupee_rounded,
                            color: Color(0xFF09A234)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF09A234), width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          amountError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: walletVm.isWithdrawing
                            ? null
                            : () async {
                                final inputVal = double.tryParse(
                                        amountController.text.trim()) ??
                                    0;
                                if (inputVal <= 0) {
                                  setModalState(() {
                                    amountError =
                                        'Please enter a valid amount greater than ₹0';
                                  });
                                  return;
                                }
                                if (inputVal > walletBalance) {
                                  setModalState(() {
                                    amountError =
                                        'Amount exceeds available wallet balance (₹${walletBalance.toStringAsFixed(0)})';
                                  });
                                  return;
                                }

                                final success = await walletVm.withdrawWallet(
                                  driverId: driverId,
                                  amount: inputVal,
                                  context: context,
                                );

                                if (success && modalCtx.mounted) {
                                  Navigator.pop(modalCtx);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF09A234),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: walletVm.isWithdrawing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.north_east_rounded, size: 20),
                        label: Text(
                          walletVm.isWithdrawing
                              ? 'Processing Withdrawal...'
                              : 'CONFIRM WITHDRAWAL',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    final effectiveDriverId = profileVm.driver?.id;

    return Consumer<WalletViewModel>(
      builder: (context, walletVm, child) {
        final walletBalance = walletVm.wallet?.balance ?? 0.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. GREEN TOP HEADER + AVAILABLE BALANCE MAIN CARD
                Container(
                  color: const Color(0xFF09A234),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Title
                      const Text(
                        'Wallet',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Main Balance Container Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Available Wallet Balance',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '₹${walletBalance.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (effectiveDriverId != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF09A234),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: () {
                                        _showAddMoneyBottomSheet(
                                            context, effectiveDriverId);
                                      },
                                      icon: const Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 18,
                                          color: Color(0xFF09A234)),
                                      label: const Text(
                                        'Add Money',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF09A234),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.2),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: Colors.white70, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: () {
                                        _showWithdrawBottomSheet(context,
                                            effectiveDriverId, walletBalance);
                                      },
                                      icon: const Icon(Icons.north_east_rounded,
                                          size: 18, color: Colors.white),
                                      label: const Text(
                                        'Withdraw',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.15),
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Colors.white, width: 1),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () {
                                    _payDailyFeeWithoutWallet(
                                        context, effectiveDriverId);
                                  },
                                  icon: const Icon(Icons.flash_on_rounded,
                                      size: 18, color: Colors.white),
                                  label: Text(
                                    'Recharge without Wallet (Pay ₹${walletVm.vehicleDailyFee.toStringAsFixed(0)} Direct)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Sub-row: Pending Settlement & Next Settlement
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pending Settlement',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '+₹${walletVm.pendingSettlement.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Next Settlement',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      walletVm.nextSettlementDate,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. STATS GRID (2x2 CARDS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Last Settlement',
                              value:
                                  '₹${walletVm.lastSettlementAmount.toStringAsFixed(0)}',
                              subtext: walletVm.lastSettlementDate,
                              subtextColor: const Color(0xFF09A234),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Total Settled',
                              value:
                                  '₹${walletVm.totalSettled.toStringAsFixed(0)}',
                              subtext: 'Since Joining',
                              subtextColor: const Color(0xFF09A234),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Total Earnings',
                              value:
                                  '₹${walletVm.totalEarningsAllTime.toStringAsFixed(0)}',
                              valueColor: const Color(0xFFEA580C),
                              subtext: 'All time',
                              subtextColor: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Total Deductions',
                              value:
                                  '₹${walletVm.totalDeductionsAllTime.toStringAsFixed(0)}',
                              valueColor: const Color(0xFFEF4444),
                              subtext: 'Commission',
                              subtextColor: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Refer & Earn Banner Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48).withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.card_giftcard_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Refer & Earn ₹25',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Invite drivers & get ₹25 cash in your wallet!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.push('/referral?driverId=${effectiveDriverId ?? ''}');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFE11D48),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Invite',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. DAILY FEE & REJECTIONS TRACKER BANNER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: walletVm.isBlocked
                            ? Colors.red.withValues(alpha: 0.5)
                            : AppColors.border,
                        width: walletVm.isBlocked ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Vehicle Daily Fee & 24-Hour Pass Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: walletVm.isPassActive
                                        ? const Color(0xFF09A234)
                                            .withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    walletVm.isPassActive
                                        ? Icons.verified_user_rounded
                                        : Icons.timer_off_rounded,
                                    color: walletVm.isPassActive
                                        ? const Color(0xFF09A234)
                                        : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Daily Pass',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      walletVm.isPassActive
                                          ? 'Active (Expires ${walletVm.passExpiresAt != null ? DateFormat('MMM dd, hh:mm a').format(walletVm.passExpiresAt!) : ''})'
                                          : 'Pass Expired / Unpaid (₹${walletVm.vehicleDailyFee.toStringAsFixed(0)} / 24 hrs)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: walletVm.isPassActive
                                            ? const Color(0xFF09A234)
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: walletVm.isPassActive
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                walletVm.isPassActive
                                    ? 'Pass Active'
                                    : 'Unpaid',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: walletVm.isPassActive
                                      ? const Color(0xFF09A234)
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Pay Daily Fee Action Buttons if Pass is Expired/Unpaid
                        if (!walletVm.isPassActive &&
                            effectiveDriverId != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: walletVm.isPayingFee
                                      ? null
                                      : () {
                                          walletVm.payDailyFee(
                                            driverId: effectiveDriverId,
                                            context: context,
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF09A234),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: walletVm.isPayingFee
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.account_balance_wallet_rounded,
                                          size: 16),
                                  label: Text(
                                    walletVm.isPayingFee
                                        ? 'Paying...'
                                        : 'Pay via Wallet',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _payDailyFeeWithoutWallet(
                                        context, effectiveDriverId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber.shade800,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.flash_on_rounded,
                                      size: 16),
                                  label: const Text(
                                    'Recharge Without Wallet',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),

                        // Row 2: Rejections Count Progress (Limit 2 Rejections)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: walletVm.rejectionsToday >= 2
                                        ? Colors.red.withValues(alpha: 0.1)
                                        : Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    walletVm.rejectionsToday >= 2
                                        ? Icons.block_rounded
                                        : Icons.warning_amber_rounded,
                                    color: walletVm.rejectionsToday >= 2
                                        ? Colors.red
                                        : Colors.amber[800],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Today\'s Order Rejections',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${walletVm.rejectionsToday} of 2 max allowed rejections today',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: walletVm.rejectionsToday >= 2
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                walletVm.rejectionsToday >= 2
                                    ? 'Blocked Today'
                                    : 'Active',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: walletVm.rejectionsToday >= 2
                                      ? Colors.red
                                      : const Color(0xFF09A234),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4B. WITHDRAWAL REQUESTS & PAYOUT PROGRESS
                if (walletVm.payouts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RECENT WITHDRAWALS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...walletVm.payouts
                            .take(3)
                            .map((payout) => _buildPayoutProgressCard(payout)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. TRANSACTIONS SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TRANSACTIONS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF09A234),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Transactions List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: walletVm.transactions.isEmpty
                      ? _buildSampleTransactionsList()
                      : Column(
                          children: walletVm.transactions.map((tx) {
                            String cleanTitle = tx.description;
                            cleanTitle = cleanTitle
                                .replaceAll(
                                    RegExp(r'\(Booking #[0-9a-fA-F\-]+\)'), '')
                                .replaceAll(
                                    RegExp(r'\(Driver #[0-9a-fA-F\-]+\)'), '')
                                .replaceAll(
                                    RegExp(
                                        r'\([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\)'),
                                    '')
                                .replaceAll(
                                    RegExp(
                                        r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'),
                                    '')
                                .trim();

                            if (tx.type == 'daily_fee' ||
                                tx.type == 'daily_deduction' ||
                                cleanTitle
                                    .toLowerCase()
                                    .contains('daily fee') ||
                                cleanTitle
                                    .toLowerCase()
                                    .contains('daily vehicle platform fee')) {
                              cleanTitle = 'Daily Pay';
                            } else if (cleanTitle.isEmpty) {
                              cleanTitle = tx.isCredit
                                  ? 'Trip Earning Credit'
                                  : 'Daily Pay';
                            }

                            return _TransactionTile(
                              title: cleanTitle,
                              subtitle:
                                  '${tx.paymentMethod} • ${DateFormat('MMM dd').format(tx.createdAt)}',
                              amount:
                                  '${tx.isCredit ? '+' : ''}₹${tx.amount.abs().toStringAsFixed(0)}',
                              isCredit: tx.isCredit,
                            );
                          }).toList(),
                        ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPayoutProgressCard(Map<String, dynamic> payout) {
    final amount = (payout['amount'] as num?)?.toDouble() ?? 0.0;
    final status = (payout['status'] as String? ?? 'created').toLowerCase();
    final method = payout['payout_method'] as String? ?? 'Bank Transfer';
    final createdAtStr = payout['created_at'] as String?;
    final dateFormatted = createdAtStr != null
        ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(createdAtStr))
        : 'Recently';

    int stepIndex = 0;
    Color statusColor = Colors.amber.shade800;
    String statusLabel = 'Created';

    if (status == 'accepted') {
      stepIndex = 1;
      statusColor = Colors.blue.shade700;
      statusLabel = 'Accepted';
    } else if (status == 'processing') {
      stepIndex = 2;
      statusColor = Colors.orange.shade700;
      statusLabel = 'Processing';
    } else if (status == 'completed' || status == 'processed') {
      stepIndex = 3;
      statusColor = const Color(0xFF09A234);
      statusLabel = 'Completed';
    } else if (status == 'failed') {
      stepIndex = -1;
      statusColor = Colors.red.shade700;
      statusLabel = 'Failed & Refunded';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      status == 'completed'
                          ? Icons.check_circle_rounded
                          : (status == 'failed'
                              ? Icons.error_rounded
                              : Icons.hourglass_top_rounded),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${amount.toStringAsFixed(0)} Withdrawal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$method • $dateFormatted',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (status != 'failed') ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStepNode('Created', 0, stepIndex),
                _buildStepConnector(0, stepIndex),
                _buildStepNode('Accepted', 1, stepIndex),
                _buildStepConnector(1, stepIndex),
                _buildStepNode('Processing', 2, stepIndex),
                _buildStepConnector(2, stepIndex),
                _buildStepNode('Complete', 3, stepIndex),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepNode(String label, int index, int currentIndex) {
    final isDone = currentIndex >= index;
    final isCurrent = currentIndex == index;
    final color = isDone
        ? const Color(0xFF09A234)
        : AppColors.textMuted.withValues(alpha: 0.3);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isDone ? color : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? const Color(0xFF09A234) : color,
                width: 2,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isDone ? AppColors.textPrimary : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int fromIndex, int currentIndex) {
    final isDone = currentIndex > fromIndex;
    return Container(
      height: 2,
      width: 16,
      color: isDone ? const Color(0xFF09A234) : AppColors.border,
    );
  }

  /// Empty state placeholder when DB has no transaction history yet
  Widget _buildSampleTransactionsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 36,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Your wallet recharges and daily fee deductions will appear here.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final String subtext;
  final Color subtextColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.valueColor,
    required this.subtext,
    required this.subtextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;

  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconData =
        isCredit ? Icons.south_west_rounded : Icons.north_east_rounded;
    final effectiveIconBgColor =
        isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final effectiveIconColor =
        isCredit ? const Color(0xFF09A234) : const Color(0xFFEF4444);
    final effectiveAmountColor =
        isCredit ? const Color(0xFF09A234) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: effectiveIconBgColor,
            child: Icon(effectiveIconData, color: effectiveIconColor, size: 18),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: effectiveAmountColor,
            ),
          ),
        ],
      ),
    );
  }
}
