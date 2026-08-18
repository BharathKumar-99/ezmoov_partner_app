import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ezmoov_partner_app/views/login/login_view.dart';
import 'package:ezmoov_partner_app/views/signup/signup_view.dart';
import 'package:ezmoov_partner_app/views/otp/otp_view.dart';
import 'package:ezmoov_partner_app/views/vehicle/vehicle_details_view.dart';
import 'package:ezmoov_partner_app/views/document/document_collection_view.dart';
import 'package:ezmoov_partner_app/views/bank/bank_details_view.dart';
import 'package:ezmoov_partner_app/views/verification/verification_pending_view.dart';
import 'package:ezmoov_partner_app/views/home/home_view.dart';
import 'package:ezmoov_partner_app/views/trip/driver_pickup_view.dart';
import 'package:ezmoov_partner_app/views/bidding/outstation_bidding_status_view.dart';
import 'package:ezmoov_partner_app/views/support/support_view.dart';
import 'package:ezmoov_partner_app/views/wallet/wallet_view.dart';
import 'package:ezmoov_partner_app/views/profile/edit_profile_view.dart';
import 'package:ezmoov_partner_app/views/referral/referral_view.dart';

import 'package:ezmoov_partner_app/viewmodels/auth_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/vehicle_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/bank_details_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/document_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/home_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/referral_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/ride_request_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/wallet_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/locale_viewmodel.dart';
import 'package:ezmoov_partner_app/core/services/audio_service.dart';
import 'package:ezmoov_partner_app/l10n/generated/app_localizations.dart';

Widget buildTestableApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => VehicleViewModel()),
      ChangeNotifierProvider(create: (_) => BankDetailsViewModel()),
      ChangeNotifierProvider(create: (_) => DocumentViewModel()),
      ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ChangeNotifierProvider(create: (_) => ReferralViewModel()),
      ChangeNotifierProvider(create: (_) => RideRequestViewModel()),
      ChangeNotifierProvider(create: (_) => WalletViewModel()),
      ChangeNotifierProvider(create: (_) => LocaleViewModel()),
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
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    const codec = StandardMethodCodec();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'xyz.luan/audioplayers.global/events',
      (ByteData? message) async => codec.encodeSuccessEnvelope(null),
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('razorpay_flutter'),
      (MethodCall methodCall) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => null,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'xyz.luan/audioplayers/events/${AudioService.instance.player.playerId}',
      (ByteData? message) async => codec.encodeSuccessEnvelope(null),
    );

    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is MissingPluginException &&
          details.exception.toString().contains('audioplayers')) {
        return;
      }
      originalOnError?.call(details);
    };

    await loadAppFonts();
  });

  group('EZMoov Partner Screen Golden Snapshot Suite', () {
    testGoldens('01_login_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const LoginView()),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '01_login_view');
    });

    testGoldens('02_signup_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const SignupView()),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '02_signup_view');
    });

    testGoldens('03_otp_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const OtpView(phone: '+91 9876543210')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '03_otp_view');
    });

    testGoldens('04_vehicle_details_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const VehicleDetailsView(driverId: 'golden_driver_123')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '04_vehicle_details_view');
    });

    testGoldens('05_document_collection_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const DocumentCollectionView(driverId: 'golden_driver_123')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '05_document_collection_view');
    });

    testGoldens('06_bank_details_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const BankDetailsView(driverId: 'golden_driver_123')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '06_bank_details_view');
    });

    testGoldens('07_verification_pending_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const VerificationPendingView(driverId: 'golden_driver_123')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '07_verification_pending_view');
    });

    testGoldens('08_home_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const HomeView(driverId: 'golden_driver_123')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '08_home_view');
    });

    testGoldens('09_driver_pickup_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const DriverPickupView(bookingId: 'golden_booking_123')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '09_driver_pickup_view');
    });

    testGoldens('10_outstation_bidding_status_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const OutstationBiddingStatusView(bookingId: 'golden_booking_123')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '10_outstation_bidding_status_view');
    });

    testGoldens('11_support_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const SupportView()),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '11_support_view');
    });

    testGoldens('12_wallet_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const WalletView(driverId: 'golden_driver_123')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '12_wallet_view');
    });

    testGoldens('13_edit_profile_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const EditProfileView()),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '13_edit_profile_view');
    });

    testGoldens('14_referral_view', (tester) async {
      await tester.pumpWidgetBuilder(
        buildTestableApp(const ReferralView(driverId: 'golden_driver_123')),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, '14_referral_view');
    });
  });
}
