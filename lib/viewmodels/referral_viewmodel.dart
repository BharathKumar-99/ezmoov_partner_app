import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/supabase_service.dart';
import '../models/driver_model.dart';
import '../models/referral_model.dart';

class ReferralViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  DriverModel? _driver;
  DriverModel? get driver => _driver;

  String _referralCode = '';
  String get referralCode => _referralCode;

  List<ReferralModel> _referrals = [];
  List<ReferralModel> get referrals => _referrals;

  double get totalEarned => _referrals
      .where((r) => r.isRewarded)
      .fold<double>(0.0, (sum, r) => sum + r.rewardAmount);

  int get totalInvited => _referrals.length;
  int get activeReferrals => _referrals.where((r) => r.isRewarded).length;

  /// Fetch driver referral code and list of invited partners
  Future<void> fetchReferralData(String driverId, {DriverModel? currentDriver}) async {
    if (driverId.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _driver = currentDriver ?? await _supabaseService.getDriverById(driverId);
      if (_driver != null) {
        _referralCode = await _supabaseService.ensureDriverReferralCode(_driver!);
      }

      final rawReferrals = await _supabaseService.getDriverReferrals(driverId);
      _referrals = rawReferrals.map((r) => ReferralModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('Error fetching referral data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Apply/Redeem a referral code for the current driver
  Future<bool> redeemReferralCode({
    required String driverId,
    required String code,
    required BuildContext context,
  }) async {
    if (driverId.isEmpty || code.trim().isEmpty || _isSubmitting) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final res = await _supabaseService.applyReferralCode(
        driverId: driverId,
        referralCode: code,
      );

      _isSubmitting = false;
      notifyListeners();

      final success = res['success'] as bool? ?? false;
      final msg = res['message'] as String? ?? '';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: success ? const Color(0xFF09A234) : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      if (success) {
        await fetchReferralData(driverId);
      }

      return success;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Copy referral code to clipboard
  void copyReferralCode(BuildContext context) {
    if (_referralCode.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _referralCode));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📋 Referral Code "$_referralCode" copied to clipboard!'),
          backgroundColor: const Color(0xFF09A234),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Share referral message via WhatsApp or OS Intent
  Future<void> shareViaWhatsApp() async {
    if (_referralCode.isEmpty) return;

    final shareText = Uri.encodeComponent(
      'Join EZMoov as a Partner Driver and start earning daily! 🚚\n\n'
      'Use my Referral Code: *$_referralCode* during signup to get instant bonus perks.\n\n'
      'Download & Register now!',
    );

    final whatsappUri = Uri.parse('whatsapp://send?text=$shareText');
    final webUri = Uri.parse('https://wa.me/?text=$shareText');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Notice launching WhatsApp share: $e');
    }
  }
}
