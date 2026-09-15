import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/driver_model.dart';

void main() {
  group('DriverModel unique_id column tests', () {
    test('Parses unique_id correctly from JSON', () {
      final json = {
        'id': 'drv-uuid-1234',
        'unique_id': 'EZMD0001',
        'name': 'Ramesh Singh',
        'email': 'ramesh@example.com',
        'phone': '+919876543210',
      };

      final driver = DriverModel.fromJson(json);

      expect(driver.id, equals('drv-uuid-1234'));
      expect(driver.uniqueId, equals('EZMD0001'));
      expect(driver.name, equals('Ramesh Singh'));
    });

    test('Parses camelCase uniqueId from JSON fallback', () {
      final json = {
        'id': 'drv-uuid-1234',
        'uniqueId': 'EZMD0002',
        'name': 'Ramesh Singh',
        'email': 'ramesh@example.com',
        'phone': '+919876543210',
      };

      final driver = DriverModel.fromJson(json);

      expect(driver.uniqueId, equals('EZMD0002'));
    });

    test('Serializes unique_id to JSON when present', () {
      final driver = DriverModel(
        id: 'drv-uuid-1234',
        uniqueId: 'EZMD0001',
        name: 'Ramesh Singh',
        email: 'ramesh@example.com',
        phone: '+919876543210',
      );

      final json = driver.toJson();

      expect(json['unique_id'], equals('EZMD0001'));
    });

    test('Does not include unique_id in JSON when null', () {
      final driver = DriverModel(
        name: 'Ramesh Singh',
        email: 'ramesh@example.com',
        phone: '+919876543210',
      );

      final json = driver.toJson();

      expect(json.containsKey('unique_id'), isFalse);
    });

    test('copyWith updates uniqueId correctly', () {
      final driver = DriverModel(
        name: 'Ramesh Singh',
        email: 'ramesh@example.com',
        phone: '+919876543210',
      );

      final updated = driver.copyWith(uniqueId: 'EZMD0003');

      expect(updated.uniqueId, equals('EZMD0003'));
      expect(updated.name, equals('Ramesh Singh'));
    });
  });
}
