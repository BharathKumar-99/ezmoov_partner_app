import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

class InAppUpdateService {
  InAppUpdateService._privateConstructor();
  static final InAppUpdateService instance = InAppUpdateService._privateConstructor();

  bool _isChecking = false;
  AppUpdateInfo? _updateInfo;
  AppUpdateInfo? get updateInfo => _updateInfo;

  Future<bool> checkForUpdateAndPerform({
    bool forceImmediate = true,
    BuildContext? context,
  }) async {

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      debugPrint('ℹ️ InAppUpdate: Skipped (platform is not Android)');
      return false;
    }

    if (_isChecking) {
      debugPrint('ℹ️ InAppUpdate: Check already in progress...');
      return false;
    }

    _isChecking = true;

    try {
      debugPrint('🔍 InAppUpdate: Checking Google Play Store for new version...');
      final info = await InAppUpdate.checkForUpdate();
      _updateInfo = info;

      debugPrint('📦 InAppUpdate Info: availability=${info.updateAvailability}, '
          'immediateAllowed=${info.immediateUpdateAllowed}, '
          'flexibleAllowed=${info.flexibleUpdateAllowed}, '
          'availableVersionCode=${info.availableVersionCode}');

      if (info.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress) {
        debugPrint('🚀 InAppUpdate: Resuming in-progress immediate update...');
        final result = await InAppUpdate.performImmediateUpdate();
        return result == AppUpdateResult.success;
      }

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (forceImmediate && info.immediateUpdateAllowed) {
          debugPrint('🚀 InAppUpdate: Starting immediate update flow...');
          final result = await InAppUpdate.performImmediateUpdate();
          debugPrint('🚀 InAppUpdate: Immediate update result: $result');
          return result == AppUpdateResult.success;
        } else if (info.flexibleUpdateAllowed) {
          debugPrint('📥 InAppUpdate: Starting flexible background update...');
          await InAppUpdate.startFlexibleUpdate();
          debugPrint('✅ InAppUpdate: Flexible update downloaded, completing update...');
          await InAppUpdate.completeFlexibleUpdate();
          return true;
        } else if (info.immediateUpdateAllowed) {
          debugPrint('🚀 InAppUpdate: Fallback starting immediate update flow...');
          final result = await InAppUpdate.performImmediateUpdate();
          return result == AppUpdateResult.success;
        }
      } else {
        debugPrint('✅ InAppUpdate: App is up to date.');
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('-10') || errorStr.contains('ERROR_APP_NOT_OWNED')) {
        debugPrint(
          'ℹ️ InAppUpdate: App was installed via sideload / debug (not directly from Play Store). '
          'In-App updates will activate automatically on builds downloaded from Google Play Store.',
        );
      } else {
        debugPrint('⚠️ InAppUpdate notice: $e');
      }
    } finally {
      _isChecking = false;
    }

    return false;
  }

  Future<void> openPlayStore([BuildContext? context, String? customUrl]) async {
    final targetUrl = customUrl != null && customUrl.isNotEmpty
        ? customUrl
        : AppConstants.playStoreUrl;

    try {

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final marketUri = Uri.parse('market://details?id=${AppConstants.packageName}');
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      final webUri = Uri.parse(targetUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not open Google Play Store. Please search for EZMoov Partner in the Play Store.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching Play Store URL: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Play Store: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
