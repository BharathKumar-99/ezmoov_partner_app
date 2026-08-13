import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/wallet_model.dart';
import '../models/vehicle_type_model.dart';

class WalletViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  DriverWalletModel? _wallet;
  DriverWalletModel? get wallet => _wallet;

  DriverDailyStatusModel? _dailyStatus;
  DriverDailyStatusModel? get dailyStatus => _dailyStatus;

  List<WalletTransactionModel> _transactions = [];
  List<WalletTransactionModel> get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRecharging = false;
  bool get isRecharging => _isRecharging;

  double _vehicleDailyFee = 100.0;
  double get vehicleDailyFee => _vehicleDailyFee;

  String _vehicleTypeName = '2 Wheeler';
  String get vehicleTypeName => _vehicleTypeName;

  double _totalEarningsAllTime = 0.0;
  double get totalEarningsAllTime => _totalEarningsAllTime;

  double _totalDeductionsAllTime = 0.0;
  double get totalDeductionsAllTime => _totalDeductionsAllTime;

  double _totalSettled = 0.0;
  double get totalSettled => _totalSettled;

  double _lastSettlementAmount = 0.0;
  double get lastSettlementAmount => _lastSettlementAmount;

  String _lastSettlementDate = 'No payouts';
  String get lastSettlementDate => _lastSettlementDate;

  double get pendingSettlement => _wallet?.balance ?? 0.0;

  String get nextSettlementDate {
    final now = DateTime.now();
    final daysUntilSunday = DateTime.sunday - now.weekday;
    final nextSunday = now.add(Duration(
        days: daysUntilSunday <= 0 ? daysUntilSunday + 7 : daysUntilSunday));
    return DateFormat('MMM dd').format(nextSunday);
  }

  int get platformCommissionPercent => 10;

  /// Driver is blocked if explicitly blocked in daily status, or if 2 rejections reached, or if daily fee is unpaid and wallet balance is below fee
  bool get isBlocked {
    if (_dailyStatus?.isBlocked == true) return true;
    if (_dailyStatus == null || _dailyStatus!.feeDeducted == false) {
      if ((_wallet?.balance ?? 0.0) < _vehicleDailyFee) {
        return true;
      }
    }
    if ((_dailyStatus?.rejectionsCount ?? 0) >= 2) return true;
    return false;
  }

  /// Specific block reason: 'exceeded_rejections' or 'insufficient_wallet_balance'
  String? get blockReason {
    if ((_dailyStatus?.rejectionsCount ?? 0) >= 2) {
      return 'exceeded_rejections';
    }
    if (_dailyStatus?.feeDeducted == false ||
        (_wallet?.balance ?? 0.0) < _vehicleDailyFee) {
      return 'insufficient_wallet_balance';
    }
    return _dailyStatus?.blockReason;
  }

  bool get feeDeductedToday => _dailyStatus?.feeDeducted ?? false;
  int get rejectionsToday => _dailyStatus?.rejectionsCount ?? 0;

  RealtimeChannel? _walletRealtimeChannel;
  String? _subscribedDriverId;

  /// Subscribe to Realtime postgres changes on driver_wallets, wallet_transactions, and driver_daily_status
  void subscribeToRealtimeWallet(String driverId) {
    if (driverId.isEmpty || _subscribedDriverId == driverId) return;

    unsubscribeRealtimeWallet();
    _subscribedDriverId = driverId;

    try {
      debugPrint(
          '⚡ Subscribing to Supabase Realtime for Driver Wallet: $driverId');
      _walletRealtimeChannel = _supabaseService.client
          .channel('public:wallet_updates:$driverId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'driver_wallets',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'driver_id',
              value: driverId,
            ),
            callback: (payload) {
              debugPrint(
                  '⚡ Realtime Wallet balance update received: ${payload.newRecord}');
              fetchWalletData(driverId, showLoading: false);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'wallet_transactions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'driver_id',
              value: driverId,
            ),
            callback: (payload) {
              debugPrint('⚡ Realtime Transaction added: ${payload.newRecord}');
              fetchWalletData(driverId, showLoading: false);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'driver_daily_status',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'driver_id',
              value: driverId,
            ),
            callback: (payload) {
              debugPrint(
                  '⚡ Realtime Daily Status updated: ${payload.newRecord}');
              fetchWalletData(driverId, showLoading: false);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Notice establishing realtime wallet subscription: $e');
    }
  }

  void unsubscribeRealtimeWallet() {
    if (_walletRealtimeChannel != null) {
      _supabaseService.client.removeChannel(_walletRealtimeChannel!);
      _walletRealtimeChannel = null;
      _subscribedDriverId = null;
    }
  }

  /// Fetch full wallet information, transactions, daily status, and vehicle fee using REAL DB records
  Future<void> fetchWalletData(String driverId,
      {bool showLoading = true}) async {
    if (driverId.isEmpty) return;

    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    // Auto-subscribe to realtime updates for live UI refreshes
    subscribeToRealtimeWallet(driverId);

    try {
      // 1. Fetch vehicle daily fee based on driver's registered vehicle
      final vehicle = await _supabaseService.getVehicleByDriverId(driverId);
      final vehicleTypes = await _supabaseService.fetchVehicleTypes();

      if (vehicle != null) {
        _vehicleTypeName = vehicle.vehicleType ?? '2 Wheeler';
        final matchedType = vehicleTypes.firstWhere(
          (vt) =>
              vt.id == vehicle.vehicleTypeId ||
              vt.name.toLowerCase() == _vehicleTypeName.toLowerCase(),
          orElse: () => _getFallbackVehicleType(_vehicleTypeName),
        );
        _vehicleDailyFee = _getDailyFeeForVehicleType(matchedType.name);
      } else {
        _vehicleDailyFee = 100.0;
      }

      // 2. Fetch driver wallet balance
      _wallet = await _supabaseService.getDriverWallet(driverId);

      // 3. Fetch transactions list
      _transactions = await _supabaseService.getWalletTransactions(driverId);

      // 4. Fetch today's daily status
      _dailyStatus = await _supabaseService.getDriverDailyStatus(driverId);

      // 5. Fetch completed trips & compute REAL total earnings
      final trips = await _supabaseService.getDriverTrips(driverId);
      final completedTrips =
          trips.where((t) => t.status == 'completed').toList();
      _totalEarningsAllTime = completedTrips.fold<double>(
        0.0,
        (sum, t) => sum + t.fare,
      );

      // 6. Compute REAL total deductions from wallet_transactions (amount < 0)
      _totalDeductionsAllTime = _transactions.fold<double>(
        0.0,
        (sum, tx) => tx.amount < 0 ? sum + tx.amount.abs() : sum,
      );

      // 7. Fetch driver payouts history for REAL settlements
      final payouts = await _supabaseService.getDriverPayouts(driverId);
      _totalSettled = payouts.fold<double>(
        0.0,
        (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0.0),
      );

      if (payouts.isNotEmpty) {
        final lastP = payouts.first;
        _lastSettlementAmount = (lastP['amount'] as num?)?.toDouble() ?? 0.0;
        final createdAtStr = lastP['created_at'] as String?;
        if (createdAtStr != null) {
          _lastSettlementDate =
              DateFormat('MMM dd').format(DateTime.parse(createdAtStr));
        }
      } else {
        _lastSettlementAmount = 0.0;
        _lastSettlementDate = 'No payouts';
      }
    } catch (e) {
      debugPrint('Error fetching real wallet data: $e');
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  VehicleTypeModel _getFallbackVehicleType(String name) {
    return VehicleTypeModel(
      id: 'default',
      name: name,
      capacity: '',
      capacityKg: 0,
      estFare: 0,
      iconName: 'directions_car',
    );
  }

  /// Exact vehicle daily fee mapping as specified by user
  double _getDailyFeeForVehicleType(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('2') ||
        lower.contains('two') ||
        lower.contains('bike')) {
      return 100.0;
    } else if (lower.contains('mini 3w') ||
        lower.contains('3 wheel') ||
        lower.contains('3w') ||
        lower.contains('rickshaw')) {
      return 175.0;
    } else if (lower.contains('7ft') ||
        lower.contains('7 feet') ||
        lower.contains('tata ace') ||
        lower.contains('ace')) {
      return 200.0;
    } else if (lower.contains('8ft') ||
        lower.contains('8 feet') ||
        lower.contains('pickup 8')) {
      return 250.0;
    } else if (lower.contains('9') ||
        lower.contains('10') ||
        lower.contains('9-10ft')) {
      return 270.0;
    } else if (lower.contains('14') ||
        lower.contains('16') ||
        lower.contains('17') ||
        lower.contains('container')) {
      return 300.0;
    }
    return 100.0;
  }

  /// Perform Wallet Recharge via RPC and auto-deduct daily fee if pending
  Future<bool> rechargeWallet({
    required String driverId,
    required double amount,
    required BuildContext context,
  }) async {
    if (amount <= 0 || driverId.isEmpty) return false;

    _isRecharging = true;
    notifyListeners();

    try {
      final res = await _supabaseService.rechargeDriverWallet(
        driverId: driverId,
        amount: amount,
      );

      final success = res['success'] as bool? ?? false;
      final message = res['message'] as String? ?? 'Recharge complete';
      final feeDeducted = res['fee_deducted'] as bool? ?? false;

      if (success) {
        // Refresh real wallet data immediately
        await fetchWalletData(driverId, showLoading: false);

        if (context.mounted) {
          final feeMsg = feeDeducted
              ? '\nDaily fee ₹${_vehicleDailyFee.toStringAsFixed(0)} auto-deducted! You are active to receive orders.'
              : '';
          _showSnackBar(
            context,
            '✅ Recharge Successful! +₹${amount.toStringAsFixed(0)} added.$feeMsg',
            backgroundColor: const Color(0xFF09A234),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          _showSnackBar(context, 'Recharge failed: $message',
              backgroundColor: Colors.red);
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Recharge error: $e',
            backgroundColor: Colors.red);
      }
      return false;
    } finally {
      _isRecharging = false;
      notifyListeners();
    }
  }

  /// Record an order rejection by driver
  Future<void> recordOrderRejection(String driverId) async {
    if (driverId.isEmpty) return;
    try {
      await _supabaseService.recordDriverRejection(driverId);
      _dailyStatus = await _supabaseService.getDriverDailyStatus(driverId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error recording order rejection: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    unsubscribeRealtimeWallet();
    super.dispose();
  }
}
