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
import 'core/services/in_app_update_service.dart';
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

      const double widthOfDesign = 375;
      return deviceSize.width / widthOfDesign;
    },
  );

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

        publishableKey: supabasePublishableKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization notice: $e');
    }
  } else {
    debugPrint(
        '⚠️ Warning: SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY is not defined in .env');
  }

  final profileViewModel = ProfileViewModel();

  await profileViewModel.restoreFromLocalCache();

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

  unawaited(profileViewModel.fetchAppConfig());

  runApp(EzMoovPartnerApp(profileViewModel: profileViewModel));

  unawaited(_initializeBackgroundServices(profileViewModel));
}

Future<void> _initializeBackgroundServices(ProfileViewModel profileViewModel) async {

  try {
    unawaited(InAppUpdateService.instance.checkForUpdateAndPerform());
  } catch (e) {
    debugPrint('Background InAppUpdate check notice: $e');
  }

  try {
    await profileViewModel.fetchAppConfig();
  } catch (e) {
    debugPrint('Background app config fetch notice: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FcmService.instance.initialize();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  try {
    await NotificationService.instance.initialize();
    await BackgroundServiceManager.instance.initialize();
  } catch (e) {
    debugPrint('Background services initialization notice: $e');
  }

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

class EzMoovPartnerApp extends StatefulWidget {
  final ProfileViewModel profileViewModel;

  const EzMoovPartnerApp({super.key, required this.profileViewModel});

  @override
  State<EzMoovPartnerApp> createState() => _EzMoovPartnerAppState();
}

class _EzMoovPartnerAppState extends State<EzMoovPartnerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InAppUpdateService.instance.checkForUpdateAndPerform();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      InAppUpdateService.instance.checkForUpdateAndPerform();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.profileViewModel),
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
            routerConfig: AppRouter.createRouter(widget.profileViewModel),
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
