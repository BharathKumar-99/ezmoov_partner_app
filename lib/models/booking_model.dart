import 'dart:convert';

class BookingModel {
  final int? idx;
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
  final String? paymentMode;
  final String? service;
  final DateTime? acceptedAt;
  final DateTime? arrivedAtPickupAt;
  final DateTime? tripStartedAt;
  final DateTime? arrivedAtDropoffAt;
  final DateTime? tripCompletedAt;
  final int totalWaitMinutes;
  final int graceTimeMinutes;
  final int chargeableWaitMinutes;
  final double waitFeePerMin;
  final double waitingCharges;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    this.idx,
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
    this.paymentMode,
    this.service,
    this.acceptedAt,
    this.arrivedAtPickupAt,
    this.tripStartedAt,
    this.arrivedAtDropoffAt,
    this.tripCompletedAt,
    this.totalWaitMinutes = 0,
    this.graceTimeMinutes = 15,
    this.chargeableWaitMinutes = 0,
    this.waitFeePerMin = 0.0,
    this.waitingCharges = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  /// Dynamic fare getter computed from amount JSON
  double get fare => extractFare(toJson());

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) {
      final clean = val.replaceAll(RegExp(r'[^0-9.]'), '').trim();
      if (clean.isNotEmpty) return double.tryParse(clean);
    }
    return null;
  }

  static int? _toInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) {
      final clean = val.trim();
      if (clean.isNotEmpty) return int.tryParse(clean);
    }
    return null;
  }

  static String? _toString(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    return str.isNotEmpty ? str : null;
  }

  static DateTime? _toDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    final str = val.toString().trim();
    if (str.isEmpty) return null;
    return DateTime.tryParse(str);
  }

  static Map<String, dynamic>? _parseAmount(dynamic rawAmount) {
    if (rawAmount == null) return null;
    if (rawAmount is Map) {
      return Map<String, dynamic>.from(rawAmount);
    }
    if (rawAmount is num) {
      return {'total_amount': rawAmount.toDouble()};
    }
    if (rawAmount is String) {
      final trimmed = rawAmount.trim();
      if (trimmed.startsWith('{')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      } else {
        final dbl = double.tryParse(trimmed);
        if (dbl != null) {
          return {'total_amount': dbl};
        }
      }
    }
    return null;
  }

  static double extractFare(Map<String, dynamic> json) {
    double? extractFromMap(Map map) {
      double? totalVal;
      double? tripVal;
      double? fareVal;
      double? baseVal;
      double? distanceVal;
      double? gstVal;
      double? discountVal;

      map.forEach((k, v) {
        if (v == null) return;
        final rawKey = k.toString().toLowerCase();
        final key = rawKey.replaceAll(RegExp(r'[\s_\-]'), '');

        // Skip driver_charges when calculating base fare
        if (key == 'drivercharges') return;

        // If v is a nested Map (e.g. fare_breakdown, price_details)
        if (v is Map) {
          final nested = extractFromMap(v);
          if (nested != null && nested > 0) {
            fareVal ??= nested;
          }
          return;
        }

        final dbl = _toDouble(v);
        if (dbl == null || dbl <= 0) return;

        // 1. Total / Payable / Grand / Net / Final Price/Fare/Amount
        if (key.contains('totalprice') ||
            key.contains('totalfare') ||
            key.contains('totalamount') ||
            key.contains('grandtotal') ||
            key.contains('finalprice') ||
            key.contains('finalfare') ||
            key.contains('finalamount') ||
            key.contains('payableprice') ||
            key.contains('payableamount') ||
            key.contains('netfare') ||
            key.contains('netprice') ||
            key == 'totalprice' ||
            key == 'total') {
          totalVal ??= dbl;
        }
        // 2. Trip / Estimated Fare
        else if (key.contains('tripfare') ||
            key.contains('estimated') ||
            key.contains('trip')) {
          tripVal ??= dbl;
        }
        // 3. Discount / Promo Amount
        else if (key.contains('discount') || key.contains('promo')) {
          discountVal ??= dbl;
        }
        // 4. Base Fare / Charge
        else if (key.contains('base')) {
          baseVal ??= dbl;
        }
        // 5. Distance Charges / Fare
        else if (key.contains('distance')) {
          distanceVal ??= dbl;
        }
        // 6. Taxes / GST
        else if (key.contains('tax') || key.contains('gst')) {
          gstVal ??= dbl;
        }
        // 7. Generic Fare / Price / Amount / Cost
        else if (key == 'fare' ||
            key == 'amount' ||
            key == 'price' ||
            key == 'cost') {
          fareVal ??= dbl;
        }
      });

      if (totalVal != null && totalVal! > 0) return totalVal!;
      if (tripVal != null && tripVal! > 0) return tripVal!;
      if (fareVal != null && fareVal! > 0) return fareVal!;

      // Sum components if no direct total key was present
      if (baseVal != null && baseVal! > 0) {
        double sum = baseVal!;
        if (distanceVal != null) sum += distanceVal!;
        if (gstVal != null) sum += gstVal!;
        if (discountVal != null) sum -= discountVal!;
        if (sum > 0) return sum;
      }

      return null;
    }

    // Helper to extract driver_charges sum if present
    double extraDriverChargesSum = 0.0;
    dynamic driverChargesObj;
    if (json['amount'] is Map &&
        (json['amount'] as Map).containsKey('driver_charges')) {
      driverChargesObj = json['amount']['driver_charges'];
    } else if (json['amount'] is String &&
        json['amount'].toString().contains('driver_charges')) {
      try {
        final decoded = jsonDecode(json['amount'].toString());
        if (decoded is Map && decoded.containsKey('driver_charges')) {
          driverChargesObj = decoded['driver_charges'];
        }
      } catch (_) {}
    } else if (json.containsKey('driver_charges')) {
      driverChargesObj = json['driver_charges'];
    }

    if (driverChargesObj is Map) {
      driverChargesObj.forEach((k, v) {
        final dbl = _toDouble(v);
        if (dbl != null && dbl > 0) {
          extraDriverChargesSum += dbl;
        }
      });
    }

    double baseFareCalculated = 0.0;

    // 1. Try parsing amount field if present
    final rawAmount = json['amount'];
    if (rawAmount != null) {
      if (rawAmount is Map) {
        final f = extractFromMap(rawAmount);
        if (f != null && f > 0) baseFareCalculated = f;
      } else if (rawAmount is String) {
        final trimmed = rawAmount.trim();
        if (trimmed.startsWith('{')) {
          try {
            final decoded = jsonDecode(trimmed);
            if (decoded is Map) {
              final f = extractFromMap(decoded);
              if (f != null && f > 0) baseFareCalculated = f;
            }
          } catch (_) {}
        } else {
          final dbl = _toDouble(trimmed);
          if (dbl != null && dbl > 0) baseFareCalculated = dbl;
        }
      } else if (rawAmount is num && rawAmount > 0) {
        baseFareCalculated = rawAmount.toDouble();
      }
    }

    // 2. Try top-level map fields
    if (baseFareCalculated == 0.0) {
      final topLevelFare = extractFromMap(json);
      if (topLevelFare != null && topLevelFare > 0) {
        baseFareCalculated = topLevelFare;
      }
    }

    return baseFareCalculated + extraDriverChargesSum;
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final parsedAmount = _parseAmount(json['amount']);

    return BookingModel(
      idx: _toInt(json['idx']),
      id: _toString(json['id']) ?? '',
      customerId: _toString(json['customer_id']) ?? '',
      customerName: _toString(json['customer_name']),
      customerPhone: _toString(json['customer_phone']),
      pickupAddress: _toString(json['pickup_address']) ?? '',
      dropAddress: _toString(json['drop_address']) ?? '',
      pickupLat: _toDouble(json['pickup_lat']) ?? 0.0,
      pickupLng: _toDouble(json['pickup_lng']) ?? 0.0,
      dropLat: _toDouble(json['drop_lat']) ?? 0.0,
      dropLng: _toDouble(json['drop_lng']) ?? 0.0,
      status: _toString(json['status']) ?? 'searching',
      amount: parsedAmount,
      vehicleTypeId: _toString(json['vehicle_type_id']),
      driverId: _toString(json['driver_id']),
      driverName: _toString(json['driver_name']),
      driverPhone: _toString(json['driver_phone']),
      vehiclePlate: _toString(json['vehicle_plate']),
      otp: _toString(json['otp']),
      pickupUrl: _toString(json['pickup_url']),
      podUrl: _toString(json['pod_url']),
      cancellationReason: _toString(json['cancellation_reason']),
      paymentMode: _toString(json['payment_mode']),
      service: _toString(json['service']) ?? _toString(json['services']),
      acceptedAt: _toDateTime(json['accepted_at']),
      arrivedAtPickupAt: _toDateTime(json['arrived_at_pickup_at']),
      tripStartedAt: _toDateTime(json['trip_started_at']),
      arrivedAtDropoffAt: _toDateTime(json['arrived_at_dropoff_at']),
      tripCompletedAt: _toDateTime(json['trip_completed_at']),
      totalWaitMinutes: _toInt(json['total_wait_minutes']) ?? 0,
      graceTimeMinutes: _toInt(json['grace_time_minutes']) ?? 15,
      chargeableWaitMinutes: _toInt(json['chargeable_wait_minutes']) ?? 0,
      waitFeePerMin: _toDouble(json['wait_fee_per_min']) ?? 0.0,
      waitingCharges: _toDouble(json['waiting_charges']) ?? 0.0,
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idx != null) 'idx': idx,
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
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (service != null) 'service': service,
      if (acceptedAt != null) 'accepted_at': acceptedAt!.toIso8601String(),
      if (arrivedAtPickupAt != null) 'arrived_at_pickup_at': arrivedAtPickupAt!.toIso8601String(),
      if (tripStartedAt != null) 'trip_started_at': tripStartedAt!.toIso8601String(),
      if (arrivedAtDropoffAt != null) 'arrived_at_dropoff_at': arrivedAtDropoffAt!.toIso8601String(),
      if (tripCompletedAt != null) 'trip_completed_at': tripCompletedAt!.toIso8601String(),
      'total_wait_minutes': totalWaitMinutes,
      'grace_time_minutes': graceTimeMinutes,
      'chargeable_wait_minutes': chargeableWaitMinutes,
      'wait_fee_per_min': waitFeePerMin,
      'waiting_charges': waitingCharges,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  BookingModel copyWith({
    int? idx,
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
    String? paymentMode,
    String? service,
    DateTime? acceptedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      idx: idx ?? this.idx,
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
      paymentMode: paymentMode ?? this.paymentMode,
      service: service ?? this.service,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
