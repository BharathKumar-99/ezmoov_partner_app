/// Model representing the dynamic partner app configuration from `public.partner_app_config` table
class PartnerAppConfigModel {
  final int id;
  final String version;
  final bool isMaintenance;
  final bool forceUpdate;
  final String updateUrl;
  final String updateTitle;
  final String updateMessage;
  final String minVersion;
  final double registrationFee;
  final bool isFreeDriverLogin;
  final String maintenanceTitle;
  final String maintenanceMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PartnerAppConfigModel({
    this.id = 1,
    this.version = '1.0.0',
    this.isMaintenance = false,
    this.forceUpdate = false,
    this.updateUrl = 'https://play.google.com/store/apps/details?id=com.ezmoov.partner',
    this.updateTitle = 'Update Available',
    this.updateMessage = 'A new version of EZMoov Partner is available. Please update the app to continue.',
    this.minVersion = '1.0.0',
    this.registrationFee = 499.00,
    this.isFreeDriverLogin = false,
    this.maintenanceTitle = 'App Under Maintenance',
    this.maintenanceMessage = 'We are currently undergoing scheduled maintenance. Please check back shortly.',
    this.createdAt,
    this.updatedAt,
  });

  /// Alias for the user-specified column spelling `is_maintanace`
  bool get isMaintanace => isMaintenance;

  /// Alias for the user-specified column spelling `regestration_fee`
  double get regestrationFee => registrationFee;

  /// Alias for the user-specified column name `update`
  bool get update => forceUpdate;

  factory PartnerAppConfigModel.defaultConfig() {
    return const PartnerAppConfigModel();
  }

  factory PartnerAppConfigModel.fromJson(Map<String, dynamic> json) {
    // 1. Maintenance flag handling (support 'is_maintanace', 'is_maintenance', 'isMaintenance')
    bool maintenance = false;
    if (json.containsKey('is_maintanace') && json['is_maintanace'] != null) {
      maintenance = json['is_maintanace'] == true || json['is_maintanace'].toString() == 'true';
    } else if (json.containsKey('is_maintenance') && json['is_maintenance'] != null) {
      maintenance = json['is_maintenance'] == true || json['is_maintenance'].toString() == 'true';
    } else if (json.containsKey('isMaintenance') && json['isMaintenance'] != null) {
      maintenance = json['isMaintenance'] == true || json['isMaintenance'].toString() == 'true';
    }

    // 2. Update flag handling (support 'update', 'force_update', 'forceUpdate', 'is_update')
    bool updateFlag = false;
    if (json.containsKey('update') && json['update'] != null) {
      updateFlag = json['update'] == true || json['update'].toString() == 'true';
    } else if (json.containsKey('force_update') && json['force_update'] != null) {
      updateFlag = json['force_update'] == true || json['force_update'].toString() == 'true';
    } else if (json.containsKey('forceUpdate') && json['forceUpdate'] != null) {
      updateFlag = json['forceUpdate'] == true || json['forceUpdate'].toString() == 'true';
    }

    // 3. Registration fee parsing (support 'regestration_fee', 'registration_fee', 'registrationFee')
    double fee = 499.00;
    if (json.containsKey('regestration_fee') && json['regestration_fee'] != null) {
      fee = double.tryParse(json['regestration_fee'].toString()) ?? 499.00;
    } else if (json.containsKey('registration_fee') && json['registration_fee'] != null) {
      fee = double.tryParse(json['registration_fee'].toString()) ?? 499.00;
    } else if (json.containsKey('registrationFee') && json['registrationFee'] != null) {
      fee = double.tryParse(json['registrationFee'].toString()) ?? 499.00;
    }

    // 4. Free driver login flag (support 'is_free_driver_login', 'isFreeDriverLogin')
    bool freeLogin = false;
    if (json.containsKey('is_free_driver_login') && json['is_free_driver_login'] != null) {
      freeLogin = json['is_free_driver_login'] == true || json['is_free_driver_login'].toString() == 'true';
    } else if (json.containsKey('isFreeDriverLogin') && json['isFreeDriverLogin'] != null) {
      freeLogin = json['isFreeDriverLogin'] == true || json['isFreeDriverLogin'].toString() == 'true';
    }

    return PartnerAppConfigModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 1 : 1,
      version: json['version']?.toString() ?? '1.0.0',
      isMaintenance: maintenance,
      forceUpdate: updateFlag,
      updateUrl: json['update_url']?.toString() ??
          json['updateUrl']?.toString() ??
          'https://play.google.com/store/apps/details?id=com.ezmoov.partner',
      updateTitle: json['update_title']?.toString() ?? json['updateTitle']?.toString() ?? 'Update Available',
      updateMessage: json['update_message']?.toString() ??
          json['updateMessage']?.toString() ??
          'A new version of EZMoov Partner is available. Please update the app to continue.',
      minVersion: json['min_version']?.toString() ?? json['minVersion']?.toString() ?? '1.0.0',
      registrationFee: fee,
      isFreeDriverLogin: freeLogin,
      maintenanceTitle: json['maintenance_title']?.toString() ??
          json['maintenanceTitle']?.toString() ??
          'App Under Maintenance',
      maintenanceMessage: json['maintenance_message']?.toString() ??
          json['maintenanceMessage']?.toString() ??
          'We are currently undergoing scheduled maintenance. Please check back shortly.',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'is_maintanace': isMaintenance,
      'is_maintenance': isMaintenance,
      'update': forceUpdate,
      'force_update': forceUpdate,
      'update_url': updateUrl,
      'update_title': updateTitle,
      'update_message': updateMessage,
      'min_version': minVersion,
      'regestration_fee': registrationFee,
      'registration_fee': registrationFee,
      'is_free_driver_login': isFreeDriverLogin,
      'maintenance_title': maintenanceTitle,
      'maintenance_message': maintenanceMessage,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  PartnerAppConfigModel copyWith({
    int? id,
    String? version,
    bool? isMaintenance,
    bool? forceUpdate,
    String? updateUrl,
    String? updateTitle,
    String? updateMessage,
    String? minVersion,
    double? registrationFee,
    bool? isFreeDriverLogin,
    String? maintenanceTitle,
    String? maintenanceMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerAppConfigModel(
      id: id ?? this.id,
      version: version ?? this.version,
      isMaintenance: isMaintenance ?? this.isMaintenance,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      updateUrl: updateUrl ?? this.updateUrl,
      updateTitle: updateTitle ?? this.updateTitle,
      updateMessage: updateMessage ?? this.updateMessage,
      minVersion: minVersion ?? this.minVersion,
      registrationFee: registrationFee ?? this.registrationFee,
      isFreeDriverLogin: isFreeDriverLogin ?? this.isFreeDriverLogin,
      maintenanceTitle: maintenanceTitle ?? this.maintenanceTitle,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PartnerAppConfigModel(id: $id, version: $version, isMaintenance: $isMaintenance, update: $forceUpdate, registrationFee: $registrationFee, isFreeDriverLogin: $isFreeDriverLogin)';
  }
}
