class RatingModel {
  final String? id;
  final String driverId;
  final String? tripId;
  final String customerName;
  final double rating;
  final String? reviewComment;
  final DateTime? createdAt;

  RatingModel({
    this.id,
    required this.driverId,
    this.tripId,
    this.customerName = 'Customer',
    required this.rating,
    this.reviewComment,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String?,
      driverId: json['driver_id'] as String? ?? '',
      tripId: json['trip_id'] as String?,
      customerName: json['customer_name'] as String? ?? 'Customer',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewComment: json['review_comment'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'driver_id': driverId,
      if (tripId != null) 'trip_id': tripId,
      'customer_name': customerName,
      'rating': rating,
      if (reviewComment != null) 'review_comment': reviewComment,
    };
  }
}
