import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/partner_app_config_model.dart';
import 'package:ezmoov_partner_app/viewmodels/wallet_viewmodel.dart';

void main() {
  group('isFreeDriverLogin & Daily Fee Logic Tests', () {
    test('PartnerAppConfigModel parses is_free_driver_login properly', () {
      final json = {
        'id': 1,
        'version': '1.0.0',
        'is_maintanace': false,
        'update': false,
        'registration_fee': 500.0,
        'is_free_driver_login': true,
      };

      final config = PartnerAppConfigModel.fromJson(json);
      expect(config.isFreeDriverLogin, isTrue);
    });

    test('WalletViewModel considers pass active and not blocked when isFreeDriverLogin is true', () {
      final walletVm = WalletViewModel();

      // Initially no pass
      expect(walletVm.isPassActive, isFalse);
      expect(walletVm.isBlocked, isTrue);
      expect(walletVm.blockReason, equals('daily_pass_required'));

      // Set free driver login to true
      walletVm.setFreeDriverLogin(true);

      expect(walletVm.isFreeDriverLogin, isTrue);
      expect(walletVm.isPassActive, isTrue);
      expect(walletVm.isBlocked, isFalse);
      expect(walletVm.blockReason, isNull);
    });

    test('Registration fee amount is preserved independently of isFreeDriverLogin flag', () {
      final json = {
        'id': 1,
        'version': '1.0.0',
        'is_maintanace': false,
        'update': false,
        'registration_fee': 499.0,
        'is_free_driver_login': true,
      };

      final config = PartnerAppConfigModel.fromJson(json);
      expect(config.isFreeDriverLogin, isTrue);
      expect(config.registrationFee, equals(499.0));
    });
  });
}
