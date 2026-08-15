import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/ride_request_viewmodel.dart';
import 'tabs/home_tab.dart';
import 'tabs/earnings_tab.dart';
import 'tabs/alerts_tab.dart';
import 'tabs/profile_tab.dart';
import '../wallet/wallet_view.dart';
import 'widgets/active_trip_floating_card.dart';
import 'widgets/pending_bid_floating_card.dart';

import '../../l10n/generated/app_localizations.dart';

class HomeView extends StatelessWidget {
  final String driverId;

  const HomeView({
    super.key,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVm = context.read<ProfileViewModel>();
      final rideVm = context.read<RideRequestViewModel>();

      final effectiveDriverId = driverId.isNotEmpty
          ? driverId
          : (profileVm.driver?.id ?? '');

      if (effectiveDriverId.isNotEmpty) {
        rideVm.restoreActiveTripOnLaunch(effectiveDriverId, context);
      }

      if (driverId.isNotEmpty && (profileVm.driver == null || profileVm.driver!.id != driverId)) {
        profileVm.fetchProfile(driverId, context);
      } else if (profileVm.driver != null && profileVm.isOnline) {
        rideVm.startBroadcastListening(
          driverId: profileVm.driver!.id!,
          driverLat: profileVm.latitude,
          driverLng: profileVm.longitude,
          context: context,
          driverVehicleType: profileVm.driver?.vehicleType ?? profileVm.vehicle?.vehicleType,
          driverVehicleTypeId: profileVm.vehicle?.vehicleTypeId,
        );
      }
    });

    return Consumer2<HomeViewModel, RideRequestViewModel>(
      builder: (context, homeVm, rideVm, child) {
        final profileVm = context.watch<ProfileViewModel>();
        final effectiveDriverId = driverId.isNotEmpty
            ? driverId
            : (profileVm.driver?.id ?? '');

        final List<Widget> tabs = [
          const HomeTab(),
          WalletView(driverId: effectiveDriverId),
          const EarningsTab(),
          const AlertsTab(),
          const ProfileTab(),
        ];

        final List<String> tabTitles = [
          l10n.appTitle,
          'Wallet & Payouts',
          l10n.earnings,
          l10n.alerts,
          l10n.profile,
        ];

        final activeTrip = rideVm.activeDriverTrip;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tabTitles[homeVm.currentTabIndex],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                tooltip: 'Wallet',
                onPressed: () {
                  homeVm.setTabIndex(1);
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                onPressed: () => context.read<ProfileViewModel>().clearProfileAndLogout(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                IndexedStack(
                  index: homeVm.currentTabIndex,
                  children: tabs,
                ),
                if (activeTrip != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: ActiveTripFloatingCard(
                      booking: activeTrip,
                      onTap: () {
                        context.go('/driver/pickup/${activeTrip.id}');
                      },
                    ),
                  )
                else if (rideVm.hasPendingBid)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: PendingBidFloatingCard(
                      booking: rideVm.activePendingBidBooking!,
                      bid: rideVm.activePendingBid!,
                      onTap: () {
                        context.go('/driver/bidding-status/${rideVm.activePendingBidBooking!.id}');
                      },
                    ),
                  ),
              ],
            ),
          ),

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: homeVm.currentTabIndex,
              onTap: (index) => homeVm.setTabIndex(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.surface,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_rounded),
                  label: l10n.home,
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_rounded),
                  label: 'Wallet',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.payments_rounded),
                  label: l10n.earnings,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.notifications_rounded),
                  label: l10n.alerts,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_rounded),
                  label: l10n.profile,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
