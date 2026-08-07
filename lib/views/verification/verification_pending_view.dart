import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../models/driver_model.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/gradient_button.dart';

class VerificationPendingView extends StatefulWidget {
  final String driverId;

  const VerificationPendingView({
    super.key,
    required this.driverId,
  });

  @override
  State<VerificationPendingView> createState() => _VerificationPendingViewState();
}

class _VerificationPendingViewState extends State<VerificationPendingView> {
  bool _isChecking = false;
  DriverModel? _driver;

  @override
  void initState() {
    super.initState();
    _loadDriverStatus();
  }

  Future<void> _loadDriverStatus() async {
    try {
      final driver = await SupabaseService.instance.getDriverById(widget.driverId);
      if (mounted) {
        setState(() {
          _driver = driver;
        });
      }
    } catch (e) {
      debugPrint('Error loading driver status: $e');
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final driver = await SupabaseService.instance.getDriverById(widget.driverId);
      setState(() {
        _driver = driver;
        _isChecking = false;
      });

      if (!mounted) return;

      if (driver != null && driver.isFullyVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Verification Approved! Welcome to EZMoov Fleet.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.go('/home', extra: {'driverId': widget.driverId});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification still pending admin review. Please check back shortly.'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = _driver;
    final isVehicleVerified = driver?.isVehicleVerified ?? false;
    final isDocsVerified = driver?.isDocumentsVerified ?? false;
    final isBankVerified = driver?.isBankDetailsVerified ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Verification'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () => Provider.of<ProfileViewModel>(context, listen: false).clearProfileAndLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Color(0xFFD97706),
                  size: 52,
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Verification Under Review',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your vehicle and document submissions have been received. Access to the driver home dashboard will be unlocked once approved by our verification team.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

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
                child: Column(
                  children: [
                    const _CheckStep(
                      title: 'Mobile Phone & Identity',
                      subtitle: 'Phone OTP Verified',
                      isDone: true,
                    ),
                    const Divider(color: AppColors.divider, height: 24),
                    _CheckStep(
                      title: 'Vehicle Registration & RC',
                      subtitle: isVehicleVerified ? 'Vehicle Verified by Admin' : 'RC Photo Submitted - Reviewing',
                      isDone: isVehicleVerified,
                      isPending: !isVehicleVerified,
                    ),
                    const Divider(color: AppColors.divider, height: 24),
                    _CheckStep(
                      title: 'Driver Certificates',
                      subtitle: isDocsVerified ? 'Certificates Verified by Admin' : 'PUC, Permit, Fitness, PCC Submitted - Reviewing',
                      isDone: isDocsVerified,
                      isPending: !isDocsVerified,
                    ),
                    const Divider(color: AppColors.divider, height: 24),
                    _CheckStep(
                      title: 'Bank Account Payouts',
                      subtitle: isBankVerified ? 'Bank Account Verified' : 'Bank Details Submitted - Reviewing',
                      isDone: isBankVerified,
                      isPending: !isBankVerified,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              GradientButton(
                text: 'Check Verification Status',
                isLoading: _isChecking,
                icon: Icons.refresh_rounded,
                onPressed: _checkVerificationStatus,
              ),

              const SizedBox(height: 16),

              TextButton.icon(
                onPressed: () => Provider.of<ProfileViewModel>(context, listen: false).clearProfileAndLogout(context),
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
                label: const Text(
                  'Log Out & Exit',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isPending;

  const _CheckStep({
    required this.title,
    required this.subtitle,
    required this.isDone,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? const Color(0xFFDCFCE7)
                : isPending
                    ? const Color(0xFFFEF3C7)
                    : AppColors.background,
          ),
          child: Icon(
            isDone
                ? Icons.check_circle_rounded
                : isPending
                    ? Icons.hourglass_top_rounded
                    : Icons.circle_outlined,
            color: isDone
                ? AppColors.primary
                : isPending
                    ? const Color(0xFFD97706)
                    : AppColors.textMuted,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isPending ? const Color(0xFFD97706) : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDone ? AppColors.primaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
