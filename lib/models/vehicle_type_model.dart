class VehicleTypeModel {
  final String id;
  final String name;
  final String capacity;
  final double capacityKg;
  final double baseFare;
  final double dailyFee;
  final String iconName;
  final bool isActive;
  final bool active;
  final int graceTime;
  final int waitTime;

  VehicleTypeModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.capacityKg,
    required this.baseFare,
    required this.dailyFee,
    required this.iconName,
    this.isActive = true,
    this.active = true,
    this.graceTime = 15,
    this.waitTime = 30,
  });

  double get estFare => baseFare;

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    final isAct = (json['is_active'] as bool?) ?? (json['active'] as bool?) ?? true;
    return VehicleTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      capacity: json['capacity'] as String? ?? '',
      capacityKg: (json['capacity_kg'] as num?)?.toDouble() ?? 0.0,
      baseFare: (json['base_fare'] as num?)?.toDouble() ??
          (json['est_fare'] as num?)?.toDouble() ??
          0.0,
      dailyFee: (json['daily_fee'] as num?)?.toDouble() ?? 100.0,
      iconName: json['icon_name'] as String? ?? 'local_shipping',
      isActive: isAct,
      active: isAct,
      graceTime: (json['grace_time'] as num?)?.toInt() ??
          (json['gracetime'] as num?)?.toInt() ??
          15,
      waitTime: (json['waittime'] as num?)?.toInt() ??
          (json['wait_time'] as num?)?.toInt() ??
          30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'capacity_kg': capacityKg,
      'base_fare': baseFare,
      'daily_fee': dailyFee,
      'icon_name': iconName,
      'is_active': isActive,
      'active': active,
      'grace_time': graceTime,
      'waittime': waitTime,
    };
  }

  // Default vehicle dataset matching database table
  static final List<VehicleTypeModel> defaultVehicleTypes = [
    VehicleTypeModel(
      id: '1',
      name: '2 Wheeler',
      capacity: '20 Kgs',
      capacityKg: 20,
      baseFare: 100,
      dailyFee: 100,
      iconName: 'two_wheeler',
      isActive: false,
      active: false,
      graceTime: 10,
      waitTime: 15,
    ),
    VehicleTypeModel(
      id: '2',
      name: '3 Wheeler',
      capacity: '500 Kgs',
      capacityKg: 500,
      baseFare: 210,
      dailyFee: 175,
      iconName: 'electric_rickshaw',
      isActive: true,
      active: true,
      graceTime: 15,
      waitTime: 30,
    ),
    VehicleTypeModel(
      id: '3',
      name: 'Mini 3 Wheeler',
      capacity: '90 Kgs',
      capacityKg: 90,
      baseFare: 150,
      dailyFee: 175,
      iconName: 'electric_rickshaw',
      isActive: true,
      active: true,
      graceTime: 15,
      waitTime: 30,
    ),
    VehicleTypeModel(
      id: '4',
      name: '4 Wheeler',
      capacity: '750 Kgs',
      capacityKg: 750,
      baseFare: 218,
      dailyFee: 200,
      iconName: 'local_shipping',
      isActive: true,
      active: true,
      graceTime: 15,
      waitTime: 45,
    ),
    VehicleTypeModel(
      id: '5',
      name: '8 Ft Vehicle',
      capacity: '1200 Kgs',
      capacityKg: 1200,
      baseFare: 318,
      dailyFee: 250,
      iconName: 'local_shipping',
      isActive: true,
      active: true,
      graceTime: 20,
      waitTime: 60,
    ),
    VehicleTypeModel(
      id: '6',
      name: '9 Ft Vehicle',
      capacity: '1700 Kgs',
      capacityKg: 1700,
      baseFare: 380,
      dailyFee: 270,
      iconName: 'local_shipping',
      isActive: true,
      active: true,
      graceTime: 20,
      waitTime: 60,
    ),
    VehicleTypeModel(
      id: '7',
      name: '10 Ft Vehicle',
      capacity: '2000 Kgs',
      capacityKg: 2000,
      baseFare: 450,
      dailyFee: 270,
      iconName: 'local_shipping',
      isActive: true,
      active: true,
      graceTime: 20,
      waitTime: 60,
    ),
  ];
}
