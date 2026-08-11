import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../views/login/login_view.dart';
import '../../views/signup/signup_view.dart';
import '../../views/otp/otp_view.dart';
import '../../views/vehicle/vehicle_details_view.dart';
import '../../views/document/document_collection_view.dart';
import '../../views/bank/bank_details_view.dart';
import '../../views/verification/verification_pending_view.dart';
import '../../views/home/home_view.dart';
import '../../views/trip/driver_pickup_view.dart';
import '../../views/bidding/outstation_bidding_status_view.dart';
import '../../views/support/support_view.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(ProfileViewModel profileViewModel) {
    return GoRouter(
      initialLocation: '/home',
      refreshListenable: profileViewModel,
      redirect: (context, state) async {
        final location = state.uri.path;
        final authUser = SupabaseService.instance.client.auth.currentUser;
        var driver = profileViewModel.driver;

        if (driver == null) {
          final savedSession =
              await profileViewModel.getSavedSessionPhoneOrId();
          if (savedSession != null && savedSession.isNotEmpty) {
            driver = await profileViewModel.fetchProfile(savedSession);
          } else if (authUser != null) {
            final userPhone = authUser.phone;
            if (userPhone != null && userPhone.isNotEmpty) {
              driver = await profileViewModel.fetchProfile(userPhone);
            }
            driver ??= await profileViewModel.fetchProfile(authUser.id);
          }
        }

        // 1. Not Logged In Guard
        if (authUser == null && driver == null) {
          if (location == '/login' ||
              location == '/signup' ||
              location == '/otp') {
            return null;
          }
          return '/login';
        }

        // If driver record missing in DB
        if (driver == null) {
          if (location == '/signup' ||
              location == '/otp' ||
              location == '/login') {
            return null;
          }
          return '/signup';
        }

        final driverId = driver.id ?? authUser?.id ?? '';

        // 3. Vehicle Details Guard
        if (!driver.isVehicleAdded) {
          if (location == '/vehicle-details') return null;
          return '/vehicle-details?driverId=$driverId';
        }

        // 4. Document Collection Guard
        if (!driver.isDocumentsUploaded) {
          if (location == '/document-collection') return null;
          return '/document-collection?driverId=$driverId';
        }

        // 5. Bank Details Guard
        if (!driver.isBankDetailsAdded) {
          if (location == '/bank-details') return null;
          return '/bank-details?driverId=$driverId';
        }

        // 6. Admin Verification Guard
        if (!driver.isFullyVerified) {
          if (location == '/verification-pending') return null;
          return '/verification-pending?driverId=$driverId';
        }

        // 7. Allow pickup navigation route, bidding status view & support view when fully verified
        if (location.startsWith('/driver/pickup/') ||
            location.startsWith('/driver/bidding-status/') ||
            location == '/support') {
          return null;
        }

        // 8. Fully Verified: Redirect away from auth/onboarding screens to /home
        if (location == '/login' ||
            location == '/signup' ||
            location == '/otp' ||
            location == '/vehicle-details' ||
            location == '/document-collection' ||
            location == '/bank-details' ||
            location == '/verification-pending') {
          return '/home?driverId=$driverId';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupView(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final phone =
                extra?['phone'] ?? state.uri.queryParameters['phone'] ?? '';
            return OtpView(phone: phone);
          },
        ),
        GoRoute(
          path: '/vehicle-details',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final driverId = extra?['driverId'] ??
                state.uri.queryParameters['driverId'] ??
                '';
            return VehicleDetailsView(driverId: driverId);
          },
        ),
        GoRoute(
          path: '/document-collection',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final driverId = extra?['driverId'] ??
                state.uri.queryParameters['driverId'] ??
                '';
            return DocumentCollectionView(driverId: driverId);
          },
        ),
        GoRoute(
          path: '/bank-details',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final driverId = extra?['driverId'] ??
                state.uri.queryParameters['driverId'] ??
                '';
            return BankDetailsView(driverId: driverId);
          },
        ),
        GoRoute(
          path: '/verification-pending',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final driverId = extra?['driverId'] ??
                state.uri.queryParameters['driverId'] ??
                '';
            return VerificationPendingView(driverId: driverId);
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final driverId = extra?['driverId'] ??
                state.uri.queryParameters['driverId'] ??
                '';
            return HomeView(driverId: driverId);
          },
        ),
        GoRoute(
          path: '/driver/pickup/:bookingId',
          builder: (context, state) {
            final bookingId = state.pathParameters['bookingId'] ?? '';
            return DriverPickupView(bookingId: bookingId);
          },
        ),
        GoRoute(
          path: '/driver/bidding-status/:bookingId',
          builder: (context, state) {
            final bookingId = state.pathParameters['bookingId'] ?? '';
            return OutstationBiddingStatusView(bookingId: bookingId);
          },
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) => const SupportView(),
        ),
      ],
    );
  }
}
