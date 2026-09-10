import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/driver_ride_action_model.dart';

void main() {
  group('DriverRideActionModel Unit Tests', () {
    test('Parses DriverRideActionModel JSON payload correctly with integer id', () {
      final json = {
        'id': 101,
        'driver_id': 'd_123',
        'booking_id': 'b_456',
        'action': 'accepted',
        'action_time': '2026-09-10T12:30:00.000Z',
        'pickup_address': 'MG Road, Bengaluru',
        'drop_address': 'Indiranagar, Bengaluru',
        'fare': 250.50,
        'vehicle_type_id': 'v_type_3w',
        'customer_id': 'c_789',
        'customer_name': 'Rahul Sharma',
        'reason': null,
        'response_time_seconds': 4,
        'driver_lat': 12.9716,
        'driver_lng': 77.5946,
        'metadata': {'source': 'partner_app'},
      };

      final actionModel = DriverRideActionModel.fromJson(json);

      expect(actionModel.id, equals(101));
      expect(actionModel.driverId, equals('d_123'));
      expect(actionModel.bookingId, equals('b_456'));
      expect(actionModel.action, equals('accepted'));
      expect(actionModel.isAccepted, isTrue);
      expect(actionModel.isDeclined, isFalse);
      expect(actionModel.fare, equals(250.50));
      expect(actionModel.pickupAddress, equals('MG Road, Bengaluru'));
      expect(actionModel.responseTimeSeconds, equals(4));
    });

    test('Parses declined action with string integer id and reason', () {
      final json = {
        'id': '202',
        'driver_id': 'd_123',
        'booking_id': 'b_999',
        'action': 'declined',
        'action_time': '2026-09-10T14:15:00.000Z',
        'reason': 'Too far from pickup point',
      };

      final actionModel = DriverRideActionModel.fromJson(json);

      expect(actionModel.id, equals(202));
      expect(actionModel.isDeclined, isTrue);
      expect(actionModel.isAccepted, isFalse);
      expect(actionModel.reason, equals('Too far from pickup point'));
    });

    test('Parses DriverRideStatsModel JSON and computes acceptance rate', () {
      final statsJson = {
        'driver_id': 'd_123',
        'total_requests': 20,
        'accepted_count': 16,
        'declined_count': 3,
        'timeout_count': 1,
        'cancelled_count': 0,
        'acceptance_rate': 80.00,
        'today_total': 5,
        'today_accepted': 4,
        'today_declined': 1,
      };

      final stats = DriverRideStatsModel.fromJson(statsJson);

      expect(stats.driverId, equals('d_123'));
      expect(stats.totalRequests, equals(20));
      expect(stats.acceptedCount, equals(16));
      expect(stats.declinedCount, equals(3));
      expect(stats.acceptanceRate, equals(80.00));
      expect(stats.todayAccepted, equals(4));
    });
  });
}
