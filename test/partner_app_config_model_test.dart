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
      expect(config.isFreeDriverOutstation, false);
      expect(config.updateTitle, 'Update Available');
      expect(config.maintenanceTitle, 'App Under Maintenance');
    });

    test('Parses JSON with exact user requested column names (is_maintanace, regestration_fee, update, is_free_driver_login, is_free_driver_outstation)', () {
      final json = {
        'id': 1,
        'version': '2.4.0',
        'is_maintanace': true,
        'update': true,
        'update_url': 'https://play.google.com/store/apps/details?id=com.ezmoov.partner',
        'regestration_fee': 299.50,
        'is_free_driver_login': true,
        'is_free_driver_outstation': true,
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
      expect(config.isFreeDriverOutstation, true);
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
        'is_free_driver_outstation': false,
      };

      final config = PartnerAppConfigModel.fromJson(json);

      expect(config.id, 2);
      expect(config.version, '3.0.1');
      expect(config.isMaintenance, false);
      expect(config.forceUpdate, false);
      expect(config.registrationFee, 599.00);
      expect(config.isFreeDriverLogin, false);
      expect(config.isFreeDriverOutstation, false);
    });

    test('Parses string/numeric representations safely', () {
      final json = {
        'id': '10',
        'version': '1.2.3',
        'is_maintanace': 'true',
        'update': 'false',
        'regestration_fee': '750',
        'is_free_driver_login': 'true',
        'is_free_driver_outstation': 'true',
      };

      final config = PartnerAppConfigModel.fromJson(json);

      expect(config.id, 10);
      expect(config.version, '1.2.3');
      expect(config.isMaintenance, true);
      expect(config.forceUpdate, false);
      expect(config.registrationFee, 750.00);
      expect(config.isFreeDriverLogin, true);
      expect(config.isFreeDriverOutstation, true);
    });

    test('toJson outputs all expected keys including exact user spellings', () {
      const config = PartnerAppConfigModel(
        id: 1,
        version: '1.5.0',
        isMaintenance: true,
        forceUpdate: true,
        registrationFee: 350.00,
        isFreeDriverLogin: true,
        isFreeDriverOutstation: true,
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
      expect(json['is_free_driver_outstation'], true);
    });

    test('Parses is_free_driver_adda and is_free_driver_local_adda correctly', () {
      final json1 = {
        'id': 1,
        'version': '1.0.0',
        'is_free_driver_adda': true,
      };
      final config1 = PartnerAppConfigModel.fromJson(json1);
      expect(config1.isFreeDriverAdda, true);
      expect(config1.isFreeDriverLocalAdda, true);

      final json2 = {
        'id': 2,
        'version': '1.0.0',
        'is_free_driver_local_adda': true,
      };
      final config2 = PartnerAppConfigModel.fromJson(json2);
      expect(config2.isFreeDriverAdda, true);
      expect(config2.isFreeDriverLocalAdda, true);
    });

    test('copyWith updates specified fields correctly', () {
      final config = PartnerAppConfigModel.defaultConfig();
      final updated = config.copyWith(
        version: '2.0.0',
        isMaintenance: true,
        registrationFee: 0.0,
        isFreeDriverLogin: true,
        isFreeDriverOutstation: true,
      );

      expect(updated.version, '2.0.0');
      expect(updated.isMaintenance, true);
      expect(updated.registrationFee, 0.0);
      expect(updated.isFreeDriverLogin, true);
      expect(updated.isFreeDriverOutstation, true);
      expect(updated.isFreeDriverAdda, true);
      expect(updated.forceUpdate, false);
    });
  });
}
