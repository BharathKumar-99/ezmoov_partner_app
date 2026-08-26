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
  final num waitTime;

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
    final isAct =
        (json['is_active'] as bool?) ?? (json['active'] as bool?) ?? true;
    return VehicleTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      capacity: json['capacity'] as String? ?? '',
      capacityKg: (json['capacity_kg'] as num?)?.toDouble() ?? 0.0,
      baseFare: (json['base_fare'] as num?)?.toDouble() ??
          (json['est_fare'] as num?)?.toDouble() ??
          0.0,
      dailyFee: (json['daily_fee'] as num?)?.toDouble() ??
          (json['dailyfee'] as num?)?.toDouble() ??
          (json['daily_pass_fee'] as num?)?.toDouble() ??
          0.0,
      iconName: json['icon_name'] as String? ?? 'local_shipping',
      isActive: isAct,
      active: isAct,
      graceTime: (json['grace_time'] as num?)?.toInt() ??
          (json['gracetime'] as num?)?.toInt() ??
          15,
      waitTime: (json['waittime'] as num?) ??
          (json['wait_time'] as num?) ??
          (json['waitTime'] as num?) ??
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
}
