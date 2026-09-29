import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/viewmodels/ride_request_viewmodel.dart';

import 'package:flutter/services.dart';

import 'package:ezmoov_partner_app/models/booking_model.dart';
import 'package:ezmoov_partner_app/models/vehicle_type_model.dart';

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

  group('Incoming Outstation Booking Eligibility Tests (40km & outstation_booking=true)', () {
    // Reference base driver location: MG Road Bengaluru (12.9756, 77.6066)
    const double driverLat = 12.9756;
    const double driverLng = 77.6066;

    // ~20 km away: Electronic City, Bengaluru (12.8399, 77.6770) -> distance approx 16.8 km (< 40 km)
    // ~55 km away: Ramanagara, Karnataka (12.7209, 77.2799) -> distance approx 45-50 km (> 40 km)

    BookingModel createOutstationBooking({
      required double pickupLat,
      required double pickupLng,
      String service = 'bidding_outstation',
    }) {
      return BookingModel(
        id: 'booking_outstation_test_1',
        customerId: 'cust_123',
        pickupAddress: 'Pickup Point',
        dropAddress: 'Drop Point (Intercity)',
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropLat: 13.5000,
        dropLng: 78.5000,
        status: 'searching',
        service: service,
      );
    }

    test('Outstation booking WITHIN 40 km and outstation_booking=true is ELIGIBLE', () {
      final booking = createOutstationBooking(
        pickupLat: 12.8399,
        pickupLng: 77.6770, // ~17 km away
      );

      final isEligible = viewModel.isBookingEligibleForDriver(
        booking: booking,
        driverLat: driverLat,
        driverLng: driverLng,
        isOutstationBookingEnabled: true,
      );

      expect(isEligible, isTrue);
    });

    test('Outstation booking WITHIN 40 km but outstation_booking=false is INELIGIBLE', () {
      final booking = createOutstationBooking(
        pickupLat: 12.8399,
        pickupLng: 77.6770, // ~17 km away
      );

      final isEligible = viewModel.isBookingEligibleForDriver(
        booking: booking,
        driverLat: driverLat,
        driverLng: driverLng,
        isOutstationBookingEnabled: false,
      );

      expect(isEligible, isFalse);
    });

    test('Outstation booking EXCEEDING 40 km even if outstation_booking=true is INELIGIBLE', () {
      final booking = createOutstationBooking(
        pickupLat: 12.7209,
        pickupLng: 77.2799, // ~45+ km away
      );

      final dist = viewModel.calculateDistance(driverLat, driverLng, 12.7209, 77.2799);
      expect(dist, greaterThan(40.0));

      final isEligible = viewModel.isBookingEligibleForDriver(
        booking: booking,
        driverLat: driverLat,
        driverLng: driverLng,
        isOutstationBookingEnabled: true,
      );

      expect(isEligible, isFalse);
    });

    test('Outstation booking handles various service name representations ("outstation", "biddingoutstation")', () {
      final booking1 = createOutstationBooking(
        pickupLat: 12.8399,
        pickupLng: 77.6770,
        service: 'outstation',
      );
      final booking2 = createOutstationBooking(
        pickupLat: 12.8399,
        pickupLng: 77.6770,
        service: 'biddingoutstation',
      );

      expect(
        viewModel.isBookingEligibleForDriver(
          booking: booking1,
          driverLat: driverLat,
          driverLng: driverLng,
          isOutstationBookingEnabled: true,
        ),
        isTrue,
      );

      expect(
        viewModel.isBookingEligibleForDriver(
          booking: booking2,
          driverLat: driverLat,
          driverLng: driverLng,
          isOutstationBookingEnabled: false,
        ),
        isFalse,
      );
    });
  });

  group('Local Adda and Standard Services Distance Threshold Tests', () {
    const double driverLat = 12.9756;
    const double driverLng = 77.6066;

    test('Local Adda within 20.0 km is eligible, beyond 20.0 km is ineligible', () {
      // Near point ~15 km away (13.1000, 77.5946)
      final nearBooking = BookingModel(
        id: 'local_near',
        customerId: 'cust_1',
        pickupAddress: 'Nearby',
        dropAddress: 'Nearby Drop',
        pickupLat: 13.1000,
        pickupLng: 77.5946,
        dropLat: 12.9800,
        dropLng: 77.6200,
        status: 'searching',
        service: 'local_adda',
      );

      // Far point ~25.0 km away (13.2000, 77.5946)
      final farBooking = BookingModel(
        id: 'local_far',
        customerId: 'cust_2',
        pickupAddress: 'Far',
        dropAddress: 'Far Drop',
        pickupLat: 13.2000,
        pickupLng: 77.5946,
        dropLat: 12.9800,
        dropLng: 77.6200,
        status: 'searching',
        service: 'local_adda',
      );

      expect(
        viewModel.isBookingEligibleForDriver(
          booking: nearBooking,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isTrue,
      );

      expect(
        viewModel.isBookingEligibleForDriver(
          booking: farBooking,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isFalse,
      );
    });

    test('Standard booking within initialStandardDistanceKm (3.0 km) is eligible; between 3km and 10km is ineligible unless farDriver=true', () {
      // Driver at (12.9756, 77.6066)
      // Point A ~2.0 km away (12.9856, 77.6066) -> dist ~1.1 km (< 3.0 km)
      final nearStandardBooking = BookingModel(
        id: 'std_near',
        customerId: 'cust_std_1',
        pickupAddress: 'Near Standard Pickup',
        dropAddress: 'Drop Point',
        pickupLat: 12.9856,
        pickupLng: 77.6066,
        dropLat: 13.5000,
        dropLng: 78.5000,
        status: 'searching',
        service: 'standard',
        farDriver: false,
      );

      // Point B ~7.8 km away (13.0456, 77.6066) -> dist ~7.8 km (> initialStandardDistanceKm, < 10.0 km)
      final midStandardBookingNoFar = BookingModel(
        id: 'std_mid_nofar',
        customerId: 'cust_std_2',
        pickupAddress: 'Mid Standard Pickup',
        dropAddress: 'Drop Point',
        pickupLat: 13.0456,
        pickupLng: 77.6066,
        dropLat: 13.5000,
        dropLng: 78.5000,
        status: 'searching',
        service: 'standard',
        farDriver: false,
      );

      final midStandardBookingWithFar = BookingModel(
        id: 'std_mid_far',
        customerId: 'cust_std_3',
        pickupAddress: 'Mid Standard Pickup (Far Driver)',
        dropAddress: 'Drop Point',
        pickupLat: 13.0456,
        pickupLng: 77.6066,
        dropLat: 13.5000,
        dropLng: 78.5000,
        status: 'searching',
        service: 'standard',
        farDriver: true,
        farDriverIncentive: 50.0,
      );

      // 1. Initial standard radius (3 km) allows nearby booking
      expect(
        viewModel.isBookingEligibleForDriver(
          booking: nearStandardBooking,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isTrue,
      );

      // 2. Initial standard radius excludes 5.5 km booking without farDriver
      expect(
        viewModel.isBookingEligibleForDriver(
          booking: midStandardBookingNoFar,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isFalse,
      );

      // 3. Far driver radius (10 km) allows 5.5 km booking with farDriver=true
      expect(
        viewModel.isBookingEligibleForDriver(
          booking: midStandardBookingWithFar,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isTrue,
      );
    });
  });

  group('Vehicle Tier Escalation Tests (7ft -> 8ft, 8ft -> 9ft, 9ft -> 10ft with 30s delay)', () {
    const double driverLat = 12.9756;
    const double driverLng = 77.6066;

    BookingModel createBookingWithVehicle(
      String vehicleTypeId, {
      DateTime? createdAt,
    }) {
      return BookingModel(
        id: 'booking_veh_test_1',
        customerId: 'cust_100',
        pickupAddress: 'Pickup Location',
        dropAddress: 'Drop Location',
        pickupLat: 12.9800,
        pickupLng: 77.6100,
        dropLat: 12.9900,
        dropLng: 77.6200,
        status: 'searching',
        service: 'local_adda',
        vehicleTypeId: vehicleTypeId,
        createdAt: createdAt ?? DateTime.now().subtract(const Duration(seconds: 35)),
      );
    }

    // --- 7ft -> 8ft tests ---
    test('7 Feet booking is NOT forwarded to 8 Feet driver before 30s (7ft has priority)', () {
      viewModel.setDriverVehicleInfo(
        vehicleType: '8 feet (1.2 Ton)',
        vehicleTypeId: '5',
      );

      final recentBooking7ft = createBookingWithVehicle(
        '7 feet (750 Kg)',
        createdAt: DateTime.now().subtract(const Duration(seconds: 5)),
      );

      final isEligible = viewModel.isBookingEligibleForDriver(
        booking: recentBooking7ft,
        driverLat: driverLat,
        driverLng: driverLng,
      );

      expect(isEligible, isFalse);
    });

    test('7 Feet booking IS forwarded to 8 Feet driver after 30s elapsed', () {
      viewModel.setDriverVehicleInfo(
        vehicleType: '8 feet (1.2 Ton)',
        vehicleTypeId: '5',
      );

      final olderBooking7ft = createBookingWithVehicle(
        '7 feet (750 Kg)',
        createdAt: DateTime.now().subtract(const Duration(seconds: 35)),
      );

      final isEligible = viewModel.isBookingEligibleForDriver(
        booking: olderBooking7ft,
        driverLat: driverLat,
        driverLng: driverLng,
      );

      expect(isEligible, isTrue);
    });

    // --- 8ft -> 9ft tests ---
    test('8 Feet booking is NOT forwarded to 9 Feet driver before 30s (8ft has priority)', () {
      viewModel.setDriverVehicleInfo(
        vehicleType: '9 feet (1.7 Ton)',
        vehicleTypeId: '6',
      );

      final recentBooking8ft = createBookingWithVehicle(
        '8 feet (1.2 Ton)',
        createdAt: DateTime.now().subtract(const Duration(seconds: 5)),
      );

      final isEligible = viewModel.isBookingEligibleForDriver(
        booking: recentBooking8ft,
        driverLat: driverLat,
        driverLng: driverLng,
      );

      expect(isEligible, isFalse);
    });

    test('8 Feet booking IS forwarded to 9 Feet driver after 30s elapsed', () {
      viewModel.setDriverVehicleInfo(
        vehicleType: '9 feet (1.7 Ton)',
        vehicleTypeId: '6',
      );

      final olderBooking8ft = createBookingWithVehicle(
        '8 feet (1.2 Ton)',
        createdAt: DateTime.now().subtract(const Duration(seconds: 35)),
      );

      final isEligible = viewModel.isBookingEligibleForDriver(
        booking: olderBooking8ft,
        driverLat: driverLat,
        driverLng: driverLng,
      );

      expect(isEligible, isTrue);
    });

    // --- 9ft -> 10ft tests ---
    test('9 Feet booking is NOT forwarded to 10 Feet driver before 30s (9ft has priority)', () {
      viewModel.setDriverVehicleInfo(
        vehicleType: '10 feet (2 Tons)',
        vehicleTypeId: '7',
      );

      final recentBooking9ft = createBookingWithVehicle(
        '9 feet (1.7 Ton)',
        createdAt: DateTime.now().subtract(const Duration(seconds: 5)),
      );

      final isEligible = viewModel.isBookingEligibleForDriver(
        booking: recentBooking9ft,
        driverLat: driverLat,
        driverLng: driverLng,
      );

      expect(isEligible, isFalse);
    });

    test('9 Feet booking IS forwarded to 10 Feet driver after 30s elapsed', () {
      viewModel.setDriverVehicleInfo(
        vehicleType: '10 feet (2 Tons)',
        vehicleTypeId: '7',
      );

      final olderBooking9ft = createBookingWithVehicle(
        '9 feet (1.7 Ton)',
        createdAt: DateTime.now().subtract(const Duration(seconds: 35)),
      );

      final isEligible = viewModel.isBookingEligibleForDriver(
        booking: olderBooking9ft,
        driverLat: driverLat,
        driverLng: driverLng,
      );

      expect(isEligible, isTrue);
    });

    test('Each vehicle class receives its own booking IMMEDIATELY (0s delay)', () {
      viewModel.setDriverVehicleInfo(
        vehicleType: '7 feet (750 Kg)',
        vehicleTypeId: '4',
      );

      final booking7ft = createBookingWithVehicle(
        '7 feet (750 Kg)',
        createdAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      expect(
        viewModel.isBookingEligibleForDriver(
          booking: booking7ft,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isTrue,
      );
    });

    test('Smaller vehicles CANNOT receive larger vehicle bookings (no downward assignment)', () {
      viewModel.setDriverVehicleInfo(
        vehicleType: '7 feet (750 Kg)',
        vehicleTypeId: '4',
      );

      final booking8ft = createBookingWithVehicle('8 feet (1.2 Ton)');

      expect(
        viewModel.isBookingEligibleForDriver(
          booking: booking8ft,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isFalse,
      );

      viewModel.setDriverVehicleInfo(
        vehicleType: '9 feet (1.7 Ton)',
        vehicleTypeId: '6',
      );

      final booking10ft = createBookingWithVehicle('10 feet (2 Tons)');

      expect(
        viewModel.isBookingEligibleForDriver(
          booking: booking10ft,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isFalse,
      );
    });

    test('Exact production vehicle list (4 Wheeler -> 8 Ft Vehicle -> 9 Ft Vehicle -> 10 Ft Vehicle) forwarding', () {
      final productionTypes = [
        VehicleTypeModel.fromJson({
          "idx": 0, "id": 1, "name": "2 Wheeler", "capacity": "20 Kgs",
          "capacity_kg": "20.00", "base_fare": "43.00", "daily_fee": "30.00",
          "icon_name": "two_wheeler", "is_active": false, "active": false,
          "grace_time": 20, "per_km": 8, "waittime": 2, "millage_cost": "0.00", "outstation_charges": "0.00"
        }),
        VehicleTypeModel.fromJson({
          "idx": 1, "id": 2, "name": "3 Wheeler", "capacity": "500 Kgs",
          "capacity_kg": "500.00", "base_fare": "210.00", "daily_fee": "175.00",
          "icon_name": "electric_rickshaw", "is_active": true, "active": true,
          "grace_time": 40, "per_km": 27, "waittime": 3, "millage_cost": "3.50", "outstation_charges": "27.00"
        }),
        VehicleTypeModel.fromJson({
          "idx": 2, "id": 4, "name": "4 Wheeler", "capacity": "750 Kgs",
          "capacity_kg": "750.00", "base_fare": "218.00", "daily_fee": "200.00",
          "icon_name": "local_shipping", "is_active": true, "active": true,
          "grace_time": 50, "per_km": 35.5, "waittime": 3.5, "millage_cost": "4.00", "outstation_charges": "35.50"
        }),
        VehicleTypeModel.fromJson({
          "idx": 3, "id": 5, "name": "8 Ft Vehicle", "capacity": "1200 Kgs",
          "capacity_kg": "1200.00", "base_fare": "318.00", "daily_fee": "250.00",
          "icon_name": "local_shipping", "is_active": true, "active": true,
          "grace_time": 80, "per_km": 35.71, "waittime": 4, "millage_cost": "7.00", "outstation_charges": "35.71"
        }),
        VehicleTypeModel.fromJson({
          "idx": 4, "id": 6, "name": "9 Ft Vehicle", "capacity": "1700 Kgs",
          "capacity_kg": "1700.00", "base_fare": "380.00", "daily_fee": "270.00",
          "icon_name": "local_shipping", "is_active": true, "active": true,
          "grace_time": 110, "per_km": 42.9, "waittime": 7, "millage_cost": "7.00", "outstation_charges": "42.90"
        }),
        VehicleTypeModel.fromJson({
          "idx": 5, "id": 7, "name": "10 Ft Vehicle", "capacity": "2000 Kgs",
          "capacity_kg": "2000.00", "base_fare": "400.00", "daily_fee": "270.00",
          "icon_name": "local_shipping", "is_active": true, "active": true,
          "grace_time": 110, "per_km": 45, "waittime": 7.5, "millage_cost": "7.00", "outstation_charges": "45.00"
        }),
      ];

      viewModel.setVehicleTypes(productionTypes);

      // Driver has '8 Ft Vehicle' (id: 5)
      viewModel.setDriverVehicleInfo(
        vehicleType: '8 Ft Vehicle',
        vehicleTypeId: '5',
      );

      // 4 Wheeler (id: 4) booking recent (<30s) -> False
      final recent4wBooking = createBookingWithVehicle(
        '4',
        createdAt: DateTime.now().subtract(const Duration(seconds: 10)),
      );
      expect(
        viewModel.isBookingEligibleForDriver(
          booking: recent4wBooking,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isFalse,
      );

      // 4 Wheeler (id: 4) booking older (>30s) -> True (forwarded to 8 Ft driver)
      final older4wBooking = createBookingWithVehicle(
        '4',
        createdAt: DateTime.now().subtract(const Duration(seconds: 35)),
      );
      expect(
        viewModel.isBookingEligibleForDriver(
          booking: older4wBooking,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isTrue,
      );

      // Driver has '9 Ft Vehicle' (id: 6)
      viewModel.setDriverVehicleInfo(
        vehicleType: '9 Ft Vehicle',
        vehicleTypeId: '6',
      );

      // 8 Ft Vehicle (id: 5) booking older (>30s) -> True (forwarded to 9 Ft driver)
      final older8ftBooking = createBookingWithVehicle(
        '5',
        createdAt: DateTime.now().subtract(const Duration(seconds: 35)),
      );
      expect(
        viewModel.isBookingEligibleForDriver(
          booking: older8ftBooking,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isTrue,
      );

      // Driver has '10 Ft Vehicle' (id: 7)
      viewModel.setDriverVehicleInfo(
        vehicleType: '10 Ft Vehicle',
        vehicleTypeId: '7',
      );

      // 9 Ft Vehicle (id: 6) booking older (>30s) -> True (forwarded to 10 Ft driver)
      final older9ftBooking = createBookingWithVehicle(
        '6',
        createdAt: DateTime.now().subtract(const Duration(seconds: 35)),
      );
      expect(
        viewModel.isBookingEligibleForDriver(
          booking: older9ftBooking,
          driverLat: driverLat,
          driverLng: driverLng,
        ),
        isTrue,
      );
    });
  });
}
