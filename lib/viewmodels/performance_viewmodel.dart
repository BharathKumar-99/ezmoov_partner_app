import 'package:flutter/material.dart';
import '../core/services/supabase_service.dart';
import '../models/driver_login_time_model.dart';

class PerformanceViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<DriverLoginTimeModel> _loginSessions = [];
  List<DriverLoginTimeModel> get loginSessions => _loginSessions;

  List<DriverLoginTimeModel> _todaySessions = [];
  List<DriverLoginTimeModel> get todaySessions => _todaySessions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingToday = false;
  bool get isFetchingToday => _isFetchingToday;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentDriverId = '';
  String get currentDriverId => _currentDriverId;

  bool get isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  /// Total duration for selected date
  Duration get totalLoginDurationForSelectedDate {
    Duration sum = Duration.zero;
    for (final session in _loginSessions) {
      sum += session.calculatedDuration;
    }
    return sum;
  }

  /// Formatted total time string for selected date (e.g. "4 hrs 15 mins" or "35 mins" or "0 mins")
  String get formattedTotalHoursForSelectedDate {
    final dur = totalLoginDurationForSelectedDate;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours hrs $minutes mins';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? "hr" : "hrs"}';
    } else if (minutes > 0) {
      return '$minutes ${minutes == 1 ? "min" : "mins"}';
    } else {
      return '0 mins';
    }
  }

  /// Total duration today
  Duration get totalTodayLoginDuration {
    Duration sum = Duration.zero;
    for (final session in _todaySessions) {
      sum += session.calculatedDuration;
    }
    return sum;
  }

  /// Formatted today login hours for quick stat display (e.g. "4h 15m" or "30m" or "0h 0m")
  String get formattedTodayLoginHoursShort {
    final dur = totalTodayLoginDuration;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0h 0m';
    }
  }

  /// Formatted today login hours (detailed, e.g. "4 hrs 15 mins" or "0 mins")
  String get formattedTodayLoginHoursDetailed {
    final dur = totalTodayLoginDuration;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours hrs $minutes mins';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? "hr" : "hrs"}';
    } else if (minutes > 0) {
      return '$minutes ${minutes == 1 ? "min" : "mins"}';
    } else {
      return '0 mins';
    }
  }

  /// Fetch today's login time for Home Dashboard card
  Future<void> fetchTodayLoginTime(String driverId) async {
    if (driverId.isEmpty) return;
    _currentDriverId = driverId;
    _isFetchingToday = true;
    notifyListeners();

    try {
      final results = await _supabaseService.getTodayDriverLoginTimes(driverId);
      _todaySessions = results;

      // If selected date is today, update loginSessions too
      if (isSelectedDateToday) {
        _loginSessions = results;
      }
    } catch (e) {
      debugPrint('Error fetching today login time: $e');
    } finally {
      _isFetchingToday = false;
      notifyListeners();
    }
  }

  /// Fetch login times for a specific selected date
  Future<void> fetchLoginTimesForDate(String driverId, DateTime date) async {
    if (driverId.isEmpty) return;
    _currentDriverId = driverId;
    _selectedDate = date;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _supabaseService.getDriverLoginTimes(
        driverId: driverId,
        date: date,
      );
      _loginSessions = results;

      // If fetching today's date, also sync _todaySessions
      if (isSelectedDateToday) {
        _todaySessions = results;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching login times for date: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User selects a new date
  void selectDate(DateTime newDate, String driverId) {
    _selectedDate = newDate;
    fetchLoginTimesForDate(driverId, newDate);
  }

  /// Navigate to previous day
  void goToPreviousDay(String driverId) {
    final prev = _selectedDate.subtract(const Duration(days: 1));
    selectDate(prev, driverId);
  }

  /// Navigate to next day (cannot go into the future)
  void goToNextDay(String driverId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = _selectedDate.add(const Duration(days: 1));
    final targetDateOnly = DateTime(target.year, target.month, target.day);

    if (targetDateOnly.isAfter(today)) return;
    selectDate(target, driverId);
  }
}
