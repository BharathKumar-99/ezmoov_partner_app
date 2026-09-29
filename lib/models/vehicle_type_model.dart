class VehicleTypeModel {
  final int? idx;
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
  final double perKm;
  final String? infoImage;
  final num waitTime;
  final double millageCost;
  final double outstationCharges;
  final DateTime? createdAt;

  VehicleTypeModel({
    this.idx,
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
    this.perKm = 0.0,
    this.infoImage,
    this.waitTime = 30,
    this.millageCost = 0.0,
    this.outstationCharges = 0.0,
    this.createdAt,
  });

  double get estFare => baseFare;
  double get mileageCost => millageCost;
  double get outstationCharge => outstationCharges;

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.trim()) ?? defaultVal;
    return defaultVal;
  }

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val.trim()) ??
          (double.tryParse(val.trim())?.toInt() ?? defaultVal);
    }
    return defaultVal;
  }

  static num _parseNum(dynamic val, [num defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is num) return val;
    if (val is String) return num.tryParse(val.trim()) ?? defaultVal;
    return defaultVal;
  }

  static DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is String && val.trim().isNotEmpty) {
      return DateTime.tryParse(val.trim());
    }
    return null;
  }

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    final isAct = (json['is_active'] as bool?) ??
        (json['active'] as bool?) ??
        true;

    return VehicleTypeModel(
      idx: json['idx'] != null ? _parseInt(json['idx']) : null,
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      capacity: json['capacity'] as String? ?? '',
      capacityKg: _parseDouble(json['capacity_kg'] ?? json['capacityKg']),
      baseFare: _parseDouble(
          json['base_fare'] ?? json['est_fare'] ?? json['baseFare']),
      dailyFee: _parseDouble(json['daily_fee'] ??
          json['dailyfee'] ??
          json['daily_pass_fee'] ??
          json['dailyFee']),
      iconName: json['icon_name'] as String? ??
          json['iconName'] as String? ??
          'local_shipping',
      isActive: isAct,
      active: isAct,
      graceTime: _parseInt(
          json['grace_time'] ?? json['gracetime'] ?? json['graceTime'], 15),
      perKm: _parseDouble(json['per_km'] ?? json['perKm']),
      infoImage:
          json['info_image'] as String? ?? json['infoImage'] as String?,
      waitTime: _parseNum(
          json['waittime'] ?? json['wait_time'] ?? json['waitTime'], 30),
      millageCost: _parseDouble(json['millage_cost'] ??
          json['mileage_cost'] ??
          json['millageCost'] ??
          json['mileageCost']),
      outstationCharges: _parseDouble(json['outstation_charges'] ??
          json['outstation_charge'] ??
          json['outstationCharges'] ??
          json['outstationCharge']),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idx != null) 'idx': idx,
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
      'per_km': perKm,
      if (infoImage != null) 'info_image': infoImage,
      'waittime': waitTime,
      'millage_cost': millageCost,
      'mileage_cost': millageCost,
      'outstation_charges': outstationCharges,
      'outstation_charge': outstationCharges,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }
}
