class IntermediateStopModel {
  final double latitude;
  final double longitude;
  final String address;
  final bool isCompleted;

  IntermediateStopModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.isCompleted = false,
  });

  factory IntermediateStopModel.fromJson(Map<String, dynamic> json) {
    double parseDbl(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val.trim()) ?? 0.0;
      return 0.0;
    }

    final lat = parseDbl(json['latitude'] ?? json['lat'] ?? json['pickup_lat'] ?? json['y']);
    final lng = parseDbl(json['longitude'] ?? json['lng'] ?? json['lon'] ?? json['pickup_lng'] ?? json['x']);
    final addr = json['address']?.toString() ??
        json['name']?.toString() ??
        json['location']?.toString() ??
        json['stop_address']?.toString() ??
        json['pickup_address']?.toString() ??
        json['drop_address']?.toString() ??
        '';

    final isComp = (json['is_completed'] ?? json['completed'] ?? json['isCompleted']) == true;

    return IntermediateStopModel(
      latitude: lat,
      longitude: lng,
      address: addr,
      isCompleted: isComp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'is_completed': isCompleted,
    };
  }

  IntermediateStopModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    bool? isCompleted,
  }) {
    return IntermediateStopModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
