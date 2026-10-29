import 'package:package_info_plus/package_info_plus.dart';

class AppConstants {
  AppConstants._();

  static String _appVersion = '1.0.3';
  static int _buildNumber = 13;
  static String _packageName = 'com.ezmoov.partner';

  static String get appVersion => _appVersion;

  static int get buildNumber => _buildNumber;

  static String get packageName => _packageName;

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.ezmoov.partner';

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

    }
  }

  static double initialStandardDistanceKm = 6.0;

  static double farDriverDistanceKm = 10.0;

  static double localAddaDistanceKm = 20.0;

  static double outstationDistanceKm = 40.0;

  static int vehicleTierForwardDelaySeconds = 30;

  static void setAppVersion(String version) {
    _appVersion = version;
  }
}
