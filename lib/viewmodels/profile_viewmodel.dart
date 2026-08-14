import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/fcm_service.dart';
import '../models/driver_model.dart';
import '../models/vehicle_model.dart';
import '../models/document_model.dart';
import '../models/bank_details_model.dart';
import '../models/rating_model.dart';
import '../models/booking_model.dart';
import 'ride_request_viewmodel.dart';
import 'wallet_viewmodel.dart';
import '../models/wallet_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  DriverModel? _driver;
  VehicleModel? _vehicle;
  DocumentModel? _documents;
  BankDetailsModel? _bankDetails;
  List<RatingModel> _ratings = [];
  List<BookingModel> _trips = [];

  DriverModel? get driver => _driver;
  VehicleModel? get vehicle => _vehicle;
  DocumentModel? get documents => _documents;
  BankDetailsModel? get bankDetails => _bankDetails;
  List<RatingModel> get ratings => _ratings;
  List<BookingModel> get trips => _trips;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _locationTimer;

  // Driver GPS coordinates (default fallback: Bengaluru)
  double _latitude = 12.9716;
  double _longitude = 77.5946;
  double get latitude => _latitude;
  double get longitude => _longitude;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  /// Request device location permissions using Geolocator system dialog
  Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if device GPS service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'GPS Location services are disabled. Please turn on location in device settings.',
        );
      }
      return false;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show explicit permission request
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          _showSnackBar(
            context,
            'Location permission denied. GPS is required to switch online.',
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'Location permissions are permanently denied. Please enable them in app settings.',
        );
      }
      return false;
    }

    return true;
  }

  /// Load complete driver profile, ratings & trip records from Supabase
  Future<DriverModel?> fetchProfile(
    String driverIdOrPhone, [
    BuildContext? context,
  ]) async {
    _errorMessage = null;

    try {
      DriverModel? loadedDriver;
      if (driverIdOrPhone.startsWith('+') ||
          RegExp(r'^\d+$').hasMatch(driverIdOrPhone)) {
        loadedDriver = await _supabaseService.getDriverByPhone(driverIdOrPhone);
      } else {
        loadedDriver = await _supabaseService.getDriverById(driverIdOrPhone);
      }

      if (loadedDriver != null) {
        _driver = loadedDriver;
        _isOnline = loadedDriver.isOnline;
        if (loadedDriver.id != null) {
          saveSessionPhoneOrId(loadedDriver.id!);
          FcmService.instance.saveUserFcmToken(loadedDriver.id!);
        }
        if (loadedDriver.latitude != null && loadedDriver.longitude != null) {
          _latitude = loadedDriver.latitude!;
          _longitude = loadedDriver.longitude!;
        }

        // Fetch linked tables
        _vehicle = await _supabaseService.getVehicleByDriverId(
          loadedDriver.id!,
        );
        _documents = await _supabaseService.getDocumentsByDriverId(
          loadedDriver.id!,
        );
        _bankDetails = await _supabaseService.getBankDetailsByDriverId(
          loadedDriver.id!,
        );
        _ratings = await _supabaseService.getDriverRatings(loadedDriver.id!);
        _trips = await _supabaseService.getDriverTrips(loadedDriver.id!);

        if (_isOnline && context != null && context.mounted) {
          final walletVm = Provider.of<WalletViewModel>(context, listen: false);
          await walletVm.fetchWalletData(loadedDriver.id!);

          if (walletVm.isBlocked || !walletVm.isPassActive) {
            debugPrint('🚨 Daily Pass expired or driver blocked! Auto-offlining driver.');
            _isOnline = false;
            await _supabaseService.updateOnlineStatus(loadedDriver.id!, false);
            _driver = _driver?.copyWith(isOnline: false);
          }
        }

        if (_isOnline) {
          final permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            _start30SecLocationTimer();
            if (context != null && context.mounted) {
              Provider.of<RideRequestViewModel>(
                context,
                listen: false,
              ).startBroadcastListening(
                driverId: loadedDriver.id!,
                driverLat: _latitude,
                driverLng: _longitude,
                context: context,
              );
            }
          } else if (context != null && context.mounted) {
            final granted = await handleLocationPermission(context);
            if (granted) {
              _start30SecLocationTimer();
              if (context.mounted) {
                Provider.of<RideRequestViewModel>(
                  context,
                  listen: false,
                ).startBroadcastListening(
                  driverId: loadedDriver.id!,
                  driverLat: _latitude,
                  driverLng: _longitude,
                  context: context,
                );
              }
            } else {
              _isOnline = false;
              if (_driver != null && _driver!.id != null) {
                await _supabaseService.updateOnlineStatus(_driver!.id!, false);
              }
            }
          }
        } else {
          _stopLocationTimer();
          if (context != null && context.mounted) {
            Provider.of<RideRequestViewModel>(
              context,
              listen: false,
            ).stopBroadcastListening();
          }
        }
        if (loadedDriver.id != null) {
          subscribeToDriverRealtime(loadedDriver.id!, (context != null && context.mounted) ? context : null);
        }
      } else {
        _driver = null;
        _vehicle = null;
        _documents = null;
        _bankDetails = null;
        _ratings = [];
        _trips = [];
        _stopLocationTimer();
        unsubscribeDriverRealtime();
        if (context != null && context.mounted) {
          Provider.of<RideRequestViewModel>(
            context,
            listen: false,
          ).stopBroadcastListening();
        }
      }

      notifyListeners();
      return _driver;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  RealtimeChannel? _driverRealtimeChannel;
  String? _subscribedDriverId;

  /// Subscribe to Realtime postgres changes on drivers table for instant online/offline status sync
  void subscribeToDriverRealtime(String driverId, [BuildContext? context]) {
    if (driverId.isEmpty || _subscribedDriverId == driverId) return;

    unsubscribeDriverRealtime();
    _subscribedDriverId = driverId;

    try {
      debugPrint('⚡ Subscribing to Supabase Realtime for Driver Profile/Online Status: $driverId');
      _driverRealtimeChannel = _supabaseService.client
          .channel('public:driver_status:$driverId')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'drivers',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: driverId,
            ),
            callback: (payload) {
              final newRecord = payload.newRecord;
              debugPrint('⚡ Realtime Driver record update received: $newRecord');

              if (newRecord.containsKey('is_online')) {
                final newIsOnline = newRecord['is_online'] as bool? ?? false;
                if (_isOnline != newIsOnline) {
                  debugPrint('⚡ Online Status changed via Realtime: $_isOnline -> $newIsOnline');
                  _isOnline = newIsOnline;
                  _driver = _driver?.copyWith(isOnline: newIsOnline);

                  if (!newIsOnline) {
                    _stopLocationTimer();
                    if (context != null && context.mounted) {
                      Provider.of<RideRequestViewModel>(context, listen: false).stopBroadcastListening();
                    }
                  } else if (newIsOnline) {
                    _start30SecLocationTimer();
                    if (context != null && context.mounted) {
                      Provider.of<RideRequestViewModel>(context, listen: false).startBroadcastListening(
                        driverId: driverId,
                        driverLat: _latitude,
                        driverLng: _longitude,
                        context: context,
                      );
                    }
                  }
                  notifyListeners();
                }
              }
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Notice establishing realtime driver subscription: $e');
    }
  }

  void unsubscribeDriverRealtime() {
    if (_driverRealtimeChannel != null) {
      _supabaseService.client.removeChannel(_driverRealtimeChannel!);
      _driverRealtimeChannel = null;
      _subscribedDriverId = null;
    }
  }

  bool _isTogglingOnline = false;
  bool get isTogglingOnline => _isTogglingOnline;

  /// Direct setter for driver profile (used during auth/onboarding)
  void updateDriverLocal(DriverModel driverModel) {
    _driver = driverModel;
    _isOnline = driverModel.isOnline;
    notifyListeners();
  }

  double _getDailyFeeForVehicleName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('2') || lower.contains('two') || lower.contains('bike')) {
      return 100.0;
    } else if (lower.contains('mini 3w') || lower.contains('3 wheel') || lower.contains('3w') || lower.contains('rickshaw')) {
      return 175.0;
    } else if (lower.contains('7ft') || lower.contains('7 feet') || lower.contains('tata ace') || lower.contains('ace')) {
      return 200.0;
    } else if (lower.contains('8ft') || lower.contains('8 feet') || lower.contains('pickup 8')) {
      return 250.0;
    } else if (lower.contains('9') || lower.contains('10') || lower.contains('9-10ft')) {
      return 270.0;
    } else if (lower.contains('14') || lower.contains('16') || lower.contains('17') || lower.contains('container')) {
      return 300.0;
    }
    return 100.0;
  }

  /// Toggle online status in Supabase and handle 30s location timer after checking location permissions & wallet daily fee block
  Future<void> toggleOnlineStatus(bool value, BuildContext context) async {
    if (_driver == null || _driver!.id == null) return;
    if (_isTogglingOnline) return;

    _isTogglingOnline = true;
    notifyListeners();

    final previousStatus = _isOnline;

    try {
      if (value) {
        // Fast parallel fetch for daily status, wallet, and vehicle
        final results = await Future.wait([
          _supabaseService.getDriverDailyStatus(_driver!.id!),
          _supabaseService.getDriverWallet(_driver!.id!),
          _supabaseService.getVehicleByDriverId(_driver!.id!),
        ]);

        final dailyStatus = results[0] as DriverDailyStatusModel?;
        final wallet = results[1] as DriverWalletModel?;
        final vehicle = results[2] as VehicleModel?;

        final vehicleType = vehicle?.vehicleType ?? '2 Wheeler';
        final vehicleDailyFee = _getDailyFeeForVehicleName(vehicleType);
        final walletBalance = wallet?.balance ?? 0.0;

        final isRejectionBlock = (dailyStatus?.rejectionsCount ?? 0) >= 2 || dailyStatus?.blockReason == 'exceeded_rejections';
        final isPassActive = dailyStatus?.isPassActive ?? false;

        if (isRejectionBlock || !isPassActive || dailyStatus?.isBlocked == true) {
          _isOnline = false;
          await _supabaseService.updateOnlineStatus(_driver!.id!, false);

          if (context.mounted) {
            final title = isRejectionBlock ? 'Orders Paused ⛔' : 'Daily Pass Required ⚠️';
            final message = isRejectionBlock
                ? 'You have rejected 2 orders today. Order allocation is paused for the remainder of today and will resume tomorrow.'
                : 'Your 24-hour daily pass is expired or unpaid. You must pay your daily fee (₹${vehicleDailyFee.toStringAsFixed(0)}) to go online for the next 24 hours.';

            showDialog(
              context: context,
              builder: (dialogCtx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                content: Text(message),
                actions: [
                  if (!isRejectionBlock) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF09A234),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        context.read<WalletViewModel>().payDailyFee(driverId: _driver!.id!, context: context);
                      },
                      icon: const Icon(Icons.flash_on_rounded, size: 16, color: Colors.white),
                      label: Text('Pay Daily Fee (₹${vehicleDailyFee.toStringAsFixed(0)})', style: const TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        context.push('/wallet?driverId=${_driver!.id!}');
                      },
                      child: const Text('View Wallet', style: TextStyle(color: Color(0xFF09A234))),
                    ),
                  ],
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            );
          }
          _isTogglingOnline = false;
          notifyListeners();
          return;
        }

        // Prompt for location permission before going online
        if (!context.mounted) return;
        final hasPermission = await handleLocationPermission(context);
        if (!hasPermission) {
          _isOnline = false;
          return;
        }
      }

      _isOnline = value;
      await _supabaseService.updateOnlineStatus(_driver!.id!, value);

      if (value) {
        // Fetch initial GPS position
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          _latitude = position.latitude;
          _longitude = position.longitude;
        } catch (e) {
          debugPrint('Notice fetching initial position: $e');
        }

        await _supabaseService.updateDriverLocation(
          _driver!.id!,
          _latitude,
          _longitude,
        );
        _start30SecLocationTimer();

        if (context.mounted) {
          Provider.of<RideRequestViewModel>(
            context,
            listen: false,
          ).startBroadcastListening(
            driverId: _driver!.id!,
            driverLat: _latitude,
            driverLng: _longitude,
            context: context,
          );
        }
      } else {
        _stopLocationTimer();
        if (context.mounted) {
          Provider.of<RideRequestViewModel>(
            context,
            listen: false,
          ).stopBroadcastListening();
        }
      }

      _driver = _driver!.copyWith(isOnline: value);

      if (context.mounted) {
        _showSnackBar(
          context,
          value ? 'You are now ONLINE' : 'You are now OFFLINE',
        );
      }
    } catch (e) {
      _isOnline = previousStatus;
      if (!previousStatus) {
        _stopLocationTimer();
        if (context.mounted) {
          Provider.of<RideRequestViewModel>(
            context,
            listen: false,
          ).stopBroadcastListening();
        }
      }
      if (context.mounted) {
        _showSnackBar(context, 'Failed to update online status: $e');
      }
    } finally {
      _isTogglingOnline = false;
      notifyListeners();
    }
  }

  bool _isTripActive = false;
  bool get isTripActive => _isTripActive;

  /// Set whether driver is in an active trip flow and update location timer interval
  void setTripActive(bool active, [BuildContext? context]) {
    _isTripActive = active;
    _stopLocationTimer();
    if (_isOnline) {
      startLocationTimer(context: context);
    }
  }

  /// Start Periodic Location Timer when Driver is Online
  /// Uses 5-second interval during active booking flow, and 30-second interval when idle.
  void startLocationTimer({BuildContext? context}) async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint(
        '🛑 Location permission not granted. Skipping location timer start.',
      );
      return;
    }

    if (_locationTimer != null && _locationTimer!.isActive) {
      _locationTimer!.cancel();
      _locationTimer = null;
    }

    final int intervalSec = _isTripActive ? 5 : 30;
    debugPrint(
      '⚡ Starting $intervalSec-second periodic GPS location updates for driver (Trip Active: $_isTripActive)...',
    );

    _locationTimer =
        Timer.periodic(Duration(seconds: intervalSec), (timer) async {
      if (_driver != null && _driver!.id != null && _isOnline) {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          _latitude = position.latitude;
          _longitude = position.longitude;

          await _supabaseService.updateDriverLocation(
            _driver!.id!,
            _latitude,
            _longitude,
          );
          debugPrint(
            '📍 Updated driver GPS location to: ($_latitude, $_longitude) [$intervalSec s]',
          );

          notifyListeners();
        } catch (e) {
          debugPrint('Notice in $intervalSec s location update: $e');
        }
      } else {
        _stopLocationTimer();
      }
    });
  }

  void _start30SecLocationTimer() {
    startLocationTimer();
  }

  /// Stop location timer
  void _stopLocationTimer() {
    if (_locationTimer != null && _locationTimer!.isActive) {
      _locationTimer!.cancel();
      _locationTimer = null;
      debugPrint('🛑 Location timer stopped.');
    }
  }

  /// Clear profile data, remove stored session, sign out Supabase auth & cancel location timer on logout
  Future<void> clearProfileAndLogout(BuildContext context) async {
    _stopLocationTimer();
    if (context.mounted) {
      Provider.of<RideRequestViewModel>(
        context,
        listen: false,
      ).stopBroadcastListening();
    }
    _driver = null;
    _vehicle = null;
    _documents = null;
    _bankDetails = null;
    _ratings = [];
    _trips = [];
    _isOnline = false;

    // Clear persisted SharedPreferences session
    await clearSession();

    // Sign out from Supabase Auth
    try {
      await _supabaseService.client.auth.signOut();
    } catch (e) {
      debugPrint('Notice signing out Supabase auth: $e');
    }

    notifyListeners();

    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<void> saveSessionPhoneOrId(String val) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_driver_session', val);
    } catch (e) {
      debugPrint('Notice saving driver session: $e');
    }
  }

  Future<String?> getSavedSessionPhoneOrId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('saved_driver_session');
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_driver_session');
    } catch (e) {
      debugPrint('Notice clearing session: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _isOnline ? const Color(0xFF09A234) : Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _stopLocationTimer();
    unsubscribeDriverRealtime();
    super.dispose();
  }
}
