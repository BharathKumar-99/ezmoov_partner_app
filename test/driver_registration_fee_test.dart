import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ezmoov_partner_app/models/driver_model.dart';
import 'package:ezmoov_partner_app/models/partner_app_config_model.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';
import 'package:ezmoov_partner_app/views/home/widgets/registration_fee_dialog.dart';
import 'package:ezmoov_partner_app/l10n/generated/app_localizations.dart';

void main() {
  group('DriverModel Registration Fee Unit Tests', () {
    test('Defaults registrationFeePaid to false', () {
      final driver = DriverModel(
        name: 'Ravi Kumar',
        email: 'ravi@example.com',
        phone: '+919876543210',
      );

      expect(driver.registrationFeePaid, isFalse);
    });

    test('Parses registration_fee_paid: false from JSON', () {
      final json = {
        'id': 'd_123',
        'name': 'Ravi Kumar',
        'email': 'ravi@example.com',
        'phone': '+919876543210',
        'registration_fee_paid': false,
        'is_verified': true,
      };

      final driver = DriverModel.fromJson(json);

      expect(driver.registrationFeePaid, isFalse);
    });

    test('Parses registration_fee_paid: true from JSON', () {
      final json = {
        'id': 'd_123',
        'name': 'Ravi Kumar',
        'email': 'ravi@example.com',
        'phone': '+919876543210',
        'registration_fee_paid': true,
        'is_verified': true,
      };

      final driver = DriverModel.fromJson(json);

      expect(driver.registrationFeePaid, isTrue);
    });

    test('Serializes registration_fee_paid to JSON properly', () {
      final driver = DriverModel(
        id: 'd_123',
        name: 'Ravi Kumar',
        email: 'ravi@example.com',
        phone: '+919876543210',
        registrationFeePaid: true,
      );

      final json = driver.toJson();
      expect(json['registration_fee_paid'], isTrue);
    });

    testWidgets('RegistrationFeeDialog renders correctly with localized fee button and benefits', (WidgetTester tester) async {
      final profileVm = ProfileViewModel();
      profileVm.setAppConfig(const PartnerAppConfigModel(
        isMaintenance: false,
        isFreeDriverLogin: false,
        registrationFee: 500.0,
      ));

      await tester.pumpWidget(
        ChangeNotifierProvider<ProfileViewModel>.value(
          value: profileVm,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: RegistrationFeeDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registration Fee Required'), findsOneWidget);
      expect(find.text('PARTNER ACCOUNT PENDING'), findsOneWidget);
      expect(find.text('PAY REGISTRATION FEE (₹500)'), findsOneWidget);
      expect(find.text('Refresh Status'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });
  });
}

