import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../l10n/generated/app_localizations.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVm = context.read<ProfileViewModel>();
      if (profileVm.driver?.id != null) {
        context.read<HomeViewModel>().fetchEarnings(profileVm.driver!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProfileViewModel>(
      builder: (context, vm, child) {
        final driver = vm.driver;
        final allTrips = vm.trips;

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);

        // Filter completed trips
        final completedTrips = allTrips.where((t) => t.status == 'completed').toList();

        // Completed trips today
        final todayCompletedTrips = completedTrips.where((t) {
          final createdAt = t.createdAt ?? now;
          return createdAt.isAfter(todayStart);
        }).toList();

        final todayTripsCount = todayCompletedTrips.length;

        // Total earnings sum from all completed trips
        final totalEarningsSum = completedTrips.fold<double>(
          0.0,
          (sum, booking) => sum + booking.fare,
        );

        // Driver Rating: driver.rating or average from ratings list
        double ratingValue = driver?.rating ?? 5.0;
        if ((driver?.rating == null || driver!.rating == 0.0) && vm.ratings.isNotEmpty) {
          final sum = vm.ratings.fold<double>(0.0, (prev, r) => prev + r.rating);
          ratingValue = sum / vm.ratings.length;
        }

        // Trips list to display in recent trips section (prefer today, fallback to overall completed)
        final displayTrips = todayCompletedTrips.isNotEmpty ? todayCompletedTrips : completedTrips;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. WELCOME TEXT ON TOP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.welcomeBack} 👋',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          driver?.name.isNotEmpty == true ? driver!.name : l10n.partnerDriver,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: (driver?.profilePicUrl != null && driver!.profilePicUrl!.isNotEmpty)
                        ? NetworkImage(driver.profilePicUrl!)
                        : null,
                    child: (driver?.profilePicUrl == null || driver!.profilePicUrl!.isEmpty)
                        ? const Icon(Icons.person, color: AppColors.primary)
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. GO ONLINE / OFFLINE SWITCH WIDGET (FULLY RESPONSIVE FOR TELUGU & ALL LANGUAGES)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: vm.isOnline ? const Color(0xFFDCFCE7) : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: vm.isOnline ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: vm.isOnline
                                      ? AppColors.primary
                                      : AppColors.textMuted.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  vm.isOnline ? Icons.power_settings_new : Icons.power_off_rounded,
                                  color: vm.isOnline ? Colors.white : AppColors.textMuted,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vm.isOnline ? l10n.youAreOnlineCaps : l10n.youAreOfflineCaps,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: vm.isOnline ? AppColors.primaryDark : AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      vm.isOnline
                                          ? l10n.readyToReceiveRideRequests
                                          : l10n.switchOnlineToStartEarning,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: vm.isOnline,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            vm.toggleOnlineStatus(val, context);
                          },
                        ),
                      ],
                    ),
                    if (vm.isOnline) ...[
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.gpsTrackingActive,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. STATS ROW (TODAY TRIPS, TOTAL EARNINGS, RATINGS)
              Row(
                children: [
                  _HomeStatCard(
                    title: l10n.todayTrips,
                    value: l10n.tripsCount(todayTripsCount),
                    icon: Icons.local_shipping_rounded,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _HomeStatCard(
                    title: l10n.totalEarnings,
                    value: '₹ ${totalEarningsSum.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: const Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 8),
                  _HomeStatCard(
                    title: l10n.rating,
                    value: '${ratingValue.toStringAsFixed(1)} ★',
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFEAB308),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 4. RECENT TRIPS SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      todayCompletedTrips.isNotEmpty ? l10n.todaysRecentTrips : l10n.recentCompletedTrips,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.completedCount(displayTrips.length),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (displayTrips.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 36,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noCompletedTripsYet,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.switchOnlineToAcceptRides,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...displayTrips.map((booking) {
                  final shortId = booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase();
                  final formattedId = l10n.tripNumber(shortId);
                  final formattedTime = booking.createdAt != null
                      ? DateFormat('hh:mm a').format(booking.createdAt!)
                      : l10n.completed;

                  return _TodayTripCard(
                    tripId: formattedId,
                    pickup: booking.pickupAddress.isNotEmpty ? booking.pickupAddress : l10n.pickupLocation,
                    drop: booking.dropAddress.isNotEmpty ? booking.dropAddress : l10n.dropoffLocation,
                    fare: '₹ ${booking.fare.toStringAsFixed(2)}',
                    time: formattedTime,
                    paymentType: l10n.completed,
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _HomeStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _HomeStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: iconColor.withValues(alpha: 0.1),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayTripCard extends StatelessWidget {
  final String tripId;
  final String pickup;
  final String drop;
  final String fare;
  final String time;
  final String paymentType;

  const _TodayTripCard({
    required this.tripId,
    required this.pickup,
    required this.drop,
    required this.fare,
    required this.time,
    required this.paymentType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tripId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                fare,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.circle, color: AppColors.primary, size: 10),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pickup,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
            height: 12,
            width: 2,
            color: AppColors.divider,
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.error, size: 12),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  drop,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  paymentType,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
