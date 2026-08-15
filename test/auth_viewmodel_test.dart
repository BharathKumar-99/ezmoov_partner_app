import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/viewmodels/auth_viewmodel.dart';
import 'package:ezmoov_partner_app/models/driver_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthViewModel authVM;

  setUp(() {
    authVM = AuthViewModel();
  });

  tearDown(() {
    authVM.dispose();
  });

  group('AuthViewModel Unit Tests', () {
    test('Initial state values are correct', () {
      expect(authVM.isLoading, isFalse);
      expect(authVM.errorMessage, isNull);
      expect(authVM.isLoginFlow, isTrue);
      expect(authVM.otpCode, equals(''));
    });

    test('setLoading and setError update state correctly', () {
      authVM.setLoading(true);
      expect(authVM.isLoading, isTrue);

      authVM.setError('Sample error message');
      expect(authVM.errorMessage, equals('Sample error message'));

      authVM.setError(null);
      expect(authVM.errorMessage, isNull);
    });

    test('otpCode setter updates value', () {
      authVM.otpCode = '123456';
      expect(authVM.otpCode, equals('123456'));
    });

    testWidgets('verifyOtp rejects invalid short OTP codes (< 6 digits)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    authVM.otpCode = '123';
                    authVM.verifyOtp(context, '+919999999999');
                  },
                  child: const Text('Verify'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid 6-digit OTP'), findsOneWidget);
    });

    test('Driver Model onboarding status checks evaluate step flags correctly', () {
      final incompleteVehicleDriver = DriverModel(
        id: 'd_1',
        name: 'Test Driver',
        email: 'test@ezmoov.com',
        phone: '+919999999999',
        isVehicleAdded: false,
      );
      expect(incompleteVehicleDriver.isVehicleAdded, isFalse);

      final incompleteDocsDriver = DriverModel(
        id: 'd_2',
        name: 'Test Driver 2',
        email: 'test2@ezmoov.com',
        phone: '+919999999999',
        isVehicleAdded: true,
        isDocumentsUploaded: false,
      );
      expect(incompleteDocsDriver.isVehicleAdded, isTrue);
      expect(incompleteDocsDriver.isDocumentsUploaded, isFalse);

      final verifiedDriver = DriverModel(
        id: 'd_3',
        name: 'Verified Driver',
        email: 'verified@ezmoov.com',
        phone: '+919999999999',
        isVehicleAdded: true,
        isDocumentsUploaded: true,
        isBankDetailsAdded: true,
        isVerified: true,
      );
      expect(verifiedDriver.isFullyVerified, isTrue);
    });
  });
}
