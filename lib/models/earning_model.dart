import 'dart:convert';

class EarningModel {
  final int? id;
  final DateTime? createdAt;
  final Map<String, dynamic>? amount;
  final String? driverId;
  final String? customerId;
  final double driverEarning;
  final String? tripId;
  final bool? paid;

  EarningModel({
    this.id,
    this.createdAt,
    this.amount,
    this.driverId,
    this.customerId,
    required this.driverEarning,
    this.tripId,
    this.paid,
  });

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      final clean = val.replaceAll(RegExp(r'[^0-9.]'), '').trim();
      if (clean.isNotEmpty) return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
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
    if (rawAmount is String) {
      final trimmed = rawAmount.trim();
      if (trimmed.startsWith('{')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
    }
    return null;
  }

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      id: _toInt(json['id']),
      createdAt: _toDateTime(json['created_at']),
      amount: _parseAmount(json['amount']),
      driverId: _toString(json['driver_id']),
      customerId: _toString(json['customer_id']),
      driverEarning: _toDouble(json['driver_earning']),
      tripId: _toString(json['trip_id']),
      paid: json['paid'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (amount != null) 'amount': amount,
      if (driverId != null) 'driver_id': driverId,
      if (customerId != null) 'customer_id': customerId,
      'driver_earning': driverEarning,
      if (tripId != null) 'trip_id': tripId,
      if (paid != null) 'paid': paid,
    };
  }
}
