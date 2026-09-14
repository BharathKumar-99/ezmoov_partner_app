import 'package:package_info_plus/package_info_plus.dart';

/// Global application constants for EZMoov Partner App
class AppConstants {
  AppConstants._();

  static String _appVersion = '1.0.3';
  static int _buildNumber = 13;
  static String _packageName = 'com.ezmoov.partner';

  /// Current application version (dynamically fetched from package_info_plus, defaults to fallback)
  static String get appVersion => _appVersion;

  /// Current application build number
  static int get buildNumber => _buildNumber;

  /// Default package name
  static String get packageName => _packageName;

  /// Play Store fallback URL
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.ezmoov.partner';

  /// Initialize and load application package metadata at runtime
  static Future<void> initialize() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        _appVersion = info.version;
      }
      if (info.buildNumber.isNotEmpty) {
        _buildNumber = int.tryParse(info.buildNumber) ?? _buildNumber;
      }
      if (info.packageName.isNotEmpty) {
        _packageName = info.packageName;
      }
    } catch (_) {
      // Fallback defaults preserved if platform channel is not available (e.g. unit tests)
    }
  }

  /// Explicitly set version (e.g., for unit testing or overrides)
  static void setAppVersion(String version) {
    _appVersion = version;
  }
}
