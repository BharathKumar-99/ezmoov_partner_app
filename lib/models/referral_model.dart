class ReferralModel {
  final String id;
  final String referrerDriverId;
  final String referredDriverId;
  final String referralCode;
  final String status; // 'pending', 'verified', 'completed', 'rewarded'
  final double rewardAmount;
  final DateTime createdAt;
  final DateTime? completedAt;

  // Joined driver info (if fetched via RPC or join query)
  final String? referredDriverName;
  final String? referredDriverPhone;

  ReferralModel({
    required this.id,
    required this.referrerDriverId,
    required this.referredDriverId,
    required this.referralCode,
    this.status = 'pending',
    this.rewardAmount = 25.0,
    required this.createdAt,
    this.completedAt,
    this.referredDriverName,
    this.referredDriverPhone,
  });

  bool get isRewarded => status == 'rewarded' || status == 'completed';

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    String? driverName;
    String? driverPhone;

    if (json['referred_driver'] != null && json['referred_driver'] is Map) {
      final drv = json['referred_driver'] as Map;
      driverName = drv['name'] as String?;
      driverPhone = drv['phone'] as String?;
    }

    return ReferralModel(
      id: json['id']?.toString() ?? '',
      referrerDriverId: json['referrer_driver_id']?.toString() ?? '',
      referredDriverId: json['referred_driver_id']?.toString() ?? '',
      referralCode: json['referral_code'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      rewardAmount: (json['reward_amount'] as num?)?.toDouble() ?? 25.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      referredDriverName: driverName ?? json['referred_driver_name'] as String?,
      referredDriverPhone: driverPhone ?? json['referred_driver_phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_driver_id': referrerDriverId,
      'referred_driver_id': referredDriverId,
      'referral_code': referralCode,
      'status': status,
      'reward_amount': rewardAmount,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }
}
