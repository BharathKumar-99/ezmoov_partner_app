import 'dart:convert';

class BookingModel {
  final String id;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String pickupAddress;
  final String dropAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String status;
  final double fare;
  final Map<String, dynamic>? amount;
  final String? vehicleTypeId;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;
  final String? otp;
  final String? pickupUrl;
  final String? podUrl;
  final String? cancellationReason;
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.pickupAddress,
    required this.dropAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.status,
    required this.fare,
    this.amount,
    this.vehicleTypeId,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    this.otp,
    this.pickupUrl,
    this.podUrl,
    this.cancellationReason,
    this.createdAt,
  });

  static Map<String, dynamic>? _parseAmount(dynamic rawAmount) {
    if (rawAmount == null) return null;
    if (rawAmount is Map) {
      return Map<String, dynamic>.from(rawAmount);
    }
    if (rawAmount is String) {
      try {
        final decoded = jsonDecode(rawAmount);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return null;
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final parsedAmount = _parseAmount(json['amount']);
    
    double extractedFare = 0.0;
    if (parsedAmount != null) {
      final total = (parsedAmount['totalfare'] as num?)?.toDouble() ??
          (parsedAmount['total_fare'] as num?)?.toDouble() ??
          (parsedAmount['trip fare'] as num?)?.toDouble() ??
          (parsedAmount['fare'] as num?)?.toDouble();
      if (total != null) {
        extractedFare = total;
      }
    }
    if (extractedFare == 0.0 && json['fare'] != null) {
      extractedFare = (json['fare'] as num?)?.toDouble() ?? 0.0;
    }

    return BookingModel(
      id: json['id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      pickupAddress: json['pickup_address'] as String? ?? '',
      dropAddress: json['drop_address'] as String? ?? '',
      pickupLat: (json['pickup_lat'] as num?)?.toDouble() ?? 0.0,
      pickupLng: (json['pickup_lng'] as num?)?.toDouble() ?? 0.0,
      dropLat: (json['drop_lat'] as num?)?.toDouble() ?? 0.0,
      dropLng: (json['drop_lng'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'searching',
      fare: extractedFare,
      amount: parsedAmount,
      vehicleTypeId: json['vehicle_type_id'] as String?,
      driverId: json['driver_id'] as String?,
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      otp: json['otp'] as String?,
      pickupUrl: json['pickup_url'] as String?,
      podUrl: json['pod_url'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      'pickup_address': pickupAddress,
      'drop_address': dropAddress,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'drop_lat': dropLat,
      'drop_lng': dropLng,
      'status': status,
      'fare': fare,
      if (amount != null) 'amount': amount,
      if (vehicleTypeId != null) 'vehicle_type_id': vehicleTypeId,
      if (driverId != null) 'driver_id': driverId,
      if (driverName != null) 'driver_name': driverName,
      if (driverPhone != null) 'driver_phone': driverPhone,
      if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
      if (otp != null) 'otp': otp,
      if (pickupUrl != null) 'pickup_url': pickupUrl,
      if (podUrl != null) 'pod_url': podUrl,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
    };
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? pickupAddress,
    String? dropAddress,
    double? pickupLat,
    double? pickupLng,
    double? dropLat,
    double? dropLng,
    String? status,
    double? fare,
    Map<String, dynamic>? amount,
    String? vehicleTypeId,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? vehiclePlate,
    String? otp,
    String? pickupUrl,
    String? podUrl,
    String? cancellationReason,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropLat: dropLat ?? this.dropLat,
      dropLng: dropLng ?? this.dropLng,
      status: status ?? this.status,
      fare: fare ?? this.fare,
      amount: amount ?? this.amount,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      otp: otp ?? this.otp,
      pickupUrl: pickupUrl ?? this.pickupUrl,
      podUrl: podUrl ?? this.podUrl,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

