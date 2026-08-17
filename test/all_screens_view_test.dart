import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ezmoov_partner_app/views/login/login_view.dart';
import 'package:ezmoov_partner_app/views/signup/signup_view.dart';
import 'package:ezmoov_partner_app/views/vehicle/vehicle_details_view.dart';
import 'package:ezmoov_partner_app/views/bank/bank_details_view.dart';
import 'package:ezmoov_partner_app/views/support/support_view.dart';
import 'package:ezmoov_partner_app/views/verification/verification_pending_view.dart';
import 'package:ezmoov_partner_app/views/referral/referral_view.dart';
import 'package:ezmoov_partner_app/viewmodels/auth_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/vehicle_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/bank_details_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/wallet_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/referral_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/locale_viewmodel.dart';
import 'package:ezmoov_partner_app/l10n/generated/app_localizations.dart';

Widget createTestApp(Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => VehicleViewModel()),
      ChangeNotifierProvider(create: (_) => BankDetailsViewModel()),
      ChangeNotifierProvider(create: (_) => WalletViewModel()),
      ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ChangeNotifierProvider(create: (_) => ReferralViewModel()),
      ChangeNotifierProvider(create: (_) => LocaleViewModel()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  group('All Screens UI & Navigation Render Tests', () {
    testWidgets('LoginView renders heading, text fields and continue button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const LoginView()));
      await tester.pumpAndSettle();

      expect(find.text('EZMoov Partner'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_rounded), findsOneWidget);
    });

    testWidgets('SignupView renders driver registration fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SignupView()));
      await tester.pumpAndSettle();

      expect(find.text('Driver Registration'), findsOneWidget);
      expect(find.text('Join EZMoov Fleet'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Sign Up & Continue'), findsOneWidget);
    });

    testWidgets('VehicleDetailsView renders category selection and form options', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const VehicleDetailsView(driverId: 'test_driver_id')));
      await tester.pumpAndSettle();

      expect(find.text('Vehicle Details'), findsOneWidget);
      expect(find.text('Truck'), findsOneWidget);
      expect(find.text('3W'), findsOneWidget);

      // Select Truck category
      await tester.tap(find.text('Truck'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(VehicleDetailsView), findsOneWidget);
    });

    testWidgets('BankDetailsView renders bank account input fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const BankDetailsView(driverId: 'test_driver_id')));
      await tester.pumpAndSettle();

      expect(find.text('Partner Payout Bank Account'), findsOneWidget);
      expect(find.text('Submit Bank Details'), findsOneWidget);
    });

    testWidgets('SupportView renders help topics and support options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SupportView()));
      await tester.pumpAndSettle();

      expect(find.byType(SupportView), findsOneWidget);
    });

    testWidgets('VerificationPendingView renders status indicator and description', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const VerificationPendingView(driverId: 'test_driver_id')));
      await tester.pumpAndSettle();

      expect(find.text('Account Verification'), findsOneWidget);
    });

    testWidgets('ReferralView renders referral header and share button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ReferralView(driverId: 'test_driver_id')));
      await tester.pumpAndSettle();

      expect(find.text('Refer & Earn Partner Bonus'), findsOneWidget);
    });
  });
}
