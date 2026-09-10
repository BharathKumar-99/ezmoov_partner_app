import 'package:flutter/material.dart';
import '../core/services/supabase_service.dart';
import '../models/driver_login_time_model.dart';
import '../models/driver_ride_action_model.dart';

class PerformanceViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<DriverLoginTimeModel> _loginSessions = [];
  List<DriverLoginTimeModel> get loginSessions => _loginSessions;

  List<DriverLoginTimeModel> _todaySessions = [];
  List<DriverLoginTimeModel> get todaySessions => _todaySessions;

  List<DriverRideActionModel> _rideActionsForSelectedDate = [];
  List<DriverRideActionModel> get rideActionsForSelectedDate =>
      _rideActionsForSelectedDate;

  List<DriverRideActionModel> _todayRideActions = [];
  List<DriverRideActionModel> get todayRideActions => _todayRideActions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingToday = false;
  bool get isFetchingToday => _isFetchingToday;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentDriverId = '';
  String get currentDriverId => _currentDriverId;

  int _loginDaysThisMonth = 0;
  int get loginDaysThisMonth => _loginDaysThisMonth;

  bool get isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  // ── Selected Date Stats ──

  /// Total ride requests offered on selected date
  int get totalRequestsForSelectedDate => _rideActionsForSelectedDate.length;

  /// Accepted requests count on selected date
  int get acceptedRequestsForSelectedDate =>
      _rideActionsForSelectedDate.where((a) => a.isAccepted).length;

  /// Declined / Denied requests count on selected date
  int get declinedRequestsForSelectedDate =>
      _rideActionsForSelectedDate.where((a) => a.isDeclined).length;

  /// Timeout requests count on selected date
  int get timeoutRequestsForSelectedDate =>
      _rideActionsForSelectedDate.where((a) => a.isTimeout).length;

  /// Completion Score (%) on selected date: (accepted / total) * 100
  /// If 3 accepted and 2 declined (total = 5), completion score = (3 / 5) * 100 = 60%
  double get completionScoreForSelectedDate {
    if (totalRequestsForSelectedDate == 0) return 100.0;
    final score =
        (acceptedRequestsForSelectedDate / totalRequestsForSelectedDate) * 100.0;
    return double.parse(score.toStringAsFixed(1));
  }

  /// Formatted completion score for selected date (e.g. "60%" or "100%")
  String get formattedCompletionScoreForSelectedDate {
    final score = completionScoreForSelectedDate;
    if (score == score.toInt()) {
      return '${score.toInt()}%';
    }
    return '${score.toStringAsFixed(1)}%';
  }

  // ── Today's Stats (Home Tab Quick Display) ──

  /// Total ride requests offered today
  int get todayTotalRequests => _todayRideActions.length;

  /// Accepted requests count today
  int get todayAcceptedCount =>
      _todayRideActions.where((a) => a.isAccepted).length;

  /// Declined / Denied requests count today
  int get todayDeclinedCount =>
      _todayRideActions.where((a) => a.isDeclined).length;

  /// Completion score today (%)
  double get todayCompletionScore {
    if (todayTotalRequests == 0) return 100.0;
    final score = (todayAcceptedCount / todayTotalRequests) * 100.0;
    return double.parse(score.toStringAsFixed(1));
  }

  /// Formatted completion score today (e.g. "60%" or "100%")
  String get formattedTodayCompletionScore {
    final score = todayCompletionScore;
    if (score == score.toInt()) {
      return '${score.toInt()}%';
    }
    return '${score.toStringAsFixed(1)}%';
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

  /// Fetch today's login time & completion score for Home Dashboard card
  Future<void> fetchTodayLoginTime(String driverId) async {
    if (driverId.isEmpty) return;
    _currentDriverId = driverId;
    _isFetchingToday = true;
    notifyListeners();

    try {
      final results = await _supabaseService.getTodayDriverLoginTimes(driverId);
      _todaySessions = results;

      final todayActions = await _supabaseService.getDriverRideActionsForDate(
        driverId: driverId,
        date: DateTime.now(),
      );
      _todayRideActions = todayActions;

      // If selected date is today, update selected date sessions & actions too
      if (isSelectedDateToday) {
        _loginSessions = results;
        _rideActionsForSelectedDate = todayActions;
      }
    } catch (e) {
      debugPrint('Error fetching today performance data: $e');
    } finally {
      _isFetchingToday = false;
      notifyListeners();
    }
  }

  /// Fetch the number of unique login days for the current month
  Future<void> fetchLoginDaysThisMonth(String driverId) async {
    if (driverId.isEmpty) return;
    _currentDriverId = driverId;

    try {
      _loginDaysThisMonth =
          await _supabaseService.getDriverLoginDaysCountThisMonth(driverId);
    } catch (e) {
      debugPrint('Error fetching login days this month: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Fetch login times & ride actions for a specific selected date
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

      final actions = await _supabaseService.getDriverRideActionsForDate(
        driverId: driverId,
        date: date,
      );
      _rideActionsForSelectedDate = actions;

      // If fetching today's date, also sync _todaySessions & _todayRideActions
      if (isSelectedDateToday) {
        _todaySessions = results;
        _todayRideActions = actions;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching performance data for date: $e');
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
