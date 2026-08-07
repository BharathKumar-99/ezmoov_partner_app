class DriverModel {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicUrl;
  final bool isOnline;
  final dynamic currentLocation;
  final bool isVerified;
  final bool isVehicleAdded;
  final bool isDocumentsUploaded;
  final bool isBankDetailsAdded;
  final bool isVehicleVerified;
  final bool isDocumentsVerified;
  final bool isBankDetailsVerified;
  final double rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DriverModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicUrl,
    this.isOnline = false,
    this.currentLocation,
    this.isVerified = false,
    this.isVehicleAdded = false,
    this.isDocumentsUploaded = false,
    this.isBankDetailsAdded = false,
    this.isVehicleVerified = false,
    this.isDocumentsVerified = false,
    this.isBankDetailsVerified = false,
    this.rating = 5.0,
    this.createdAt,
    this.updatedAt,
  });

  bool get isFullyVerified =>
      isVerified || (isVehicleVerified && isDocumentsVerified && isBankDetailsVerified);

  /// Extract latitude numeric value from currentLocation JSON map or object
  double? get latitude {
    if (currentLocation is Map) {
      final map = currentLocation as Map;
      final val = map['latitude'] ?? map['lat'];
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
    }
    return null;
  }

  /// Extract longitude numeric value from currentLocation JSON map or object
  double? get longitude {
    if (currentLocation is Map) {
      final map = currentLocation as Map;
      final val = map['longitude'] ?? map['lng'];
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
    }
    return null;
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profilePicUrl: json['profile_pic_url'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      currentLocation: json['current_location'],
      isVerified: json['is_verified'] as bool? ?? false,
      isVehicleAdded: json['is_vehicle_added'] as bool? ?? false,
      isDocumentsUploaded: json['is_documents_uploaded'] as bool? ?? false,
      isBankDetailsAdded: json['is_bank_details_added'] as bool? ?? false,
      isVehicleVerified: json['is_vehicle_verified'] as bool? ?? false,
      isDocumentsVerified: json['is_documents_verified'] as bool? ?? false,
      isBankDetailsVerified: json['is_bank_details_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_pic_url': profilePicUrl,
      'is_online': isOnline,
      'current_location': currentLocation,
      'is_verified': isVerified,
      'is_vehicle_added': isVehicleAdded,
      'is_documents_uploaded': isDocumentsUploaded,
      'is_bank_details_added': isBankDetailsAdded,
      'is_vehicle_verified': isVehicleVerified,
      'is_documents_verified': isDocumentsVerified,
      'is_bank_details_verified': isBankDetailsVerified,
      'rating': rating,
    };
  }

  DriverModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePicUrl,
    bool? isOnline,
    dynamic currentLocation,
    bool? isVerified,
    bool? isVehicleAdded,
    bool? isDocumentsUploaded,
    bool? isBankDetailsAdded,
    bool? isVehicleVerified,
    bool? isDocumentsVerified,
    bool? isBankDetailsVerified,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isOnline: isOnline ?? this.isOnline,
      currentLocation: currentLocation ?? this.currentLocation,
      isVerified: isVerified ?? this.isVerified,
      isVehicleAdded: isVehicleAdded ?? this.isVehicleAdded,
      isDocumentsUploaded: isDocumentsUploaded ?? this.isDocumentsUploaded,
      isBankDetailsAdded: isBankDetailsAdded ?? this.isBankDetailsAdded,
      isVehicleVerified: isVehicleVerified ?? this.isVehicleVerified,
      isDocumentsVerified: isDocumentsVerified ?? this.isDocumentsVerified,
      isBankDetailsVerified: isBankDetailsVerified ?? this.isBankDetailsVerified,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
