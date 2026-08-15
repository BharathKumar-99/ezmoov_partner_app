import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/viewmodels/ride_request_viewmodel.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  late RideRequestViewModel viewModel;

  setUp(() {
    viewModel = RideRequestViewModel();
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('RideRequestViewModel Unit Tests', () {
    test('Haversine distance calculation produces correct kilometer output', () {
      // Bengaluru MG Road to Kempegowda Bus Station (approx 3.5 - 6.0 km)
      final dist = viewModel.calculateDistance(12.9756, 77.6066, 12.9779, 77.5727);
      expect(dist, greaterThan(3.5));
      expect(dist, lessThan(6.0));
    });

    test('Haversine distance returns 0.0 for zero coordinates', () {
      final dist = viewModel.calculateDistance(0.0, 0.0, 12.9756, 77.6066);
      expect(dist, equals(0.0));
    });

    test('declineRide adds bookingId to declined list and resets modal state', () {
      expect(viewModel.declinedBookingIds, isEmpty);

      viewModel.declineRide('test_booking_123');

      expect(viewModel.declinedBookingIds, contains('test_booking_123'));
      expect(viewModel.activeBroadcastBooking, isNull);
    });

    test('withdrawBid clears active pending bid state', () {
      viewModel.withdrawBid();
      expect(viewModel.hasPendingBid, isFalse);
      expect(viewModel.activePendingBidBooking, isNull);
      expect(viewModel.activePendingBid, isNull);
    });
  });
}
