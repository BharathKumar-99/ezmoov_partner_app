import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/vehicle_type_model.dart';

void main() {
  group('VehicleTypeModel Unit Tests', () {
    test('Parses vehicle type JSON payload correctly with millage_cost and outstation_charges', () {
      final json = {
        'id': 'v_type_3w',
        'name': '3 Wheeler',
        'capacity': '500 Kgs',
        'capacity_kg': 500.0,
        'base_fare': 210.0,
        'daily_fee': 175.0,
        'icon_name': 'electric_rickshaw',
        'is_active': true,
        'grace_time': 40,
        'waittime': 3.0,
        'millage_cost': 3.50,
        'outstation_charges': 27.00,
      };

      final vt = VehicleTypeModel.fromJson(json);

      expect(vt.id, equals('v_type_3w'));
      expect(vt.name, equals('3 Wheeler'));
      expect(vt.capacityKg, equals(500.0));
      expect(vt.baseFare, equals(210.0));
      expect(vt.dailyFee, equals(175.0));
      expect(vt.millageCost, equals(3.50));
      expect(vt.mileageCost, equals(3.50));
      expect(vt.outstationCharges, equals(27.00));
      expect(vt.isActive, isTrue);

      final outJson = vt.toJson();
      expect(outJson['millage_cost'], equals(3.50));
      expect(outJson['outstation_charges'], equals(27.00));
    });

    test('Parses exact production 6-tier vehicle JSON list with string numbers, idx, per_km, and info_image', () {
      final listJson = [
        {
          "idx": 0,
          "id": 1,
          "name": "2 Wheeler",
          "capacity": "20 Kgs",
          "capacity_kg": "20.00",
          "base_fare": "43.00",
          "daily_fee": "30.00",
          "icon_name": "two_wheeler",
          "created_at": "2026-08-14 14:04:51.903529+00",
          "is_active": false,
          "active": false,
          "grace_time": 20,
          "per_km": 8,
          "info_image": "https://icpqdnkbhdavpcaievdz.supabase.co/storage/v1/object/public/VehicleType/bike.png",
          "waittime": 2,
          "millage_cost": "0.00",
          "outstation_charges": "0.00",
          "mileage_cost": "0.00",
          "outstation_charge": "0.00"
        },
        {
          "idx": 1,
          "id": 2,
          "name": "3 Wheeler",
          "capacity": "500 Kgs",
          "capacity_kg": "500.00",
          "base_fare": "210.00",
          "daily_fee": "175.00",
          "icon_name": "electric_rickshaw",
          "created_at": "2026-08-14 14:04:51.903529+00",
          "is_active": true,
          "active": true,
          "grace_time": 40,
          "per_km": 27,
          "info_image": "https://icpqdnkbhdavpcaievdz.supabase.co/storage/v1/object/public/VehicleType/auto.png",
          "waittime": 3,
          "millage_cost": "3.50",
          "outstation_charges": "27.00",
          "mileage_cost": "3.50",
          "outstation_charge": "27.00"
        },
        {
          "idx": 2,
          "id": 4,
          "name": "4 Wheeler",
          "capacity": "750 Kgs",
          "capacity_kg": "750.00",
          "base_fare": "218.00",
          "daily_fee": "200.00",
          "icon_name": "local_shipping",
          "created_at": "2026-08-14 14:04:51.903529+00",
          "is_active": true,
          "active": true,
          "grace_time": 50,
          "per_km": 35.5,
          "info_image": "https://icpqdnkbhdavpcaievdz.supabase.co/storage/v1/object/public/VehicleType/4wheeler.png",
          "waittime": 3.5,
          "millage_cost": "4.00",
          "outstation_charges": "35.50",
          "mileage_cost": "4.00",
          "outstation_charge": "35.50"
        },
        {
          "idx": 3,
          "id": 5,
          "name": "8 Ft Vehicle",
          "capacity": "1200 Kgs",
          "capacity_kg": "1200.00",
          "base_fare": "318.00",
          "daily_fee": "250.00",
          "icon_name": "local_shipping",
          "created_at": "2026-08-14 14:04:51.903529+00",
          "is_active": true,
          "active": true,
          "grace_time": 80,
          "per_km": 35.71,
          "info_image": "https://icpqdnkbhdavpcaievdz.supabase.co/storage/v1/object/public/VehicleType/8er.png",
          "waittime": 4,
          "millage_cost": "7.00",
          "outstation_charges": "35.71",
          "mileage_cost": "7.00",
          "outstation_charge": "35.71"
        },
        {
          "idx": 4,
          "id": 6,
          "name": "9 Ft Vehicle",
          "capacity": "1700 Kgs",
          "capacity_kg": "1700.00",
          "base_fare": "380.00",
          "daily_fee": "270.00",
          "icon_name": "local_shipping",
          "created_at": "2026-08-14 14:04:51.903529+00",
          "is_active": true,
          "active": true,
          "grace_time": 110,
          "per_km": 42.9,
          "info_image": "https://icpqdnkbhdavpcaievdz.supabase.co/storage/v1/object/public/VehicleType/9ner.png",
          "waittime": 7,
          "millage_cost": "7.00",
          "outstation_charges": "42.90",
          "mileage_cost": "7.00",
          "outstation_charge": "42.90"
        },
        {
          "idx": 5,
          "id": 7,
          "name": "10 Ft Vehicle",
          "capacity": "2000 Kgs",
          "capacity_kg": "2000.00",
          "base_fare": "400.00",
          "daily_fee": "270.00",
          "icon_name": "local_shipping",
          "created_at": "2026-08-14 14:04:51.903529+00",
          "is_active": true,
          "active": true,
          "grace_time": 110,
          "per_km": 45,
          "info_image": "https://icpqdnkbhdavpcaievdz.supabase.co/storage/v1/object/public/VehicleType/10er.png",
          "waittime": 7.5,
          "millage_cost": "7.00",
          "outstation_charges": "45.00",
          "mileage_cost": "7.00",
          "outstation_charge": "45.00"
        }
      ];

      final types = listJson.map((j) => VehicleTypeModel.fromJson(j)).toList();
      expect(types, hasLength(6));

      // 1. 2 Wheeler
      final twoWheeler = types.firstWhere((vt) => vt.id == '1');
      expect(twoWheeler.idx, equals(0));
      expect(twoWheeler.name, equals('2 Wheeler'));
      expect(twoWheeler.capacity, equals('20 Kgs'));
      expect(twoWheeler.capacityKg, equals(20.0));
      expect(twoWheeler.baseFare, equals(43.0));
      expect(twoWheeler.dailyFee, equals(30.0));
      expect(twoWheeler.isActive, isFalse);
      expect(twoWheeler.perKm, equals(8.0));
      expect(twoWheeler.waitTime, equals(2));
      expect(twoWheeler.millageCost, equals(0.0));
      expect(twoWheeler.outstationCharges, equals(0.0));

      // 2. 3 Wheeler
      final threeWheeler = types.firstWhere((vt) => vt.id == '2');
      expect(threeWheeler.idx, equals(1));
      expect(threeWheeler.name, equals('3 Wheeler'));
      expect(threeWheeler.capacityKg, equals(500.0));
      expect(threeWheeler.baseFare, equals(210.0));
      expect(threeWheeler.dailyFee, equals(175.0));
      expect(threeWheeler.isActive, isTrue);
      expect(threeWheeler.graceTime, equals(40));
      expect(threeWheeler.perKm, equals(27.0));
      expect(threeWheeler.waitTime, equals(3));
      expect(threeWheeler.millageCost, equals(3.5));
      expect(threeWheeler.outstationCharges, equals(27.0));

      // 3. 4 Wheeler (750kg)
      final fourWheeler = types.firstWhere((vt) => vt.id == '4');
      expect(fourWheeler.idx, equals(2));
      expect(fourWheeler.name, equals('4 Wheeler'));
      expect(fourWheeler.capacityKg, equals(750.0));
      expect(fourWheeler.baseFare, equals(218.0));
      expect(fourWheeler.dailyFee, equals(200.0));
      expect(fourWheeler.isActive, isTrue);
      expect(fourWheeler.graceTime, equals(50));
      expect(fourWheeler.perKm, equals(35.5));
      expect(fourWheeler.waitTime, equals(3.5));
      expect(fourWheeler.millageCost, equals(4.0));
      expect(fourWheeler.outstationCharges, equals(35.50));

      // 4. 8 Ft Vehicle
      final eightFt = types.firstWhere((vt) => vt.id == '5');
      expect(eightFt.idx, equals(3));
      expect(eightFt.name, equals('8 Ft Vehicle'));
      expect(eightFt.capacityKg, equals(1200.0));
      expect(eightFt.baseFare, equals(318.0));
      expect(eightFt.dailyFee, equals(250.0));
      expect(eightFt.isActive, isTrue);
      expect(eightFt.graceTime, equals(80));
      expect(eightFt.perKm, equals(35.71));
      expect(eightFt.waitTime, equals(4));
      expect(eightFt.millageCost, equals(7.0));
      expect(eightFt.outstationCharges, equals(35.71));

      // 5. 9 Ft Vehicle
      final nineFt = types.firstWhere((vt) => vt.id == '6');
      expect(nineFt.idx, equals(4));
      expect(nineFt.name, equals('9 Ft Vehicle'));
      expect(nineFt.capacityKg, equals(1700.0));
      expect(nineFt.baseFare, equals(380.0));
      expect(nineFt.dailyFee, equals(270.0));
      expect(nineFt.isActive, isTrue);
      expect(nineFt.graceTime, equals(110));
      expect(nineFt.perKm, equals(42.9));
      expect(nineFt.waitTime, equals(7));
      expect(nineFt.millageCost, equals(7.0));
      expect(nineFt.outstationCharges, equals(42.90));

      // 6. 10 Ft Vehicle
      final tenFt = types.firstWhere((vt) => vt.id == '7');
      expect(tenFt.idx, equals(5));
      expect(tenFt.name, equals('10 Ft Vehicle'));
      expect(tenFt.capacityKg, equals(2000.0));
      expect(tenFt.baseFare, equals(400.0));
      expect(tenFt.dailyFee, equals(270.0));
      expect(tenFt.isActive, isTrue);
      expect(tenFt.graceTime, equals(110));
      expect(tenFt.perKm, equals(45.0));
      expect(tenFt.waitTime, equals(7.5));
      expect(tenFt.millageCost, equals(7.0));
      expect(tenFt.outstationCharges, equals(45.00));
    });
  });
}

