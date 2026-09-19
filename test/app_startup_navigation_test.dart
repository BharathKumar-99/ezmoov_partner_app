import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';
import 'package:ezmoov_partner_app/models/driver_model.dart';
import 'package:ezmoov_partner_app/core/router/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('App Startup & Router Navigation Tests', () {
    test('ProfileViewModel saveToLocalCache and restoreFromLocalCache properly saves and restores driver', () async {
      final profileVM = ProfileViewModel();

      final testDriver = DriverModel(
        id: 'driver-uuid-1234',
        name: 'Ramesh Kumar',
        email: 'ramesh@ezmoov.com',
        phone: '+919876543210',
        isVehicleAdded: true,
        isDocumentsUploaded: true,
        isBankDetailsAdded: true,
        isVerified: true,
        isOnline: false,
      );

      profileVM.updateDriverLocal(testDriver);
      await profileVM.saveToLocalCache();
      expect(profileVM.driver?.id, equals('driver-uuid-1234'));

      // Create a fresh ProfileViewModel simulating cold app restart
      final freshProfileVM = ProfileViewModel();
      expect(freshProfileVM.driver, isNull);

      // Restore from cache
      await freshProfileVM.restoreFromLocalCache();
      expect(freshProfileVM.driver, isNotNull);
      expect(freshProfileVM.driver?.id, equals('driver-uuid-1234'));
      expect(freshProfileVM.driver?.name, equals('Ramesh Kumar'));
      expect(freshProfileVM.driver?.phone, equals('+919876543210'));
      expect(freshProfileVM.driver?.isFullyVerified, isTrue);
    });

    test('AppRouter creates valid router configuration', () {
      final profileVM = ProfileViewModel();
      final router = AppRouter.createRouter(profileVM);
      expect(router, isNotNull);
      expect(router.routeInformationProvider.value.uri.path, isNotEmpty);
    });

    test('Clear session properly clears stored cache and resets in-memory driver', () async {
      final profileVM = ProfileViewModel();
      final testDriver = DriverModel(
        id: 'driver-uuid-5678',
        name: 'Suresh',
        email: 'suresh@ezmoov.com',
        phone: '+919876543211',
      );

      profileVM.updateDriverLocal(testDriver);
      await profileVM.saveToLocalCache();
      expect(profileVM.driver, isNotNull);

      await profileVM.clearSession();
      expect(profileVM.driver, isNull);

      final freshProfileVM = ProfileViewModel();
      await freshProfileVM.restoreFromLocalCache();
      expect(freshProfileVM.driver, isNull);
    });
  });
}
