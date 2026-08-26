import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum LocationTileType {
  pickup,
  stop,
  drop,
}

class DashedLineConnector extends StatelessWidget {
  final double height;
  final Color color;

  const DashedLineConnector({
    super.key,
    this.height = 24,
    this.color = const Color(0xFFF97316),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 18, top: 4, bottom: 4),
      height: height,
      child: Column(
        children: List.generate(
          4,
          (index) => Container(
            width: 2,
            height: height / 8,
            color: index % 2 == 0 ? color : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

class RouteLocationTile extends StatelessWidget {
  final LocationTileType type;
  final String address;
  final double distanceKm;
  final String? customTitle;
  final int? stopIndex;

  const RouteLocationTile({
    super.key,
    required this.type,
    required this.address,
    required this.distanceKm,
    this.customTitle,
    this.stopIndex,
  });

  String _getDefaultTitle() {
    switch (type) {
      case LocationTileType.pickup:
        return 'PICKUP LOCATION';
      case LocationTileType.stop:
        return stopIndex != null ? 'STOP $stopIndex LOCATION' : 'INTERMEDIATE STOP';
      case LocationTileType.drop:
        return 'FINAL DROP LOCATION';
    }
  }

  String _formatAreaHeader(String fullAddress) {
    if (customTitle != null && customTitle!.isNotEmpty) {
      return customTitle!.toUpperCase();
    }
    final trimmed = fullAddress.trim();
    if (trimmed.isEmpty) return _getDefaultTitle();

    final parts = trimmed.split(',');
    if (parts.isNotEmpty) {
      final first = parts.first.trim();
      if (first.length <= 5 && parts.length > 1) {
        return '${first.toUpperCase()}, ${parts[1].trim().toUpperCase()}';
      }
      return first.toUpperCase();
    }
    return _getDefaultTitle();
  }

  @override
  Widget build(BuildContext context) {
    final areaHeader = _formatAreaHeader(address);
    final distanceText = '${distanceKm > 0 ? distanceKm.toStringAsFixed(1) : '0.0'} KM';

    Color pillBg;
    Color pillBorder;
    Color pillTextColor;
    IconData pillIcon;

    switch (type) {
      case LocationTileType.pickup:
        pillBg = const Color(0xFFECFDF5);
        pillBorder = const Color(0xFF86EFAC);
        pillTextColor = const Color(0xFF047857);
        pillIcon = Icons.circle_outlined;
        break;
      case LocationTileType.stop:
        pillBg = const Color(0xFFFEF3C7);
        pillBorder = const Color(0xFFFCD34D);
        pillTextColor = const Color(0xFFB45309);
        pillIcon = Icons.alt_route_rounded;
        break;
      case LocationTileType.drop:
        pillBg = const Color(0xFFFFF7ED);
        pillBorder = const Color(0xFFFDBA74);
        pillTextColor = const Color(0xFFC2410C);
        pillIcon = Icons.location_on_outlined;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Distance Pill + Bullet + Location Area Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Distance Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: pillBorder, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    pillIcon,
                    size: 13,
                    color: pillTextColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    distanceText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: pillTextColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Bullet separator
            const Text(
              '•',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            // Location Header Title
            Expanded(
              child: Text(
                areaHeader,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Full address text line
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            address.isNotEmpty ? address : 'Address details unavailable',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
