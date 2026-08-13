class DocumentModel {
  final String? id;
  final String driverId;
  final String aadhaarUrl;
  final String drivingLicenseUrl;
  final String vehicleRcUrl;
  final String panCardUrl;
  final String insuranceUrl;
  final String pucUrl;
  final String permitUrl;
  final String fitnessUrl;
  final String policeClearanceUrl;
  final String selfieWithVehicleUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DocumentModel({
    this.id,
    required this.driverId,
    this.aadhaarUrl = '',
    this.drivingLicenseUrl = '',
    this.vehicleRcUrl = '',
    this.panCardUrl = '',
    this.insuranceUrl = '',
    this.pucUrl = '',
    this.permitUrl = '',
    this.fitnessUrl = '',
    this.policeClearanceUrl = '',
    this.selfieWithVehicleUrl = '',
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String?,
      driverId: json['driver_id'] as String? ?? '',
      aadhaarUrl: json['aadhaar_url'] as String? ?? '',
      drivingLicenseUrl: json['driving_license_url'] as String? ?? '',
      vehicleRcUrl: json['vehicle_rc_url'] as String? ?? '',
      panCardUrl: json['pan_card_url'] as String? ?? '',
      insuranceUrl: json['insurance_url'] as String? ?? '',
      pucUrl: json['puc_url'] as String? ?? '',
      permitUrl: json['permit_url'] as String? ?? '',
      fitnessUrl: json['fitness_url'] as String? ?? '',
      policeClearanceUrl: json['police_clearance_url'] as String? ?? '',
      selfieWithVehicleUrl: json['selfie_with_vehicle_url'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
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
      'aadhaar_url': aadhaarUrl,
      'driving_license_url': drivingLicenseUrl,
      'vehicle_rc_url': vehicleRcUrl,
      'pan_card_url': panCardUrl,
      'insurance_url': insuranceUrl,
      'puc_url': pucUrl,
      'permit_url': permitUrl,
      'fitness_url': fitnessUrl,
      'police_clearance_url': policeClearanceUrl,
      'selfie_with_vehicle_url': selfieWithVehicleUrl,
      'status': status,
    };
  }
}
