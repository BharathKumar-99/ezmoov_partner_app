import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/services/supabase_service.dart';
import '../models/driver_model.dart';
import '../models/vehicle_model.dart';
import '../models/document_model.dart';
import '../models/bank_details_model.dart';
import '../models/rating_model.dart';
import '../models/booking_model.dart';
import 'ride_request_viewmodel.dart';

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
      } else {
        _driver = null;
        _vehicle = null;
        _documents = null;
        _bankDetails = null;
        _ratings = [];
        _trips = [];
        _stopLocationTimer();
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

  /// Direct setter for driver profile (used during auth/onboarding)
  void updateDriverLocal(DriverModel driverModel) {
    _driver = driverModel;
    _isOnline = driverModel.isOnline;
    notifyListeners();
  }

  /// Toggle online status in Supabase and handle 30s location timer after checking location permissions
  Future<void> toggleOnlineStatus(bool value, BuildContext context) async {
    if (_driver == null || _driver!.id == null) return;

    if (value) {
      // 1. Explicitly prompt for location permission before going online
      final hasPermission = await handleLocationPermission(context);
      if (!hasPermission) {
        _isOnline = false;
        notifyListeners();
        return;
      }
    }

    final previousStatus = _isOnline;
    _isOnline = value;
    notifyListeners();

    try {
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
      notifyListeners();

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
      notifyListeners();
      if (context.mounted) {
        _showSnackBar(context, 'Failed to update online status: $e');
      }
    }
  }

  /// Start 30-Second Periodic Location Timer when Driver is Online
  void _start30SecLocationTimer() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint(
        '🛑 Location permission not granted. Skipping location timer start.',
      );
      return;
    }

    if (_locationTimer != null && _locationTimer!.isActive) {
      return;
    }

    debugPrint(
      '⚡ Starting 30-second periodic GPS location updates for driver...',
    );

    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
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
            '📍 Updated driver GPS location to: ($_latitude, $_longitude)',
          );
          notifyListeners();
        } catch (e) {
          debugPrint('Notice in 30s location update: $e');
        }
      } else {
        _stopLocationTimer();
      }
    });
  }

  /// Stop location timer
  void _stopLocationTimer() {
    if (_locationTimer != null && _locationTimer!.isActive) {
      _locationTimer!.cancel();
      _locationTimer = null;
      debugPrint('🛑 30-second location timer stopped.');
    }
  }

  /// Clear profile data and cancel location timer on logout
  void clearProfileAndLogout(BuildContext context) {
    _stopLocationTimer();
    Provider.of<RideRequestViewModel>(
      context,
      listen: false,
    ).stopBroadcastListening();
    _driver = null;
    _vehicle = null;
    _documents = null;
    _bankDetails = null;
    _ratings = [];
    _trips = [];
    _isOnline = false;
    notifyListeners();
    context.go('/login');
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
    super.dispose();
  }
}
