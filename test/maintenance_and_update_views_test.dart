import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ezmoov_partner_app/l10n/generated/app_localizations.dart';
import 'package:ezmoov_partner_app/viewmodels/locale_viewmodel.dart';
import 'package:ezmoov_partner_app/viewmodels/profile_viewmodel.dart';
import 'package:ezmoov_partner_app/views/maintenance/maintenance_view.dart';
import 'package:ezmoov_partner_app/views/update/app_update_view.dart';

Widget _buildTestWidget(Widget child, ProfileViewModel profileVm) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ProfileViewModel>.value(value: profileVm),
      ChangeNotifierProvider<LocaleViewModel>(create: (_) => LocaleViewModel()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      home: child,
    ),
  );
}

void main() {
  group('MaintenanceView & AppUpdateView UI Tests', () {
    testWidgets('MaintenanceView renders custom title, message and status correctly', (tester) async {
      final profileVm = ProfileViewModel();

      await tester.pumpWidget(
        _buildTestWidget(const MaintenanceView(), profileVm),
      );

      // Verify header and title
      expect(find.text('System Status'), findsOneWidget);
      expect(find.text('App Under Maintenance'), findsOneWidget);
      expect(find.text('SCHEDULED DOWNTIME'), findsOneWidget);
      expect(find.text('CHECK SERVER STATUS'), findsOneWidget);
      expect(find.byIcon(Icons.construction_rounded), findsOneWidget);
    });

    testWidgets('AppUpdateView renders version chips and update buttons in mandatory mode', (tester) async {
      final profileVm = ProfileViewModel();

      await tester.pumpWidget(
        _buildTestWidget(const AppUpdateView(isForced: true), profileVm),
      );

      expect(find.text('App Update'), findsOneWidget);
      expect(find.text('MANDATORY UPDATE'), findsOneWidget);
      expect(find.text('Update Available'), findsOneWidget);
      expect(find.text('UPDATE NOW'), findsOneWidget);
      expect(find.byIcon(Icons.rocket_launch_rounded), findsOneWidget);
      expect(find.text("WHAT'S NEW IN THIS VERSION"), findsOneWidget);
      expect(find.text('⚠️ This update is required to continue receiving orders.'), findsOneWidget);
    });

    testWidgets('AppUpdateView renders optional mode with Remind Me Later button', (tester) async {
      final profileVm = ProfileViewModel();

      await tester.pumpWidget(
        _buildTestWidget(const AppUpdateView(isForced: false), profileVm),
      );

      expect(find.text('NEW VERSION AVAILABLE'), findsOneWidget);
      expect(find.text('Remind Me Later'), findsOneWidget);
    });
  });
}
