import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/partner_app_config_model.dart';

void main() {
  group('PartnerAppConfigModel Tests', () {
    test('Default config has expected initial values', () {
      final config = PartnerAppConfigModel.defaultConfig();
      expect(config.id, 1);
      expect(config.version, '1.0.0');
      expect(config.isMaintenance, false);
      expect(config.isMaintanace, false);
      expect(config.forceUpdate, false);
      expect(config.update, false);
      expect(config.registrationFee, 499.00);
      expect(config.regestrationFee, 499.00);
      expect(config.isFreeDriverLogin, false);
      expect(config.updateTitle, 'Update Available');
      expect(config.maintenanceTitle, 'App Under Maintenance');
    });

    test('Parses JSON with exact user requested column names (is_maintanace, regestration_fee, update, is_free_driver_login)', () {
      final json = {
        'id': 1,
        'version': '2.4.0',
        'is_maintanace': true,
        'update': true,
        'update_url': 'https://play.google.com/store/apps/details?id=com.ezmoov.partner',
        'regestration_fee': 299.50,
        'is_free_driver_login': true,
        'maintenance_message': 'Server upgrade in progress',
      };

      final config = PartnerAppConfigModel.fromJson(json);

      expect(config.id, 1);
      expect(config.version, '2.4.0');
      expect(config.isMaintenance, true);
      expect(config.isMaintanace, true);
      expect(config.forceUpdate, true);
      expect(config.update, true);
      expect(config.registrationFee, 299.50);
      expect(config.regestrationFee, 299.50);
      expect(config.isFreeDriverLogin, true);
      expect(config.maintenanceMessage, 'Server upgrade in progress');
    });

    test('Parses JSON with alternate standard column names (is_maintenance, registration_fee, force_update)', () {
      final json = {
        'id': 2,
        'version': '3.0.1',
        'is_maintenance': false,
        'force_update': false,
        'registration_fee': 599.00,
        'is_free_driver_login': false,
      };

      final config = PartnerAppConfigModel.fromJson(json);

      expect(config.id, 2);
      expect(config.version, '3.0.1');
      expect(config.isMaintenance, false);
      expect(config.forceUpdate, false);
      expect(config.registrationFee, 599.00);
      expect(config.isFreeDriverLogin, false);
    });

    test('Parses string/numeric representations safely', () {
      final json = {
        'id': '10',
        'version': '1.2.3',
        'is_maintanace': 'true',
        'update': 'false',
        'regestration_fee': '750',
        'is_free_driver_login': 'true',
      };

      final config = PartnerAppConfigModel.fromJson(json);

      expect(config.id, 10);
      expect(config.version, '1.2.3');
      expect(config.isMaintenance, true);
      expect(config.forceUpdate, false);
      expect(config.registrationFee, 750.00);
      expect(config.isFreeDriverLogin, true);
    });

    test('toJson outputs all expected keys including exact user spellings', () {
      const config = PartnerAppConfigModel(
        id: 1,
        version: '1.5.0',
        isMaintenance: true,
        forceUpdate: true,
        registrationFee: 350.00,
        isFreeDriverLogin: true,
      );

      final json = config.toJson();

      expect(json['id'], 1);
      expect(json['version'], '1.5.0');
      expect(json['is_maintanace'], true);
      expect(json['is_maintenance'], true);
      expect(json['update'], true);
      expect(json['force_update'], true);
      expect(json['regestration_fee'], 350.00);
      expect(json['registration_fee'], 350.00);
      expect(json['is_free_driver_login'], true);
    });

    test('copyWith updates specified fields correctly', () {
      final config = PartnerAppConfigModel.defaultConfig();
      final updated = config.copyWith(
        version: '2.0.0',
        isMaintenance: true,
        registrationFee: 0.0,
        isFreeDriverLogin: true,
      );

      expect(updated.version, '2.0.0');
      expect(updated.isMaintenance, true);
      expect(updated.registrationFee, 0.0);
      expect(updated.isFreeDriverLogin, true);
      expect(updated.forceUpdate, false);
    });
  });
}
