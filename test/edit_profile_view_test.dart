import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ezmoov_partner_app/models/driver_model.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';
import 'package:ezmoov_partner_app/views/profile/edit_profile_view.dart';
import 'package:ezmoov_partner_app/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EditProfileView renders form fields and save button correctly',
      (WidgetTester tester) async {
    final profileVM = ProfileViewModel();

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileViewModel>.value(
        value: profileVM,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EditProfileView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar Title
    expect(find.text('Edit Profile'), findsOneWidget);

    // Verify Save Button
    expect(find.text('SAVE CHANGES'), findsOneWidget);

    // Verify Input Field Labels
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Email Address'), findsAtLeastNWidgets(1));
    expect(find.text('Full Operational Address *'), findsAtLeastNWidgets(1));
  });

  testWidgets('EditProfileView renders Partner ID when present',
      (WidgetTester tester) async {
    final profileVM = ProfileViewModel();
    profileVM.updateDriverLocal(
      DriverModel(
        id: 'drv-1',
        uniqueId: 'EZMD0001',
        name: 'Ramesh Singh',
        email: 'ramesh@example.com',
        phone: '+919876543210',
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileViewModel>.value(
        value: profileVM,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EditProfileView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Partner ID (Unique ID)'), findsOneWidget);
    expect(find.text('EZMD0001'), findsOneWidget);
  });
}
