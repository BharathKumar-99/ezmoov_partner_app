class VehicleTypeModel {
  final String id;
  final String name;
  final String capacity;
  final double capacityKg;
  final double estFare;
  final String iconName;

  VehicleTypeModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.capacityKg,
    required this.estFare,
    required this.iconName,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      capacity: json['capacity'] as String? ?? '',
      capacityKg: (json['capacity_kg'] as num?)?.toDouble() ?? 0.0,
      estFare: (json['est_fare'] as num?)?.toDouble() ??
          (json['base_fare'] as num?)?.toDouble() ??
          0.0,
      iconName: json['icon_name'] as String? ?? 'electric_rickshaw',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'capacity_kg': capacityKg,
      'est_fare': estFare,
      'icon_name': iconName,
    };
  }

  // Pre-configured default vehicle types matching app specifications with valid UUID format
  static final List<VehicleTypeModel> defaultVehicleTypes = [
    VehicleTypeModel(
      id: '11111111-1111-1111-1111-111111111111',
      name: 'Mini 3W',
      capacity: '90kg',
      capacityKg: 90,
      estFare: 206,
      iconName: 'electric_rickshaw',
    ),
    VehicleTypeModel(
      id: '22222222-2222-2222-2222-222222222222',
      name: '3 Wheeler',
      capacity: '500kg',
      capacityKg: 500,
      estFare: 356,
      iconName: 'local_shipping',
    ),
    VehicleTypeModel(
      id: '33333333-3333-3333-3333-333333333333',
      name: 'Tata Ace',
      capacity: '750kg',
      capacityKg: 750,
      estFare: 374,
      iconName: 'local_shipping',
    ),
    VehicleTypeModel(
      id: '44444444-4444-4444-4444-444444444444',
      name: 'Pickup 8ft',
      capacity: '1,200kg',
      capacityKg: 1200,
      estFare: 511,
      iconName: 'directions_bus',
    ),
    VehicleTypeModel(
      id: '55555555-5555-5555-5555-555555555555',
      name: 'Pickup 1.7 Ton',
      capacity: '1,700kg',
      capacityKg: 1700,
      estFare: 612,
      iconName: 'fire_truck',
    ),
    VehicleTypeModel(
      id: '66666666-6666-6666-6666-666666666666',
      name: '14ft Container',
      capacity: '3,500kg',
      capacityKg: 3500,
      estFare: 1063,
      iconName: 'fire_truck',
    ),
    VehicleTypeModel(
      id: '77777777-7777-7777-7777-777777777777',
      name: '17ft Open',
      capacity: '6,000kg',
      capacityKg: 6000,
      estFare: 1733,
      iconName: 'agriculture',
    ),
  ];
}
