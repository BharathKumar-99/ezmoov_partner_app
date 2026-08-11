class VehicleCatalogModel {
  final String id;
  final String wheelCount;
  final String brand;
  final String model;
  final String bodyType;
  final String payloadCapacity;
  final double baseRate;
  final double ratePerKm;
  final DateTime? createdAt;

  VehicleCatalogModel({
    required this.id,
    required this.wheelCount,
    required this.brand,
    required this.model,
    required this.bodyType,
    required this.payloadCapacity,
    required this.baseRate,
    required this.ratePerKm,
    this.createdAt,
  });

  factory VehicleCatalogModel.fromJson(Map<String, dynamic> json) {
    return VehicleCatalogModel(
      id: json['id'] as String? ?? '',
      wheelCount: json['wheel_count'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      bodyType: json['body_type'] as String? ?? '',
      payloadCapacity: json['payload_capacity'] as String? ?? '',
      baseRate: (json['base_rate'] as num?)?.toDouble() ?? 250.00,
      ratePerKm: (json['rate_per_km'] as num?)?.toDouble() ?? 18.00,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wheel_count': wheelCount,
      'brand': brand,
      'model': model,
      'body_type': bodyType,
      'payload_capacity': payloadCapacity,
      'base_rate': baseRate,
      'rate_per_km': ratePerKm,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  static List<VehicleCatalogModel> get defaultCatalog => [
        VehicleCatalogModel(
          id: 'vcat-3w-piaggio-ape-open',
          wheelCount: '3 Wheeler',
          brand: 'Piaggio',
          model: 'Ape Xtra LDX',
          bodyType: 'Open Body',
          payloadCapacity: '500 kg',
          baseRate: 150.00,
          ratePerKm: 12.00,
        ),
        VehicleCatalogModel(
          id: 'vcat-3w-bajaj-maxima-closed',
          wheelCount: '3 Wheeler',
          brand: 'Bajaj',
          model: 'Maxima C',
          bodyType: 'Closed Body',
          payloadCapacity: '600 kg',
          baseRate: 180.00,
          ratePerKm: 14.00,
        ),
        VehicleCatalogModel(
          id: 'vcat-3w-mahindra-treo-open',
          wheelCount: '3 Wheeler',
          brand: 'Mahindra',
          model: 'Treo Zor',
          bodyType: 'Flatbed Open',
          payloadCapacity: '550 kg',
          baseRate: 160.00,
          ratePerKm: 13.00,
        ),
        VehicleCatalogModel(
          id: 'vcat-4w-tata-ace-open',
          wheelCount: '4 Wheeler',
          brand: 'Tata',
          model: 'Ace Gold',
          bodyType: 'Open Body',
          payloadCapacity: '750 kg',
          baseRate: 250.00,
          ratePerKm: 18.00,
        ),
        VehicleCatalogModel(
          id: 'vcat-4w-tata-ace-closed',
          wheelCount: '4 Wheeler',
          brand: 'Tata',
          model: 'Ace EV',
          bodyType: 'Closed Container',
          payloadCapacity: '600 kg',
          baseRate: 270.00,
          ratePerKm: 19.00,
        ),
        VehicleCatalogModel(
          id: 'vcat-4w-mahindra-bolero-open',
          wheelCount: '4 Wheeler',
          brand: 'Mahindra',
          model: 'Bolero Maxx Pik-Up',
          bodyType: 'Open Body',
          payloadCapacity: '1300 kg',
          baseRate: 350.00,
          ratePerKm: 24.00,
        ),
        VehicleCatalogModel(
          id: 'vcat-4w-mahindra-bolero-container',
          wheelCount: '4 Wheeler',
          brand: 'Mahindra',
          model: 'Bolero Maxx Pik-Up',
          bodyType: 'Closed Container',
          payloadCapacity: '1200 kg',
          baseRate: 380.00,
          ratePerKm: 26.00,
        ),
        VehicleCatalogModel(
          id: 'vcat-4w-ashok-leyland-dost-open',
          wheelCount: '4 Wheeler',
          brand: 'Ashok Leyland',
          model: 'Dost Strong',
          bodyType: 'Open Body',
          payloadCapacity: '1250 kg',
          baseRate: 340.00,
          ratePerKm: 23.00,
        ),
      ];
}
