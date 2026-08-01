class DocumentModel {
  final String? id;
  final String driverId;
  final String pucUrl;
  final String permitUrl;
  final String fitnessUrl;
  final String policeClearanceUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DocumentModel({
    this.id,
    required this.driverId,
    required this.pucUrl,
    required this.permitUrl,
    required this.fitnessUrl,
    required this.policeClearanceUrl,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String?,
      driverId: json['driver_id'] as String? ?? '',
      pucUrl: json['puc_url'] as String? ?? '',
      permitUrl: json['permit_url'] as String? ?? '',
      fitnessUrl: json['fitness_url'] as String? ?? '',
      policeClearanceUrl: json['police_clearance_url'] as String? ?? '',
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
      'puc_url': pucUrl,
      'permit_url': permitUrl,
      'fitness_url': fitnessUrl,
      'police_clearance_url': policeClearanceUrl,
      'status': status,
    };
  }
}
