import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

/// Reusable Waiting Time Widget displayed when driver arrives at location
class WaitingTimeWidget extends StatefulWidget {
  final String type;
  final String rateText;
  final int graceMins;
  final int? pickupWaitSeconds;
  final DateTime? arrivedAtPickup;
  final DateTime? arrivedAtDropOff;

  const WaitingTimeWidget({
    super.key,
    required this.type,
    this.rateText = '₹ 4.0/min after 90 minutes',
    this.graceMins = 90,
    this.pickupWaitSeconds,
    this.arrivedAtPickup,
    this.arrivedAtDropOff,
  });

  @override
  State<WaitingTimeWidget> createState() => _WaitingTimeWidgetState();
}

class _WaitingTimeWidgetState extends State<WaitingTimeWidget> {
  Timer? _timer;
  int _currentSeconds = 0;
  DateTime? _localPickupStart;
  DateTime? _localDropOffStart;

  @override
  void initState() {
    super.initState();
    _localPickupStart = widget.arrivedAtPickup ?? DateTime.now();
    _localDropOffStart = widget.arrivedAtDropOff ?? DateTime.now();
    _updateTime();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  @override
  void didUpdateWidget(WaitingTimeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.arrivedAtPickup != widget.arrivedAtPickup &&
        widget.arrivedAtPickup != null) {
      _localPickupStart = widget.arrivedAtPickup;
    }
    if (oldWidget.arrivedAtDropOff != widget.arrivedAtDropOff &&
        widget.arrivedAtDropOff != null) {
      _localDropOffStart = widget.arrivedAtDropOff;
    }
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final typeLower = widget.type.toLowerCase();
    final now = DateTime.now();
    int computedSecs = 0;

    if (typeLower == 'arrived_at_pickup' ||
        typeLower == 'arrived' ||
        typeLower == 'arrived_pickup') {
      final pickupStart = widget.arrivedAtPickup ?? _localPickupStart ?? now;
      computedSecs = now.difference(pickupStart).inSeconds;
    } else if (typeLower == 'arrived_at_drop_off' ||
        typeLower == 'arrived_at_dropoff' ||
        typeLower == 'arrived_at_drop' ||
        typeLower == 'arrived_dropoff' ||
        typeLower == 'arrived_destination') {
      final dropStart = widget.arrivedAtDropOff ?? _localDropOffStart ?? now;
      final dropSecs = now.difference(dropStart).inSeconds;
      final pWait = widget.pickupWaitSeconds ?? 0;
      computedSecs = dropSecs + pWait;
    } else {
      final pStart = widget.arrivedAtPickup ?? _localPickupStart ?? now;
      computedSecs = now.difference(pStart).inSeconds;
    }

    if (mounted) {
      setState(() {
        _currentSeconds = computedSecs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int displaySecs = _currentSeconds;
    int mins = displaySecs ~/ 60;
    int secs = displaySecs % 60;
    String minStr = mins.toString().padLeft(2, '0');
    String secStr = secs.toString().padLeft(2, '0');

    // Calculate progress ratio based on graceMins
    double calcProgress =
        (displaySecs / ((widget.graceMins > 0 ? widget.graceMins : 90) * 60))
            .clamp(0.05, 1.0);

    final l10n = AppLocalizations.of(context);
    final waitingTitle = l10n?.waitingTime ?? 'Waiting Time';
    final minLabel = l10n?.minShort ?? 'MIN';
    final secLabel = l10n?.secShort ?? 'SEC';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon + Waiting Time Title
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD1FAE5).withValues(alpha: 0.6),
                      border: Border.all(
                        color: const Color(0xFFA7F3D0),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.access_time_filled_rounded,
                          color: Color(0xFF059669),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    waitingTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),

              // Timer Display (Big Green Numbers + MIN SEC Subtitles)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$minStr : $secStr',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF059669),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          minLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          secLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Green Progress Bar Line
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: calcProgress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF059669),
              ),
              minHeight: 3.5,
            ),
          ),
          const SizedBox(height: 12),

          // Subtext Rate Info
          Text(
            widget.rateText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
