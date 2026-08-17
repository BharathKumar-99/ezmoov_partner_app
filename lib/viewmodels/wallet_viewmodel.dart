import 'dart:async';
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

  List<Map<String, dynamic>> _payouts = [];
  List<Map<String, dynamic>> get payouts => _payouts;

  double get pendingSettlement => _wallet?.balance ?? 0.0;

  String get nextSettlementDate {
    final now = DateTime.now();
    final daysUntilSunday = DateTime.sunday - now.weekday;
    final nextSunday = now.add(Duration(
        days: daysUntilSunday <= 0 ? daysUntilSunday + 7 : daysUntilSunday));
    return DateFormat('MMM dd').format(nextSunday);
  }

  int get platformCommissionPercent => 10;

  bool get isPassActive => _dailyStatus?.isPassActive ?? false;
  DateTime? get passExpiresAt => _dailyStatus?.passExpiresAt;

  /// Driver is blocked if explicitly blocked in daily status, or if 2 rejections reached, or if 24-hour daily pass is expired/unpaid
  bool get isBlocked {
    if (_dailyStatus?.isBlocked == true) return true;
    if ((_dailyStatus?.rejectionsCount ?? 0) >= 2) return true;
    if (!isPassActive) return true;
    return false;
  }

  /// Specific block reason: 'exceeded_rejections' or 'daily_pass_required' or 'insufficient_wallet_balance'
  String? get blockReason {
    if ((_dailyStatus?.rejectionsCount ?? 0) >= 2) {
      return 'exceeded_rejections';
    }
    if (!isPassActive) {
      return 'daily_pass_required';
    }
    return _dailyStatus?.blockReason;
  }

  bool get feeDeductedToday => isPassActive;
  int get rejectionsToday => _dailyStatus?.rejectionsCount ?? 0;

  final List<RealtimeChannel> _realtimeChannels = [];
  String? _subscribedDriverId;

  /// Subscribe to Realtime postgres changes using a dedicated channel for EACH table
  void subscribeToRealtimeWallet(String driverId) {
    if (driverId.isEmpty || _subscribedDriverId == driverId) return;

    unsubscribeRealtimeWallet();
    _subscribedDriverId = driverId;

    try {
      debugPrint(
          '⚡ Subscribing to Supabase Realtime dedicated channels for Driver: $driverId');

      // 1. Driver Wallets Channel
      final walletChan = _supabaseService.client
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
          );
      walletChan.subscribe();
      _realtimeChannels.add(walletChan);

      // 2. Wallet Transactions Channel
      final txChan = _supabaseService.client
          .channel('public:transactions_updates:$driverId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
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
          );
      txChan.subscribe();
      _realtimeChannels.add(txChan);

      // 3. Driver Daily Status Channel
      final dailyStatusChan = _supabaseService.client
          .channel('public:daily_status_updates:$driverId')
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
          );
      dailyStatusChan.subscribe();
      _realtimeChannels.add(dailyStatusChan);

      // 4. Driver Payouts Channel
      final payoutsChan = _supabaseService.client
          .channel('public:payouts_updates:$driverId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'driver_payouts',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'driver_id',
              value: driverId,
            ),
            callback: (payload) {
              debugPrint(
                  '⚡ Realtime Payout status updated: ${payload.newRecord}');
              fetchWalletData(driverId, showLoading: false);
            },
          );
      payoutsChan.subscribe();
      _realtimeChannels.add(payoutsChan);
    } catch (e) {
      debugPrint('Notice establishing realtime wallet subscriptions: $e');
    }
  }

  void unsubscribeRealtimeWallet() {
    for (final chan in _realtimeChannels) {
      _supabaseService.client.removeChannel(chan);
    }
    _realtimeChannels.clear();
    _subscribedDriverId = null;
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
      // 1. Fetch vehicle daily fee strictly from server vehicleTypes DB records
      final vehicle = await _supabaseService.getVehicleByDriverId(driverId);
      final vehicleTypes = await _supabaseService.fetchVehicleTypes();

      if (vehicle != null) {
        _vehicleTypeName = vehicle.vehicleType ?? '';
        VehicleTypeModel? matchedType;

        for (final vt in vehicleTypes) {
          if (vt.id == vehicle.vehicleTypeId ||
              (vt.name.isNotEmpty &&
                  vt.name.toLowerCase() == _vehicleTypeName.toLowerCase())) {
            matchedType = vt;
            break;
          }
        }

        if (matchedType == null && _vehicleTypeName.isNotEmpty) {
          for (final vt in vehicleTypes) {
            if (vt.name.toLowerCase().contains(_vehicleTypeName.toLowerCase()) ||
                _vehicleTypeName.toLowerCase().contains(vt.name.toLowerCase())) {
              matchedType = vt;
              break;
            }
          }
        }

        matchedType ??= vehicleTypes.isNotEmpty ? vehicleTypes.first : null;
        _vehicleDailyFee = matchedType?.dailyFee ?? 0.0;
      } else if (vehicleTypes.isNotEmpty) {
        _vehicleDailyFee = vehicleTypes.first.dailyFee;
      } else {
        _vehicleDailyFee = 0.0;
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
      _payouts = payouts;
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



  bool _isPayingFee = false;
  bool get isPayingFee => _isPayingFee;

  /// Driver manually pays daily fee to purchase 24-hour pass
  Future<bool> payDailyFee({
    required String driverId,
    required BuildContext context,
  }) async {
    if (driverId.isEmpty || _isPayingFee) return false;

    _isPayingFee = true;
    notifyListeners();

    try {
      final res = await _supabaseService.payDriverDailyFee(driverId);
      _isPayingFee = false;
      notifyListeners();

      final success = res['success'] as bool? ?? false;
      final message = res['message'] as String? ?? 'Payment complete';

      if (success) {
        await fetchWalletData(driverId, showLoading: false);
        if (context.mounted) {
          _showSnackBar(
            context,
            '🎉 24-Hour Pass Activated! You can now go online.',
            backgroundColor: const Color(0xFF09A234),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          _showSnackBar(
            context,
            message,
            backgroundColor: Colors.red.shade700,
          );
        }
        return false;
      }
    } catch (e) {
      _isPayingFee = false;
      notifyListeners();
      if (context.mounted) {
        _showSnackBar(
          context,
          'Error paying daily fee: $e',
          backgroundColor: Colors.red.shade700,
        );
      }
      return false;
    }
  }

  bool _isWithdrawing = false;
  bool get isWithdrawing => _isWithdrawing;

  /// Perform Wallet Withdrawal via RPC
  Future<bool> withdrawWallet({
    required String driverId,
    required double amount,
    required BuildContext context,
  }) async {
    if (amount <= 0 || driverId.isEmpty || _isWithdrawing) return false;

    _isWithdrawing = true;
    notifyListeners();

    try {
      final res = await _supabaseService.withdrawDriverWallet(
        driverId: driverId,
        amount: amount,
      );

      _isWithdrawing = false;
      notifyListeners();

      final success = res['success'] as bool? ?? false;
      final message = res['message'] as String? ?? 'Withdrawal processed';

      if (success) {
        await fetchWalletData(driverId, showLoading: false);
        if (context.mounted) {
          _showSnackBar(
            context,
            '💸 ₹${amount.toStringAsFixed(0)} withdrawal request submitted! Money will be credited to your bank account in 1 - 2 business days.',
            backgroundColor: const Color(0xFF09A234),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          _showSnackBar(
            context,
            message,
            backgroundColor: Colors.red.shade700,
          );
        }
        return false;
      }
    } catch (e) {
      _isWithdrawing = false;
      notifyListeners();
      if (context.mounted) {
        _showSnackBar(
          context,
          'Error requesting withdrawal: $e',
          backgroundColor: Colors.red.shade700,
        );
      }
      return false;
    }
  }

  /// Perform Wallet Recharge via RPC
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
