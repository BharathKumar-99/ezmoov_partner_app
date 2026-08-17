import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:provider/provider.dart';

import 'package:ezmoov_partner_app/views/vehicle/vehicle_details_view.dart';
import 'package:ezmoov_partner_app/viewmodels/auth_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/vehicle_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/bank_details_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/wallet_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/referral_viewmodel.dart';
import 'package:ezmoov_partner_app/l10n/generated/app_localizations.dart';

Widget buildTestableWidget(Widget child, {VehicleViewModel? vehicleViewModel}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => vehicleViewModel ?? VehicleViewModel()),
      ChangeNotifierProvider(create: (_) => BankDetailsViewModel()),
      ChangeNotifierProvider(create: (_) => WalletViewModel()),
      ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ChangeNotifierProvider(create: (_) => ReferralViewModel()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  group('VehicleDetailsView Golden Tests', () {
    testGoldens('VehicleDetailsView renders across mobile & tablet devices', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          const Device(
            name: 'small_screen',
            size: Size(320, 568),
            devicePixelRatio: 2.0,
          ),
          Device.phone,
          Device.iphone11,
          Device.tabletPortrait,
        ])
        ..addScenario(
          name: 'Default Initial State',
          widget: buildTestableWidget(const VehicleDetailsView(driverId: 'golden_driver_123')),
        )
        ..addScenario(
          name: 'Truck Category Selected State',
          widget: Builder(builder: (context) {
            final vm = VehicleViewModel();
            vm.selectCategory('Truck');
            return buildTestableWidget(
              const VehicleDetailsView(driverId: 'golden_driver_123'),
              vehicleViewModel: vm,
            );
          }),
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'vehicle_details_view_devices');
    });

    testGoldens('VehicleDetailsView category interaction & form elements', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableWidget(const VehicleDetailsView(driverId: 'golden_driver_123')),
        surfaceSize: const Size(414, 896),
      );

      await screenMatchesGolden(tester, 'vehicle_details_view_initial');

      // Tap Truck Category
      await tester.tap(find.text('Truck'), warnIfMissed: false);
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'vehicle_details_view_truck_selected');
    });
  });
}
