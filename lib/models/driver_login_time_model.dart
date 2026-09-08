import 'package:intl/intl.dart';

class DriverLoginTimeModel {
  final String id;
  final String driverId;
  final DateTime startTime;
  final DateTime? endTime;
  final String? totalTime;
  final String date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DriverLoginTimeModel({
    required this.id,
    required this.driverId,
    required this.startTime,
    this.endTime,
    this.totalTime,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOngoing => endTime == null;

  /// Calculate duration dynamically (if ongoing, from startTime to now)
  Duration get calculatedDuration {
    if (endTime != null) {
      final diff = endTime!.difference(startTime);
      return diff.isNegative ? Duration.zero : diff;
    }
    final now = DateTime.now();
    final diff = now.difference(startTime);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Formatted duration string, e.g. "2h 30m" or "45m" or "1m"
  String get formattedDuration {
    final dur = calculatedDuration;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '< 1m';
    }
  }

  /// Detailed formatted duration string, e.g. "2 hrs 30 mins"
  String get formattedDurationDetailed {
    if (totalTime != null && totalTime!.isNotEmpty && totalTime != 'Ongoing') {
      return totalTime!;
    }
    final dur = calculatedDuration;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hrs $minutes mins';
    } else if (minutes > 0) {
      return '$minutes mins';
    } else {
      return '< 1 min';
    }
  }

  /// Formatted time range, e.g. "09:30 AM - 01:15 PM" or "09:30 AM - Present"
  String get formattedTimeRange {
    final startStr = DateFormat('hh:mm a').format(startTime.toLocal());
    if (endTime != null) {
      final endStr = DateFormat('hh:mm a').format(endTime!.toLocal());
      return '$startStr - $endStr';
    }
    return '$startStr - Ongoing';
  }

  factory DriverLoginTimeModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedStart;
    try {
      parsedStart = DateTime.parse(json['start_time'] as String);
    } catch (_) {
      parsedStart = DateTime.now();
    }

    DateTime? parsedEnd;
    if (json['end_time'] != null) {
      try {
        parsedEnd = DateTime.parse(json['end_time'] as String);
      } catch (_) {
        parsedEnd = null;
      }
    }

    DateTime? parsedCreated;
    if (json['created_at'] != null) {
      try {
        parsedCreated = DateTime.parse(json['created_at'] as String);
      } catch (_) {
        parsedCreated = null;
      }
    }

    DateTime? parsedUpdated;
    if (json['updated_at'] != null) {
      try {
        parsedUpdated = DateTime.parse(json['updated_at'] as String);
      } catch (_) {
        parsedUpdated = null;
      }
    }

    return DriverLoginTimeModel(
      id: (json['id'] ?? '').toString(),
      driverId: (json['driver_id'] ?? '').toString(),
      startTime: parsedStart,
      endTime: parsedEnd,
      totalTime: json['total_time'] as String?,
      date: (json['date'] ?? DateFormat('yyyy-MM-dd').format(parsedStart)).toString(),
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime?.toUtc().toIso8601String(),
      'total_time': totalTime,
      'date': date,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }
}
