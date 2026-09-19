import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scaled_app/scaled_app.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service_manager.dart';
import 'core/services/fcm_service.dart';
import 'viewmodels/auth_viewmodel.dart';

import 'viewmodels/vehicle_viewmodel.dart';
import 'viewmodels/document_viewmodel.dart';
import 'viewmodels/bank_details_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'views/home/widgets/overlay_bubble_widget.dart';
import 'viewmodels/profile_viewmodel.dart';

import 'viewmodels/ride_request_viewmodel.dart';
import 'viewmodels/locale_viewmodel.dart';
import 'l10n/generated/app_localizations.dart';
import 'viewmodels/wallet_viewmodel.dart';
import 'viewmodels/referral_viewmodel.dart';
import 'viewmodels/performance_viewmodel.dart';

Future<void> main() async {
  ScaledWidgetsFlutterBinding.ensureInitialized(
    scaleFactor: (deviceSize) {
      // 375 is the standard mobile UI design reference width
      const double widthOfDesign = 375;
      return deviceSize.width / widthOfDesign;
    },
  );

  // Initialize package metadata (dynamically loads app version, build number, package name)
  await AppConstants.initialize();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Could not load .env file: $e');
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
      dotenv.env['SUPABASE_ANON_KEY'] ??
      '';

  if (supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabasePublishableKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization notice: $e');
    }
  } else {
    debugPrint(
        '⚠️ Warning: SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY is not defined in .env');
  }

  final profileViewModel = ProfileViewModel();

  // Restore cached driver profile from local disk storage immediately
  await profileViewModel.restoreFromLocalCache();

  // Fetch fresh driver profile from Supabase if logged in
  try {
    final currentAuthUser = Supabase.instance.client.auth.currentUser;
    final savedSession = await profileViewModel.getSavedSessionPhoneOrId();
    final driverIdentifier = savedSession ??
        (currentAuthUser?.phone != null && currentAuthUser!.phone!.isNotEmpty
            ? currentAuthUser.phone!
            : null) ??
        currentAuthUser?.id;

    if (driverIdentifier != null && driverIdentifier.isNotEmpty) {
      await profileViewModel
          .fetchProfile(driverIdentifier)
          .timeout(const Duration(seconds: 4))
          .catchError((_) => null);
    }
  } catch (e) {
    debugPrint('Startup profile fetch notice: $e');
  }

  // Fetch dynamic app config matching version from Supabase on launch
  unawaited(profileViewModel.fetchAppConfig());

  // Run app UI immediately
  runApp(EzMoovPartnerApp(profileViewModel: profileViewModel));

  // Run non-critical background services & network profile sync asynchronously
  unawaited(_initializeBackgroundServices(profileViewModel));
}

/// Asynchronously initialize Firebase, notifications, background tasks and refresh profile & config from Supabase
Future<void> _initializeBackgroundServices(ProfileViewModel profileViewModel) async {
  // 0. Fetch latest app config matching version dynamically
  try {
    await profileViewModel.fetchAppConfig();
  } catch (e) {
    debugPrint('Background app config fetch notice: $e');
  }

  // 1. Initialize Firebase & FCM
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FcmService.instance.initialize();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // 2. Initialize Notification and Background Services
  try {
    await NotificationService.instance.initialize();
    await BackgroundServiceManager.instance.initialize();
  } catch (e) {
    debugPrint('Background services initialization notice: $e');
  }

  // 3. Refresh driver profile from network in background
  try {
    final currentAuthUser = Supabase.instance.client.auth.currentUser;
    final savedSession = await profileViewModel.getSavedSessionPhoneOrId();
    final driverId = savedSession ??
        (currentAuthUser?.phone != null && currentAuthUser!.phone!.isNotEmpty
            ? currentAuthUser.phone!
            : null) ??
        profileViewModel.driver?.id ??
        currentAuthUser?.id;

    if (driverId != null && driverId.isNotEmpty) {
      await profileViewModel.fetchProfile(driverId);
    }
  } catch (e) {
    debugPrint('Background profile refresh notice: $e');
  }
}

class EzMoovPartnerApp extends StatelessWidget {
  final ProfileViewModel profileViewModel;

  const EzMoovPartnerApp({super.key, required this.profileViewModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profileViewModel),
        ChangeNotifierProvider(create: (_) => LocaleViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => VehicleViewModel()),
        ChangeNotifierProvider(create: (_) => DocumentViewModel()),
        ChangeNotifierProvider(create: (_) => BankDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => RideRequestViewModel()),
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
        ChangeNotifierProvider(create: (_) => ReferralViewModel()),
        ChangeNotifierProvider(create: (_) => PerformanceViewModel()),
      ],
      child: Consumer<LocaleViewModel>(
        builder: (context, localeVM, child) {
          return MaterialApp.router(
            title: 'EZMoov Partner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.createRouter(profileViewModel),
            locale: localeVM.locale,
            builder: (context, routerChild) {
              return MediaQuery(
                data: MediaQuery.of(context).scale(),
                child: routerChild ?? const SizedBox.shrink(),
              );
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
              Locale('te', ''),
            ],
          );
        },
      ),
    );
  }
}

// Overlay Window Entrypoint for Floating Home Screen Bubble Mode
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayBubbleWidget(),
    ),
  );
}
