import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ezmoov_partner_app/views/signup/signup_view.dart';
import 'package:ezmoov_partner_app/views/signup/widgets/terms_and_conditions_dialog.dart';
import 'package:ezmoov_partner_app/viewmodels/auth_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/locale_viewmodel.dart';
import 'package:ezmoov_partner_app/l10n/generated/app_localizations.dart';

Widget createTestSignupApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => LocaleViewModel()),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SignupView(),
    ),
  );
}

void main() {
  group('SignupView Terms & Conditions Flow Tests', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize = const Size(1080, 2400);
      binding.platformDispatcher.views.first.devicePixelRatio = 2.0;
    });

    testWidgets('SignupView renders terms & conditions checkbox and text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestSignupApp());
      await tester.pumpAndSettle();

      expect(find.text('Driver Registration'), findsOneWidget);
      expect(find.text('Sign Up & Continue'), findsOneWidget);

      // Checkbox should be present and initially unchecked
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      final Checkbox checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isFalse);

      // Terms & Conditions text
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('Clicking Sign Up when terms unchecked opens TermsAndConditionsDialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestSignupApp());
      await tester.pumpAndSettle();

      // Tap Sign Up & Continue button
      final btnFinder = find.text('Sign Up & Continue');
      await tester.ensureVisible(btnFinder);
      await tester.tap(btnFinder);
      await tester.pumpAndSettle();

      // Verify TermsAndConditionsDialog is shown with tabs and agreement
      expect(find.byType(TermsAndConditionsDialog), findsOneWidget);
      expect(find.text('DRIVER PARTNER TECHNOLOGY ACCESS AGREEMENT'), findsOneWidget);
      expect(find.text('Driver Partner Agreement'), findsWidgets);
      expect(find.text('Platform Terms of Use'), findsOneWidget);
      expect(find.text('Accept Terms'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('Accepting terms in popup turns checkmark to true', (WidgetTester tester) async {
      await tester.pumpWidget(createTestSignupApp());
      await tester.pumpAndSettle();

      // 1. Initial state: checkbox is unchecked
      Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);

      // 2. Click Sign Up & Continue to trigger terms popup
      final btnFinder = find.text('Sign Up & Continue');
      await tester.ensureVisible(btnFinder);
      await tester.tap(btnFinder);
      await tester.pumpAndSettle();
      expect(find.byType(TermsAndConditionsDialog), findsOneWidget);

      // 3. Click 'Accept Terms' in popup
      final acceptFinder = find.text('Accept Terms');
      await tester.ensureVisible(acceptFinder);
      await tester.tap(acceptFinder);
      await tester.pumpAndSettle();

      // 4. Popup should be dismissed and checkbox should now be checked (true)
      expect(find.byType(TermsAndConditionsDialog), findsNothing);
      checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('Tapping checkbox directly toggles checkmark state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestSignupApp());
      await tester.pumpAndSettle();

      final checkboxFinder = find.byType(Checkbox);
      await tester.ensureVisible(checkboxFinder);

      Checkbox checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isFalse);

      // Tap checkbox to check
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isTrue);

      // Tap checkbox to uncheck
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isFalse);
    });

    testWidgets('Declining terms popup keeps checkbox unchecked', (WidgetTester tester) async {
      await tester.pumpWidget(createTestSignupApp());
      await tester.pumpAndSettle();

      // Click Sign Up to trigger popup
      final btnFinder = find.text('Sign Up & Continue');
      await tester.ensureVisible(btnFinder);
      await tester.tap(btnFinder);
      await tester.pumpAndSettle();

      // Tap 'Decline'
      final declineFinder = find.text('Decline');
      await tester.ensureVisible(declineFinder);
      await tester.tap(declineFinder);
      await tester.pumpAndSettle();

      // Popup dismissed, checkbox remains false
      expect(find.byType(TermsAndConditionsDialog), findsNothing);
      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });
  });
}
