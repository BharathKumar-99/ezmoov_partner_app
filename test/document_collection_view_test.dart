import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ezmoov_partner_app/views/document/document_collection_view.dart';
import 'package:ezmoov_partner_app/viewmodels/document_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/locale_viewmodel.dart';
import 'package:ezmoov_partner_app/l10n/generated/app_localizations.dart';

Widget createDocumentTestApp(Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => DocumentViewModel()),
      ChangeNotifierProvider(create: (_) => ProfileViewModel()),
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
  group('DocumentCollectionView UI Render Tests', () {
    testWidgets('renders all 12 document upload cards including Aadhaar Front/Back, DL Front/Back, Vehicle RC', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createDocumentTestApp(const DocumentCollectionView(driverId: 'test_driver_id')));
      await tester.pumpAndSettle();

      expect(find.text('Document Verification'), findsWidgets);

      // Verify all 12 document titles are rendered
      expect(find.text('Aadhaar Card (Front)'), findsOneWidget);
      expect(find.text('Aadhaar Card (Back)'), findsOneWidget);
      expect(find.text('Driving License (Front)'), findsOneWidget);
      expect(find.text('Driving License (Back)'), findsOneWidget);
      expect(find.text('Vehicle RC'), findsOneWidget);
      expect(find.text('PAN Card'), findsOneWidget);
      expect(find.text('Vehicle Insurance'), findsOneWidget);
      expect(find.text('PUC Certificate'), findsOneWidget);
      expect(find.text('Vehicle Permit'), findsOneWidget);
      expect(find.text('Fitness Certificate'), findsOneWidget);
      expect(find.text('Police Clearance Certificate'), findsOneWidget);
      expect(find.text('Selfie with Vehicle'), findsOneWidget);

      // Verify submit button shows 0/12 uploaded initially
      expect(find.text('Submit Documents (0/12)'), findsOneWidget);
    });

    testWidgets('renders 8 document upload cards for 3-wheeler vehicles', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createDocumentTestApp(const DocumentCollectionView(
        driverId: 'test_driver_id',
        vehicleCategory: '3W',
      )));
      await tester.pumpAndSettle();

      expect(find.text('Aadhaar Card (Front)'), findsOneWidget);
      expect(find.text('Aadhaar Card (Back)'), findsOneWidget);
      expect(find.text('Driving License (Front)'), findsOneWidget);
      expect(find.text('Driving License (Back)'), findsOneWidget);
      expect(find.text('Vehicle RC'), findsOneWidget);
      expect(find.text('PAN Card'), findsOneWidget);
      expect(find.text('Vehicle Insurance'), findsOneWidget);
      expect(find.text('PUC Certificate'), findsOneWidget);

      // Verify 4W exclusive docs are not rendered
      expect(find.text('Vehicle Permit'), findsNothing);
      expect(find.text('Fitness Certificate'), findsNothing);
      expect(find.text('Police Clearance Certificate'), findsNothing);
      expect(find.text('Selfie with Vehicle'), findsNothing);

      // Verify submit button shows 0/8 uploaded initially
      expect(find.text('Submit Documents (0/8)'), findsOneWidget);
    });
  });
}
