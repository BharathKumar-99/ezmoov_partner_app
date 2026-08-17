import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/booking_model.dart';

void main() {
  group('Intermediate Stops & Fare Rules Tests', () {
    test('Parses intermediate_stops JSON array correctly', () {
      final jsonPayload = {
        'id': 'booking_123',
        'customer_id': 'cust_456',
        'pickup_address': 'Gachibowli, Hyderabad',
        'drop_address': 'Hitec City, Hyderabad',
        'pickup_lat': 17.440,
        'pickup_lng': 78.348,
        'drop_lat': 17.450,
        'drop_lng': 78.380,
        'status': 'accepted',
        'intermediate_stops': [
          {
            'latitude': 17.445,
            'longitude': 78.377,
            'address': 'Stop 1 Address',
            'is_completed': false,
          },
          {
            'latitude': 17.448,
            'longitude': 78.379,
            'address': 'Stop 2 Address',
            'is_completed': true,
          }
        ],
        'amount': {
          'base_fare': 100.0,
          'distance_charges': 50.0,
          'stops_charge': 50.0,
          'taxes_&_gst': 0.0,
          'total_price': 200.0,
        }
      };

      final booking = BookingModel.fromJson(jsonPayload);

      expect(booking.hasStops, isTrue);
      expect(booking.stopsCount, equals(2));
      expect(booking.intermediateStops[0].address, equals('Stop 1 Address'));
      expect(booking.intermediateStops[0].isCompleted, isFalse);
      expect(booking.intermediateStops[1].address, equals('Stop 2 Address'));
      expect(booking.intermediateStops[1].isCompleted, isTrue);
      expect(booking.stopsCharge, equals(50.0));
      expect(booking.baseFare, equals(100.0));
      expect(booking.distanceCharges, equals(50.0));
      expect(booking.taxesAndGst, equals(0.0));
      expect(booking.fare, equals(200.0));
    });

    test('Computes stopsCharge as 25 per stop if stops_charge key missing', () {
      final jsonPayload = {
        'id': 'booking_999',
        'customer_id': 'cust_999',
        'pickup_address': 'Start',
        'drop_address': 'End',
        'pickup_lat': 17.400,
        'pickup_lng': 78.400,
        'drop_lat': 17.500,
        'drop_lng': 78.500,
        'status': 'searching',
        'intermediate_stops': [
          {'latitude': 17.41, 'longitude': 78.41, 'address': 'Stop A'},
          {'latitude': 17.42, 'longitude': 78.42, 'address': 'Stop B'},
          {'latitude': 17.43, 'longitude': 78.43, 'address': 'Stop C'},
        ],
        'amount': {'total_price': 175.0}
      };

      final booking = BookingModel.fromJson(jsonPayload);

      expect(booking.hasStops, isTrue);
      expect(booking.stopsCount, equals(3));
      expect(booking.stopsCharge, equals(75.0)); // 3 stops * 25.0
    });

    test('Parses stringified JSON array in intermediate_stops correctly', () {
      final jsonPayload = {
        'id': 'booking_stringified',
        'customer_id': 'cust_stringified',
        'pickup_address': 'Pickup',
        'drop_address': 'Drop',
        'pickup_lat': 17.400,
        'pickup_lng': 78.400,
        'drop_lat': 17.500,
        'drop_lng': 78.500,
        'status': 'searching',
        'intermediate_stops': '[{"lat": 17.41, "lng": 78.41, "address": "Stringified Stop 1"}, {"lat": 17.42, "lng": 78.42, "address": "Stringified Stop 2"}]',
        'amount': {'total_price': 150.0}
      };

      final booking = BookingModel.fromJson(jsonPayload);

      expect(booking.hasStops, isTrue);
      expect(booking.stopsCount, equals(2));
      expect(booking.intermediateStops[0].address, equals('Stringified Stop 1'));
      expect(booking.intermediateStops[1].address, equals('Stringified Stop 2'));
    });
  });
}
