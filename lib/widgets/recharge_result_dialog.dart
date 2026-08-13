import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class RechargeResultDialog extends StatefulWidget {
  final bool isSuccess;
  final double amount;
  final String? errorMessage;
  final VoidCallback onDismiss;

  const RechargeResultDialog({
    super.key,
    required this.isSuccess,
    this.amount = 0.0,
    this.errorMessage,
    required this.onDismiss,
  });

  static void show({
    required BuildContext context,
    required bool isSuccess,
    double amount = 0.0,
    String? errorMessage,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RechargeResultDialog(
        isSuccess: isSuccess,
        amount: amount,
        errorMessage: errorMessage,
        onDismiss: () {
          Navigator.pop(ctx);
          if (onDismiss != null) onDismiss();
        },
      ),
    );
  }

  @override
  State<RechargeResultDialog> createState() => _RechargeResultDialogState();
}

class _RechargeResultDialogState extends State<RechargeResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.isSuccess;
    final primaryColor = isSuccess ? const Color(0xFF09A234) : const Color(0xFFEF4444);
    final bgLightColor = isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon Badge
            ScaleTransition(
              scale: _scaleAnim,
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnim.value,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: bgLightColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSuccess ? Icons.check_rounded : Icons.close_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              isSuccess ? 'Payment Successful! 🎉' : 'Payment Failed ❌',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            // Amount pill if success
            if (isSuccess && widget.amount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Text(
                  '+₹${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Message Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSuccess ? const Color(0xFFF9FAFB) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSuccess ? const Color(0xFFE5E7EB) : const Color(0xFFFCA5A5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isSuccess ? Icons.access_time_filled_rounded : Icons.info_outline_rounded,
                    size: 20,
                    color: isSuccess ? const Color(0xFF09A234) : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isSuccess
                          ? 'Your payment was processed successfully! Please note: It may take up to 30 minutes for the updated balance to reflect in your wallet depending on bank/UPI confirmation.'
                          : (widget.errorMessage != null &&
                                  widget.errorMessage != 'undefined' &&
                                  widget.errorMessage!.trim().isNotEmpty)
                              ? widget.errorMessage!
                              : 'Payment Failed',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isSuccess ? AppColors.textSecondary : const Color(0xFF991B1B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: widget.onDismiss,
                child: Text(
                  isSuccess ? 'Got it!' : 'OK',
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
      ),
    );
  }
}
