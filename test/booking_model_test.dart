import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/booking_model.dart';

void main() {
  test('Parses user booking JSON payload correctly', () {
    final jsonPayload = {
      "idx": 6,
      "id": "d3080d8a-f532-491f-8653-358b65f65b7d",
      "driver_id": "f9fcfbdc-e430-4019-8eed-cd2b09afabc7",
      "pickup_address": "XH7H+523, Jayanagar, Kalasipalyam New Extension, Kalasipalya, Bengaluru, Karnataka 560002, India, Kalasipalya, Bengaluru",
      "drop_address": "Home - 7/10/3, Chikkalasandra, Near siri empire, Bengaluru, 560061",
      "pickup_lat": 12.962895,
      "pickup_lng": 77.5775383,
      "drop_lat": 12.9149265738777,
      "drop_lng": 77.5485795736313,
      "status": "searching",
      "otp": "5900",
      "driver_name": "Demo Partner",
      "customer_phone": "1234567890",
      "customer_id": "54e94ad1-8d12-4642-8fae-b05f62b2a752",
      "amount": "{\"gst\": 10.2, \"promo\": 0.0, \"base_fare\": 150.0, \"totalfare\": 214.28, \"trip fare\": 204.08, \"distance_fare\": 54.08}",
      "customer_name": "kioken",
    };

    final booking = BookingModel.fromJson(jsonPayload);

    expect(booking.customerName, equals('kioken'));
    expect(booking.customerPhone, equals('1234567890'));
    expect(booking.fare, closeTo(214.28, 0.01));
    expect(booking.amount?['totalfare'], equals(214.28));
  });

  test('Parses new total_price breakdown payload with discounts & taxes', () {
    final payload = {
      "id": "test_total_price",
      "customer_id": "cust_total_price",
      "amount": {
        "base_fare": 150,
        "promo_code": "SAVE100",
        "taxes_&_gst": 10.31,
        "total_price": 116.47,
        "discount_amount": 100,
        "distance_charges": 56.16
      }
    };

    final booking = BookingModel.fromJson(payload);
    expect(booking.fare, closeTo(116.47, 0.01));
  });

  test('Parses driver_charges map {"toll": 55, "gas": 334} once without double counting', () {
    final payload = {
      "id": "test_driver_charges",
      "customer_id": "cust_driver_charges",
      "amount": {
        "total_price": 116.47,
        "driver_charges": {
          "toll": 55,
          "gas": 334
        }
      }
    };

    final booking = BookingModel.fromJson(payload);
    // Base 116.47 + 389 charges = 505.47
    expect(booking.fare, closeTo(505.47, 0.01));

    // Serialize to JSON and parse back
    final reloadedBooking = BookingModel.fromJson(booking.toJson());
    // Should still be exactly 505.47, never 894.47!
    expect(reloadedBooking.fare, closeTo(505.47, 0.01));
  });

  test('Parses component summation when total key is missing with discount', () {
    final componentsBooking = BookingModel.fromJson({
      "id": "test3",
      "customer_id": "cust3",
      "amount": {
        "base_fare": 150,
        "distance_charges": 56.16,
        "taxes_&_gst": 10.31,
        "discount_amount": 100
      }
    });
    expect(componentsBooking.fare, closeTo(116.47, 0.01));
  });

  test('Parses numeric amount and string numbers', () {
    final directNumBooking = BookingModel.fromJson({
      "id": "test1",
      "customer_id": "cust1",
      "customer_name": "John",
      "customer_phone": 9876543210, // integer phone number
      "amount": 350.50,
    });
    expect(directNumBooking.customerName, equals('John'));
    expect(directNumBooking.customerPhone, equals('9876543210'));
    expect(directNumBooking.fare, equals(350.50));

    final directStrBooking = BookingModel.fromJson({
      "id": "test2",
      "customer_id": "cust2",
      "customer_name": "Jane",
      "customer_phone": "+919876543210",
      "amount": "199.99",
    });
    expect(directStrBooking.fare, equals(199.99));
  });

  test('Parses nested fare_breakdown map or case-insensitive keys', () {
    final nestedBooking = BookingModel.fromJson({
      "id": "test4",
      "customer_id": "cust4",
      "amount": {
        "fare_breakdown": {
          "Total Fare": "285.50"
        }
      }
    });
    expect(nestedBooking.fare, equals(285.50));
  });
}
