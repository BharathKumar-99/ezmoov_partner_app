class DriverWalletModel {
  final String? id;
  final String driverId;
  final double balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DriverWalletModel({
    this.id,
    required this.driverId,
    this.balance = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory DriverWalletModel.fromJson(Map<String, dynamic> json) {
    return DriverWalletModel(
      id: json['id'] as String?,
      driverId: json['driver_id'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'driver_id': driverId,
      'balance': balance,
    };
  }
}

class WalletTransactionModel {
  final String id;
  final String driverId;
  final double amount;
  final String type; // 'recharge', 'daily_deduction', 'earning_credit', 'commission_deduction', 'settlement'
  final String description;
  final String? referenceId;
  final String paymentMethod;
  final DateTime createdAt;

  WalletTransactionModel({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.type,
    required this.description,
    this.referenceId,
    this.paymentMethod = 'UPI',
    required this.createdAt,
  });

  bool get isCredit => amount > 0;

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String? ?? '',
      driverId: json['driver_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'transaction',
      description: json['description'] as String? ?? '',
      referenceId: json['reference_id'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'UPI',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'amount': amount,
      'type': type,
      'description': description,
      if (referenceId != null) 'reference_id': referenceId,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class DriverDailyStatusModel {
  final String? id;
  final String driverId;
  final DateTime statusDate;
  final double dailyFee;
  final bool feeDeducted;
  final int rejectionsCount;
  final bool isBlocked;
  final String? blockReason; // 'insufficient_wallet_balance', 'exceeded_rejections'

  DriverDailyStatusModel({
    this.id,
    required this.driverId,
    required this.statusDate,
    this.dailyFee = 100.0,
    this.feeDeducted = false,
    this.rejectionsCount = 0,
    this.isBlocked = false,
    this.blockReason,
  });

  factory DriverDailyStatusModel.fromJson(Map<String, dynamic> json) {
    return DriverDailyStatusModel(
      id: json['id'] as String?,
      driverId: json['driver_id'] as String? ?? '',
      statusDate: json['status_date'] != null
          ? DateTime.parse(json['status_date'])
          : DateTime.now(),
      dailyFee: (json['daily_fee'] as num?)?.toDouble() ?? 100.0,
      feeDeducted: json['fee_deducted'] as bool? ?? false,
      rejectionsCount: json['rejections_count'] as int? ?? 0,
      isBlocked: json['is_blocked'] as bool? ?? false,
      blockReason: json['block_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'driver_id': driverId,
      'status_date': statusDate.toIso8601String().split('T').first,
      'daily_fee': dailyFee,
      'fee_deducted': feeDeducted,
      'rejections_count': rejectionsCount,
      'is_blocked': isBlocked,
      if (blockReason != null) 'block_reason': blockReason,
    };
  }
}
