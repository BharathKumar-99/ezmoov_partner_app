import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';
import 'package:ezmoov_partner_app/views/profile/edit_profile_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EditProfileView renders form fields and save button correctly',
      (WidgetTester tester) async {
    final profileVM = ProfileViewModel();

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileViewModel>.value(
        value: profileVM,
        child: const MaterialApp(
          home: EditProfileView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar Title
    expect(find.text('Edit Profile'), findsOneWidget);

    // Verify Save Button
    expect(find.text('SAVE PROFILE CHANGES'), findsOneWidget);

    // Verify Input Field Labels
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
  });
}
