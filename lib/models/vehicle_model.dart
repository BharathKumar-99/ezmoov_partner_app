class VehicleModel {
  final String? id;
  final String driverId;
  final String vehicleNumber;
  final String rcNumber;
  final String rcPicUrl;
  final String? vehicleTypeId;
  final String? vehicleTypeName;
  final String? ownerName;
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
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'driver_id': driverId,
      'vehicle_number': vehicleNumber,
      'rc_number': rcNumber,
      'rc_pic_url': rcPicUrl,
      if (vehicleTypeId != null) 'vehicle_type_id': vehicleTypeId,
      if (vehicleTypeName != null) 'vehicle_type': vehicleTypeName,
      if (ownerName != null) 'owner_name': ownerName,
    };
  }
}
