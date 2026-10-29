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

  int get totalRequestsForSelectedDate => _rideActionsForSelectedDate.length;

  int get acceptedRequestsForSelectedDate =>
      _rideActionsForSelectedDate.where((a) => a.isAccepted).length;

  int get declinedRequestsForSelectedDate =>
      _rideActionsForSelectedDate.where((a) => a.isDeclined).length;

  int get timeoutRequestsForSelectedDate =>
      _rideActionsForSelectedDate.where((a) => a.isTimeout).length;

  double get completionScoreForSelectedDate {
    if (totalRequestsForSelectedDate == 0) return 100.0;
    final score =
        (acceptedRequestsForSelectedDate / totalRequestsForSelectedDate) * 100.0;
    return double.parse(score.toStringAsFixed(1));
  }

  String get formattedCompletionScoreForSelectedDate {
    final score = completionScoreForSelectedDate;
    if (score == score.toInt()) {
      return '${score.toInt()}%';
    }
    return '${score.toStringAsFixed(1)}%';
  }

  int get todayTotalRequests => _todayRideActions.length;

  int get todayAcceptedCount =>
      _todayRideActions.where((a) => a.isAccepted).length;

  int get todayDeclinedCount =>
      _todayRideActions.where((a) => a.isDeclined).length;

  double get todayCompletionScore {
    if (todayTotalRequests == 0) return 100.0;
    final score = (todayAcceptedCount / todayTotalRequests) * 100.0;
    return double.parse(score.toStringAsFixed(1));
  }

  String get formattedTodayCompletionScore {
    final score = todayCompletionScore;
    if (score == score.toInt()) {
      return '${score.toInt()}%';
    }
    return '${score.toStringAsFixed(1)}%';
  }

  Duration get totalLoginDurationForSelectedDate {
    Duration sum = Duration.zero;
    for (final session in _loginSessions) {
      sum += session.calculatedDuration;
    }
    return sum;
  }

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

  Duration get totalTodayLoginDuration {
    Duration sum = Duration.zero;
    for (final session in _todaySessions) {
      sum += session.calculatedDuration;
    }
    return sum;
  }

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

  void selectDate(DateTime newDate, String driverId) {
    _selectedDate = newDate;
    fetchLoginTimesForDate(driverId, newDate);
  }

  void goToPreviousDay(String driverId) {
    final prev = _selectedDate.subtract(const Duration(days: 1));
    selectDate(prev, driverId);
  }

  void goToNextDay(String driverId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = _selectedDate.add(const Duration(days: 1));
    final targetDateOnly = DateTime(target.year, target.month, target.day);

    if (targetDateOnly.isAfter(today)) return;
    selectDate(target, driverId);
  }
}
