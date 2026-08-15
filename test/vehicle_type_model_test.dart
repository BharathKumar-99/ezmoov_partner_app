import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/vehicle_type_model.dart';

void main() {
  group('VehicleTypeModel Unit Tests', () {
    test('Parses vehicle type JSON payload correctly', () {
      final json = {
        'id': 'v_type_3w',
        'name': '3 Wheeler',
        'capacity': '500 Kgs',
        'capacity_kg': 500.0,
        'base_fare': 210.0,
        'daily_fee': 175.0,
        'icon_name': 'electric_rickshaw',
        'is_active': true,
      };

      final vt = VehicleTypeModel.fromJson(json);

      expect(vt.id, equals('v_type_3w'));
      expect(vt.name, equals('3 Wheeler'));
      expect(vt.capacityKg, equals(500.0));
      expect(vt.baseFare, equals(210.0));
      expect(vt.dailyFee, equals(175.0));
      expect(vt.isActive, isTrue);
    });

    test('Contains valid default vehicle types list', () {
      final defaults = VehicleTypeModel.defaultVehicleTypes;
      expect(defaults, isNotEmpty);
      expect(defaults.any((vt) => vt.name == '3 Wheeler'), isTrue);
      expect(defaults.any((vt) => vt.name == '4 Wheeler'), isTrue);
    });
  });
}
