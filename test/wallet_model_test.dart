import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/wallet_model.dart';

void main() {
  group('DriverWalletModel Outstation Pass Tests', () {
    test('Parses outstation_pass_expires_at correctly and verifies isOutstationPassActive', () {
      final futureDate = DateTime.now().add(const Duration(days: 15));
      final walletJson = {
        'id': 'wallet-123',
        'driver_id': 'driver-456',
        'balance': 500.0,
        'hold_balance': 0.0,
        'currency': 'INR',
        'is_active': true,
        'daily_fee_paid': false,
        'outstation_pass_expires_at': futureDate.toIso8601String(),
      };

      final wallet = DriverWalletModel.fromJson(walletJson);
      expect(wallet.outstationPassExpiresAt, isNotNull);
      expect(wallet.isOutstationPassActive, isTrue);
    });

    test('isOutstationPassActive returns false for past expiry date', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final walletJson = {
        'id': 'wallet-123',
        'driver_id': 'driver-456',
        'balance': 500.0,
        'hold_balance': 0.0,
        'currency': 'INR',
        'is_active': true,
        'daily_fee_paid': false,
        'outstation_pass_expires_at': pastDate.toIso8601String(),
      };

      final wallet = DriverWalletModel.fromJson(walletJson);
      expect(wallet.outstationPassExpiresAt, isNotNull);
      expect(wallet.isOutstationPassActive, isFalse);
    });

    test('isOutstationPassActive returns false when outstation_pass_expires_at is null', () {
      final walletJson = {
        'id': 'wallet-123',
        'driver_id': 'driver-456',
        'balance': 500.0,
        'hold_balance': 0.0,
        'currency': 'INR',
        'is_active': true,
        'daily_fee_paid': false,
      };

      final wallet = DriverWalletModel.fromJson(walletJson);
      expect(wallet.outstationPassExpiresAt, isNull);
      expect(wallet.isOutstationPassActive, isFalse);
    });

    test('Parses local_adda_pass_expires_at correctly and verifies isLocalAddaPassActive', () {
      final futureDate = DateTime.now().add(const Duration(days: 20));
      final walletJson = {
        'id': 'wallet-123',
        'driver_id': 'driver-456',
        'balance': 500.0,
        'local_adda_pass_expires_at': futureDate.toIso8601String(),
      };

      final wallet = DriverWalletModel.fromJson(walletJson);
      expect(wallet.localAddaPassExpiresAt, isNotNull);
      expect(wallet.isLocalAddaPassActive, isTrue);
      expect(wallet.isOutstationPassActive, isTrue);
    });

    test('Serializes local_adda_pass_expires_at correctly to JSON', () {
      final expiryDate = DateTime.parse('2026-10-23T18:30:00.000Z');
      final wallet = DriverWalletModel(
        id: 'wallet-123',
        driverId: 'driver-456',
        balance: 1500.0,
        localAddaPassExpiresAt: expiryDate,
      );

      final json = wallet.toJson();
      expect(json['local_adda_pass_expires_at'], isNotNull);
      expect(json['outstation_pass_expires_at'], isNotNull);
    });
  });
}
