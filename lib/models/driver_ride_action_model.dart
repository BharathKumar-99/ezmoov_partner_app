import 'package:intl/intl.dart';

class DriverRideActionModel {
  final int id;
  final String driverId;
  final String? bookingId;
  final String action; // 'accepted', 'declined', 'denied', 'timeout', 'cancelled'
  final DateTime actionTime;
  final String? pickupAddress;
  final String? dropAddress;
  final double? fare;
  final String? vehicleTypeId;
  final String? customerId;
  final String? customerName;
  final String? reason;
  final int? responseTimeSeconds;
  final double? driverLat;
  final double? driverLng;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  DriverRideActionModel({
    required this.id,
    required this.driverId,
    this.bookingId,
    required this.action,
    required this.actionTime,
    this.pickupAddress,
    this.dropAddress,
    this.fare,
    this.vehicleTypeId,
    this.customerId,
    this.customerName,
    this.reason,
    this.responseTimeSeconds,
    this.driverLat,
    this.driverLng,
    this.metadata,
    this.createdAt,
  });

  bool get isAccepted => action.toLowerCase() == 'accepted';
  bool get isDeclined =>
      action.toLowerCase() == 'declined' || action.toLowerCase() == 'denied';
  bool get isTimeout => action.toLowerCase() == 'timeout';
  bool get isCancelled => action.toLowerCase() == 'cancelled';

  String get formattedActionTime =>
      DateFormat('dd MMM yyyy, hh:mm a').format(actionTime.toLocal());

  String get formattedTimeOnly =>
      DateFormat('hh:mm a').format(actionTime.toLocal());

  factory DriverRideActionModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedActionTime;
    try {
      parsedActionTime = json['action_time'] != null
          ? DateTime.parse(json['action_time'].toString())
          : DateTime.now();
    } catch (_) {
      parsedActionTime = DateTime.now();
    }

    DateTime? parsedCreatedAt;
    if (json['created_at'] != null) {
      try {
        parsedCreatedAt = DateTime.parse(json['created_at'].toString());
      } catch (_) {
        parsedCreatedAt = null;
      }
    }

    int parsedId = 0;
    if (json['id'] is int) {
      parsedId = json['id'] as int;
    } else if (json['id'] != null) {
      parsedId = int.tryParse(json['id'].toString()) ?? 0;
    }

    double? parsedFare;
    if (json['fare'] != null) {
      parsedFare = (json['fare'] is num)
          ? (json['fare'] as num).toDouble()
          : double.tryParse(json['fare'].toString());
    }

    double? parsedLat;
    if (json['driver_lat'] != null) {
      parsedLat = (json['driver_lat'] is num)
          ? (json['driver_lat'] as num).toDouble()
          : double.tryParse(json['driver_lat'].toString());
    }

    double? parsedLng;
    if (json['driver_lng'] != null) {
      parsedLng = (json['driver_lng'] is num)
          ? (json['driver_lng'] as num).toDouble()
          : double.tryParse(json['driver_lng'].toString());
    }

    int? parsedResponseTime;
    if (json['response_time_seconds'] != null) {
      parsedResponseTime = (json['response_time_seconds'] is num)
          ? (json['response_time_seconds'] as num).toInt()
          : int.tryParse(json['response_time_seconds'].toString());
    }

    return DriverRideActionModel(
      id: parsedId,
      driverId: (json['driver_id'] ?? '').toString(),
      bookingId: json['booking_id']?.toString(),
      action: (json['action'] ?? 'declined').toString(),
      actionTime: parsedActionTime,
      pickupAddress: json['pickup_address'] as String?,
      dropAddress: json['drop_address'] as String?,
      fare: parsedFare,
      vehicleTypeId: json['vehicle_type_id'] as String?,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String?,
      reason: json['reason'] as String?,
      responseTimeSeconds: parsedResponseTime,
      driverLat: parsedLat,
      driverLng: parsedLng,
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'booking_id': bookingId,
      'action': action,
      'action_time': actionTime.toUtc().toIso8601String(),
      'pickup_address': pickupAddress,
      'drop_address': dropAddress,
      'fare': fare,
      'vehicle_type_id': vehicleTypeId,
      'customer_id': customerId,
      'customer_name': customerName,
      'reason': reason,
      'response_time_seconds': responseTimeSeconds,
      'driver_lat': driverLat,
      'driver_lng': driverLng,
      'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
    };
  }

  DriverRideActionModel copyWith({
    int? id,
    String? driverId,
    String? bookingId,
    String? action,
    DateTime? actionTime,
    String? pickupAddress,
    String? dropAddress,
    double? fare,
    String? vehicleTypeId,
    String? customerId,
    String? customerName,
    String? reason,
    int? responseTimeSeconds,
    double? driverLat,
    double? driverLng,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return DriverRideActionModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      bookingId: bookingId ?? this.bookingId,
      action: action ?? this.action,
      actionTime: actionTime ?? this.actionTime,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      fare: fare ?? this.fare,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      reason: reason ?? this.reason,
      responseTimeSeconds: responseTimeSeconds ?? this.responseTimeSeconds,
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Aggregated acceptance and decline statistics for a driver
class DriverRideStatsModel {
  final String driverId;
  final int totalRequests;
  final int acceptedCount;
  final int declinedCount;
  final int timeoutCount;
  final int cancelledCount;
  final double acceptanceRate;
  final int todayTotal;
  final int todayAccepted;
  final int todayDeclined;

  DriverRideStatsModel({
    required this.driverId,
    required this.totalRequests,
    required this.acceptedCount,
    required this.declinedCount,
    required this.timeoutCount,
    required this.cancelledCount,
    required this.acceptanceRate,
    required this.todayTotal,
    required this.todayAccepted,
    required this.todayDeclined,
  });

  factory DriverRideStatsModel.empty(String driverId) {
    return DriverRideStatsModel(
      driverId: driverId,
      totalRequests: 0,
      acceptedCount: 0,
      declinedCount: 0,
      timeoutCount: 0,
      cancelledCount: 0,
      acceptanceRate: 100.00,
      todayTotal: 0,
      todayAccepted: 0,
      todayDeclined: 0,
    );
  }

  factory DriverRideStatsModel.fromJson(Map<String, dynamic> json) {
    return DriverRideStatsModel(
      driverId: (json['driver_id'] ?? '').toString(),
      totalRequests: (json['total_requests'] as num?)?.toInt() ?? 0,
      acceptedCount: (json['accepted_count'] as num?)?.toInt() ?? 0,
      declinedCount: (json['declined_count'] as num?)?.toInt() ?? 0,
      timeoutCount: (json['timeout_count'] as num?)?.toInt() ?? 0,
      cancelledCount: (json['cancelled_count'] as num?)?.toInt() ?? 0,
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 100.00,
      todayTotal: (json['today_total'] as num?)?.toInt() ?? 0,
      todayAccepted: (json['today_accepted'] as num?)?.toInt() ?? 0,
      todayDeclined: (json['today_declined'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'total_requests': totalRequests,
      'accepted_count': acceptedCount,
      'declined_count': declinedCount,
      'timeout_count': timeoutCount,
      'cancelled_count': cancelledCount,
      'acceptance_rate': acceptanceRate,
      'today_total': todayTotal,
      'today_accepted': todayAccepted,
      'today_declined': todayDeclined,
    };
  }
}
