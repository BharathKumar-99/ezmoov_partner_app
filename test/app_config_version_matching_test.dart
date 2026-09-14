import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ezmoov_partner_app/core/constants/app_constants.dart';
import 'package:ezmoov_partner_app/models/partner_app_config_model.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Config Version Matching & Non-Persistent Storage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      PackageInfo.setMockInitialValues(
        appName: 'EZMoov Partner',
        packageName: 'com.ezmoov.partner',
        version: '1.0.3',
        buildNumber: '13',
        buildSignature: '',
      );
    });

    test('AppConstants initializes dynamically from package_info_plus', () async {
      await AppConstants.initialize();
      expect(AppConstants.appVersion, equals('1.0.3'));
      expect(AppConstants.buildNumber, equals(13));
      expect(AppConstants.packageName, equals('com.ezmoov.partner'));
    });

    test('saveToLocalCache does NOT store cached_app_config_json into SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final vm = ProfileViewModel();

      vm.setAppConfig(const PartnerAppConfigModel(
        version: '1.0.2',
        registrationFee: 299.0,
        isFreeDriverLogin: true,
      ));

      await vm.saveToLocalCache();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('cached_app_config_json'), isFalse);
      expect(prefs.getString('cached_app_config_json'), isNull);
    });

    test('restoreFromLocalCache does NOT load cached_app_config_json from SharedPreferences', () async {
      // Simulate leftover stale data in SharedPreferences
      SharedPreferences.setMockInitialValues({
        'cached_app_config_json': '{"version":"0.9.0","registration_fee":999.0,"is_free_driver_login":false}',
      });

      final vm = ProfileViewModel();
      vm.setAppConfig(const PartnerAppConfigModel(
        version: '1.0.2',
        registrationFee: 499.0,
      ));

      await vm.restoreFromLocalCache();

      // App config must NOT be overwritten by the SharedPreferences value
      expect(vm.appConfig.version, equals('1.0.2'));
      expect(vm.appConfig.registrationFee, equals(499.0));
    });

    test('PartnerAppConfigModel correctly parses version matching fields', () {
      final json = {
        'id': 2,
        'version': '1.0.2',
        'is_maintenance': false,
        'force_update': false,
        'registration_fee': 499.00,
        'is_free_driver_login': true,
        'update_url': 'https://play.google.com/store/apps/details?id=com.ezmoov.partner',
      };

      final config = PartnerAppConfigModel.fromJson(json);

      expect(config.id, equals(2));
      expect(config.version, equals('1.0.2'));
      expect(config.isMaintenance, isFalse);
      expect(config.forceUpdate, isFalse);
      expect(config.registrationFee, equals(499.00));
      expect(config.isFreeDriverLogin, isTrue);
    });

    test('fetchAppConfig executes and notifies listeners', () async {
      final vm = ProfileViewModel();
      bool listenerNotified = false;
      vm.addListener(() {
        listenerNotified = true;
      });

      final result = await vm.fetchAppConfig(null, '1.0.2');
      expect(result, isNotNull);
      expect(listenerNotified, isTrue);
    });

    test('saveToLocalCache does NOT store user details into SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final vm = ProfileViewModel();

      await vm.saveToLocalCache();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('cached_driver_json'), isFalse);
      expect(prefs.containsKey('cached_vehicle_json'), isFalse);
      expect(prefs.containsKey('cached_documents_json'), isFalse);
      expect(prefs.containsKey('cached_bank_details_json'), isFalse);
      expect(prefs.containsKey('cached_app_config_json'), isFalse);
    });

    test('restoreFromLocalCache does NOT load user details from SharedPreferences', () async {
      // Simulate leftover stale data in SharedPreferences
      SharedPreferences.setMockInitialValues({
        'cached_driver_json': '{"id":"d_old","name":"Old Driver"}',
        'cached_vehicle_json': '{"id":"v_old","vehicle_model":"Old Car"}',
        'cached_documents_json': '{"id":"doc_old"}',
        'cached_bank_details_json': '{"id":"bank_old"}',
      });

      final vm = ProfileViewModel();
      await vm.restoreFromLocalCache();

      // In-memory properties must remain null
      expect(vm.driver, isNull);
      expect(vm.vehicle, isNull);
      expect(vm.documents, isNull);
      expect(vm.bankDetails, isNull);
    });

    test('clearSession removes all in-memory state and legacy local storage keys', () async {
      SharedPreferences.setMockInitialValues({
        'cached_app_config_json': '{"version":"1.0.0"}',
        'cached_driver_json': '{"id":"d_1"}',
        'cached_vehicle_json': '{"id":"v_1"}',
        'cached_documents_json': '{"id":"doc_1"}',
        'cached_bank_details_json': '{"id":"bank_1"}',
        'saved_driver_session': 'driver_99',
      });

      final vm = ProfileViewModel();
      await vm.clearSession();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('cached_app_config_json'), isFalse);
      expect(prefs.containsKey('cached_driver_json'), isFalse);
      expect(prefs.containsKey('cached_vehicle_json'), isFalse);
      expect(prefs.containsKey('cached_documents_json'), isFalse);
      expect(prefs.containsKey('cached_bank_details_json'), isFalse);
      expect(prefs.containsKey('saved_driver_session'), isFalse);

      expect(vm.driver, isNull);
      expect(vm.vehicle, isNull);
      expect(vm.documents, isNull);
      expect(vm.bankDetails, isNull);
      expect(vm.ratings, isEmpty);
      expect(vm.trips, isEmpty);
    });
  });
}
