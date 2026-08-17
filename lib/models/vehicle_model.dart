class VehicleModel {
  final String? id;
  final String driverId;
  final String vehicleNumber;
  final String rcNumber;
  final String rcPicUrl;
  final String? vehicleTypeId;
  final String? vehicleTypeName;
  final String? ownerName;
  final String? bodyType;
  final String? fuelType;
  final String? cityOfOperation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VehicleModel({
    this.id,
    required this.driverId,
    required this.vehicleNumber,
    required this.rcNumber,
    required this.rcPicUrl,
    this.vehicleTypeId,
    this.vehicleTypeName,
    this.ownerName,
    this.bodyType,
    this.fuelType,
    this.cityOfOperation,
    this.createdAt,
    this.updatedAt,
  });

  String? get vehicleType => vehicleTypeName ?? vehicleTypeId;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String?,
      driverId: json['driver_id'] as String? ?? '',
      vehicleNumber: json['vehicle_number'] as String? ?? '',
      rcNumber: json['rc_number'] as String? ?? '',
      rcPicUrl: json['rc_pic_url'] as String? ?? '',
      vehicleTypeId: json['vehicle_type_id']?.toString(),
      vehicleTypeName: json['vehicle_type'] as String?,
      ownerName: json['owner_name'] as String?,
      bodyType: json['body_type'] as String?,
      fuelType: json['fuel_type'] as String?,
      cityOfOperation: json['city_of_operation'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'driver_id': driverId,
      'vehicle_number': vehicleNumber,
      'rc_number': rcNumber,
      'rc_pic_url': rcPicUrl,
    };
    if (id != null) data['id'] = id;
    if (ownerName != null && ownerName!.isNotEmpty) {
      data['owner_name'] = ownerName;
    }
    if (vehicleTypeId != null && vehicleTypeId!.isNotEmpty) {
      final parsedInt = int.tryParse(vehicleTypeId!);
      data['vehicle_type_id'] = parsedInt ?? vehicleTypeId;
    }
    if (vehicleTypeName != null && vehicleTypeName!.isNotEmpty) {
      data['vehicle_type'] = vehicleTypeName;
    }
    if (bodyType != null && bodyType!.isNotEmpty) {
      data['body_type'] = bodyType;
    }
    if (fuelType != null && fuelType!.isNotEmpty) {
      data['fuel_type'] = fuelType;
    }
    if (cityOfOperation != null && cityOfOperation!.isNotEmpty) {
      data['city_of_operation'] = cityOfOperation;
    }
    return data;
  }
}
