class BidModel {
  final String? id;
  final String bookingId;
  final String driverId;
  final double currentBookingRate;
  final double driverBid;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BidModel({
    this.id,
    required this.bookingId,
    required this.driverId,
    required this.currentBookingRate,
    required this.driverBid,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
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

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: _toString(json['id']),
      bookingId: _toString(json['booking_id']) ?? '',
      driverId: _toString(json['driver_id']) ?? '',
      currentBookingRate: _toDouble(json['current_booking_rate']),
      driverBid: _toDouble(json['driver_bid']),
      status: _toString(json['status']) ?? 'pending',
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'booking_id': bookingId,
      'driver_id': driverId,
      'current_booking_rate': currentBookingRate,
      'driver_bid': driverBid,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
