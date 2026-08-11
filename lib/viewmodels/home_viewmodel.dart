import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/supabase_service.dart';
import '../core/services/location_service.dart';
import '../core/services/background_service_manager.dart';
import '../core/services/overlay_bubble_service.dart';
import '../models/driver_model.dart';
import 'profile_viewmodel.dart';


import '../models/vehicle_model.dart';
import '../models/document_model.dart';
import '../models/bank_details_model.dart';
import '../models/booking_model.dart';
import '../models/earning_model.dart';


class HomeViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final LocationService _locationService = LocationService.instance;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  DriverModel? _driver;
  VehicleModel? _vehicle;
  DocumentModel? _documents;
  BankDetailsModel? _bankDetails;

  DriverModel? get driver => _driver;
  VehicleModel? get vehicle => _vehicle;
  DocumentModel? get documents => _documents;
  BankDetailsModel? get bankDetails => _bankDetails;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double _latitude = 12.9716;
  double _longitude = 77.5946;
  double get latitude => _latitude;
  double get longitude => _longitude;

  // Earnings & Payout State
  List<BookingModel> _driverTrips = [];
  List<BookingModel> get driverTrips => _driverTrips;

  List<EarningModel> _driverEarnings = [];
  List<EarningModel> get driverEarnings => _driverEarnings;

  String _earningsFilter = 'week'; // 'today', 'week', 'all'
  String get earningsFilter => _earningsFilter;

  double _totalWithdrawnAmount = 0.0;
  double get totalWithdrawnAmount => _totalWithdrawnAmount;

  bool _isFetchingEarnings = false;
  bool get isFetchingEarnings => _isFetchingEarnings;

  bool _isProcessingPayout = false;
  bool get isProcessingPayout => _isProcessingPayout;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void setEarningsFilter(String filter) {
    _earningsFilter = filter;
    notifyListeners();
  }

  Future<void> loadDashboard(String driverId) async {
    setLoading(true);
    _errorMessage = null;

    try {
      _driver = await _supabaseService.getDriverById(driverId);
      if (_driver != null) {
        _isOnline = _driver!.isOnline;
        _vehicle = await _supabaseService.getVehicleByDriverId(driverId);
        _documents = await _supabaseService.getDocumentsByDriverId(driverId);
        _bankDetails = await _supabaseService.getBankDetailsByDriverId(driverId);
      }
      await fetchEarnings(driverId);
      setLoading(false);
    } catch (e) {
      setLoading(false);
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchEarnings(String driverId) async {
    if (driverId.isEmpty) return;
    _isFetchingEarnings = true;
    notifyListeners();

    try {
      final trips = await _supabaseService.getDriverTrips(driverId);
      final earnings = await _supabaseService.getDriverEarnings(driverId);
      final payouts = await _supabaseService.getDriverPayouts(driverId);

      _driverTrips = trips;
      _driverEarnings = earnings;

      double withdrawnSum = 0.0;
      for (final payout in payouts) {
        withdrawnSum += (payout['amount'] as num?)?.toDouble() ?? 0.0;
      }
      _totalWithdrawnAmount = withdrawnSum;

      _isFetchingEarnings = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Notice fetching earnings: $e');
      _isFetchingEarnings = false;
      notifyListeners();
    }
  }

  /// Get completed trips filtered by time window
  List<BookingModel> get filteredCompletedTrips {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(const Duration(days: 7));

    return _driverTrips.where((trip) {
      final isCompleted = trip.status == 'completed';
      if (!isCompleted) return false;

      final createdAt = trip.createdAt ?? now;

      if (_earningsFilter == 'today') {
        return createdAt.isAfter(todayStart);
      } else if (_earningsFilter == 'week') {
        return createdAt.isAfter(weekStart);
      }
      return true; // 'all'
    }).toList();
  }

  /// Get driver earnings filtered by time window from public.earning
  List<EarningModel> get filteredEarnings {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(const Duration(days: 7));

    return _driverEarnings.where((item) {
      final createdAt = item.createdAt ?? now;

      if (_earningsFilter == 'today') {
        return createdAt.isAfter(todayStart);
      } else if (_earningsFilter == 'week') {
        return createdAt.isAfter(weekStart);
      }
      return true; // 'all'
    }).toList();
  }

  /// Total earnings calculated by adding up driver_earning from public.earning table
  double get totalEarnings {
    if (_driverEarnings.isNotEmpty) {
      double sum = 0.0;
      for (final item in filteredEarnings) {
        sum += item.driverEarning;
      }
      return sum;
    }

    // Fallback if public.earning table is empty
    double sum = 0.0;
    for (final trip in filteredCompletedTrips) {
      sum += trip.fare;
    }
    return sum;
  }

  /// Base trip fares portion (85%)
  double get tripFaresTotal => totalEarnings * 0.85;

  /// Surge & Incentives portion (15%)
  double get bonusesTotal => totalEarnings * 0.15;

  /// Available balance for withdrawal
  double get availableBalance {
    double netAllTime = 0.0;
    if (_driverEarnings.isNotEmpty) {
      for (final item in _driverEarnings) {
        netAllTime += item.driverEarning;
      }
    } else {
      netAllTime = _driverTrips
          .where((t) => t.status == 'completed')
          .fold(0.0, (prev, t) => prev + t.fare);
    }
    final avail = netAllTime - _totalWithdrawnAmount;
    return avail > 0 ? avail : 0.0;
  }


  /// Process instant bank payout withdrawal
  Future<bool> processInstantPayout({
    required String driverId,
    required double amount,
    required BuildContext context,
  }) async {
    if (_isProcessingPayout) return false;

    _isProcessingPayout = true;
    notifyListeners();

    try {
      final bankName = _bankDetails?.bankName ?? 'Connected Bank';
      final accNumber = _bankDetails?.accountNumber ?? 'Account';

      await _supabaseService.saveDriverPayout(
        driverId: driverId,
        amount: amount,
        bankName: bankName,
        accountNumber: accNumber,
      );

      _totalWithdrawnAmount += amount;
      _isProcessingPayout = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessingPayout = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleOnlineStatus(bool value, BuildContext context) async {
    if (_driver == null || _driver!.id == null) return;

    final previousStatus = _isOnline;
    _isOnline = value;
    notifyListeners();

    try {
      await _supabaseService.updateOnlineStatus(_driver!.id!, value);
      if (value) {
        _locationService.startLocationTracking(
          driverId: _driver!.id!,
          onLocationChanged: (lat, lng) {
            _latitude = lat;
            _longitude = lng;
            notifyListeners();
          },
        );
        await BackgroundServiceManager.instance.startBackgroundService();
        await OverlayBubbleService.instance.showFloatingBubble();
      } else {
        _locationService.stopLocationTracking();
        await BackgroundServiceManager.instance.stopBackgroundService();
        await OverlayBubbleService.instance.closeFloatingBubble();
      }
      _driver = _driver!.copyWith(isOnline: value);
      if (context.mounted) {
        _showSnackBar(context, value ? 'You are now ONLINE' : 'You are now OFFLINE');
      }
    } catch (e) {
      _isOnline = previousStatus;
      notifyListeners();
      if (context.mounted) {
        _showSnackBar(context, 'Failed to update online status: $e');
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    _locationService.stopLocationTracking();
    await BackgroundServiceManager.instance.stopBackgroundService();
    await OverlayBubbleService.instance.closeFloatingBubble();
    _driver = null;
    _vehicle = null;
    _documents = null;
    _bankDetails = null;
    _driverTrips = [];
    _totalWithdrawnAmount = 0.0;
    _isOnline = false;
    _currentTabIndex = 0;
    if (context.mounted) {
      await Provider.of<ProfileViewModel>(context, listen: false).clearProfileAndLogout(context);
    }
  }



  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _isOnline ? const Color(0xFF09A234) : Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
