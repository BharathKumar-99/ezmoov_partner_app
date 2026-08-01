class BankDetailsModel {
  final String? id;
  final String driverId;
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String? upiId;
  final String? passbookPicUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BankDetailsModel({
    this.id,
    required this.driverId,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    this.upiId,
    this.passbookPicUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(
      id: json['id'] as String?,
      driverId: json['driver_id'] as String? ?? '',
      accountHolderName: json['account_holder_name'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? '',
      accountNumber: json['account_number'] as String? ?? '',
      ifscCode: json['ifsc_code'] as String? ?? '',
      upiId: json['upi_id'] as String?,
      passbookPicUrl: json['passbook_pic_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'driver_id': driverId,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'upi_id': upiId,
      'passbook_pic_url': passbookPicUrl,
    };
  }
}
