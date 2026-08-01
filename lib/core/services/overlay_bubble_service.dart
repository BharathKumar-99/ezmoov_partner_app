import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayBubbleService {
  OverlayBubbleService._privateConstructor();
  static final OverlayBubbleService instance = OverlayBubbleService._privateConstructor();

  bool _isBubbleActive = false;
  bool get isBubbleActive => _isBubbleActive;

  /// Check and request System Alert Window (Draw Over Other Apps) permission
  Future<bool> checkPermission() async {
    try {
      final isGranted = await FlutterOverlayWindow.isPermissionGranted();
      if (!isGranted) {
        final granted = await FlutterOverlayWindow.requestPermission();
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Notice checking overlay permission: $e');
      return false;
    }
  }

  /// Show floating system bubble on home screen when driver is ONLINE
  Future<void> showFloatingBubble({
    String statusText = 'ONLINE',
  }) async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        debugPrint('⚠️ Overlay window permission not granted.');
        return;
      }

      final isActive = await FlutterOverlayWindow.isActive();
      if (!isActive) {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: 'EZMoov Partner',
          overlayContent: statusText,
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
          height: 220,
          width: 220,
        );
        _isBubbleActive = true;
        debugPrint('🟢 Floating Overlay Bubble displayed on home screen.');
      }
    } catch (e) {
      debugPrint('Notice showing floating overlay bubble: $e');
    }
  }


  /// Hide and close floating system bubble when driver goes OFFLINE
  Future<void> closeFloatingBubble() async {
    try {
      final isActive = await FlutterOverlayWindow.isActive();
      if (isActive) {
        await FlutterOverlayWindow.closeOverlay();
        _isBubbleActive = false;
        debugPrint('🔴 Floating Overlay Bubble closed.');
      }
    } catch (e) {
      debugPrint('Notice closing floating overlay bubble: $e');
    }
  }
}
