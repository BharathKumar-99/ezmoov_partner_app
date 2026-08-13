import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  RazorpayService._internal();
  static final RazorpayService instance = RazorpayService._internal();

  late Razorpay _razorpay;
  bool _isInitialized = false;

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    if (_isInitialized) {
      _razorpay.clear();
    }
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    _isInitialized = true;
  }

  void openCheckout({
    required double amount,
    required String driverId,
    required String driverName,
    required String driverPhone,
    required String driverEmail,
  }) {
    final keyId = dotenv.env['RAZORPAY_KEY_ID'] ?? 'rzp_test_TPGpToo02EEZTT';

    final cleanDigits = driverPhone.replaceAll(RegExp(r'\D'), '');
    final tenDigits = cleanDigits.length >= 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;

    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // amount in paise
      'name': 'EZMoov',
      'description': 'Wallet Recharge ₹${amount.toStringAsFixed(0)}',
      'notes': {
        'type': 'wallet_recharge',
        'driver_id': driverId,
        'amount': amount.toString(),
      },
      'prefill': {
        'contact': tenDigits.isNotEmpty ? tenDigits : '9999999999',
        'email': driverEmail.isNotEmpty ? driverEmail : 'partner@ezmoov.com',
        'name': driverName.isNotEmpty ? driverName : 'EZMoov Partner',
      },
      'external': {
        'wallets': ['paytm', 'gpay', 'phonepe']
      }
    };

    try {
      debugPrint(
          '💳 Opening Razorpay Checkout with Key: $keyId for Amount: ₹$amount');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
    }
  }

  void dispose() {
    if (_isInitialized) {
      _razorpay.clear();
      _isInitialized = false;
    }
  }
}
