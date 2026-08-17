import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../viewmodels/wallet_viewmodel.dart';
import '../../../viewmodels/ride_request_viewmodel.dart';
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
      if (!mounted) return;
      final profileVm = context.read<ProfileViewModel>();
      if (profileVm.driver?.id != null && mounted) {
        context.read<HomeViewModel>().fetchEarnings(profileVm.driver!.id!);
        context.read<WalletViewModel>().fetchWalletData(profileVm.driver!.id!);
      }
    });
  }

  void _showPassRequiredDialog(BuildContext context, String driverId, double fee) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 24),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Daily Pass Required ⚠️',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'You must pay your daily fee (₹${fee.toStringAsFixed(0)}) to activate your 24-hour pass before going online.',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogCtx);
                if (driverId.isNotEmpty) {
                  context.read<WalletViewModel>().payDailyFee(driverId: driverId, context: context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF09A234),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.flash_on_rounded, size: 16),
              label: Text('Pay Daily Fee (₹${fee.toStringAsFixed(0)})'),
            ),
          ],
        );
      },
    );
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

        final homeVm = context.watch<HomeViewModel>();

        // Total earnings sum from public.earning (fallback to completed trips)
        final totalEarningsSum = homeVm.driverEarnings.isNotEmpty
            ? homeVm.totalEarnings
            : completedTrips.fold<double>(
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

              // ONGOING ACTIVE TRIP RESUME BANNER CARD
              Builder(
                builder: (context) {
                  final activeTrip = context.watch<RideRequestViewModel>().activeDriverTrip;
                  if (activeTrip == null) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: InkWell(
                      onTap: () {
                        context.go('/driver/pickup/${activeTrip.id}');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.navigation_rounded,
                                  color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TRIP IN PROGRESS 🚗',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade400,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activeTrip.dropAddress.isNotEmpty
                                        ? activeTrip.dropAddress
                                        : 'Active Booking Route',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                context.go('/driver/pickup/${activeTrip.id}');
                              },
                              child: const Text('RESUME TRIP',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              Consumer<WalletViewModel>(
                builder: (context, walletVm, child) {
                  if (!walletVm.isBlocked) return const SizedBox.shrink();

                  final isPassRequired = walletVm.blockReason == 'daily_pass_required';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPassRequired ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPassRequired ? Colors.amber.shade400 : Colors.red.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPassRequired ? Icons.flash_on_rounded : Icons.block_rounded,
                              color: isPassRequired ? Colors.amber.shade900 : Colors.red.shade700,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isPassRequired
                                    ? '24-Hour Pass Required ⚠️'
                                    : 'Orders Paused for Today ⛔',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isPassRequired ? Colors.amber.shade900 : Colors.red.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isPassRequired
                              ? 'Your 24-hour daily pass is expired or unpaid. Pay ₹${walletVm.vehicleDailyFee.toStringAsFixed(0)} to activate your pass and go online for 24 hours.'
                              : 'You rejected 2 order requests today. Order allocation is paused for the remainder of today.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isPassRequired ? Colors.amber.shade900 : Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isPassRequired
                                ? (walletVm.isPayingFee
                                    ? null
                                    : () {
                                        if (driver?.id != null) {
                                          walletVm.payDailyFee(driverId: driver!.id!, context: context);
                                        }
                                      })
                                : () {
                                    context.push('/wallet?driverId=${driver?.id ?? ''}');
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPassRequired ? const Color(0xFF09A234) : Colors.red.shade700,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: isPassRequired
                                ? (walletVm.isPayingFee
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.flash_on_rounded, size: 18))
                                : const Icon(Icons.info_outline_rounded, size: 18),
                            label: Text(
                              isPassRequired
                                  ? (walletVm.isPayingFee
                                      ? 'Activating Pass...'
                                      : 'Pay Daily Fee (₹${walletVm.vehicleDailyFee.toStringAsFixed(0)})')
                                  : 'View Wallet Details',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

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
                                  color: vm.isTogglingOnline
                                      ? AppColors.primary.withValues(alpha: 0.15)
                                      : (vm.isOnline
                                          ? AppColors.primary
                                          : AppColors.textMuted.withValues(alpha: 0.2)),
                                  shape: BoxShape.circle,
                                ),
                                child: vm.isTogglingOnline
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : Icon(
                                        vm.isOnline
                                            ? Icons.power_settings_new
                                            : Icons.power_off_rounded,
                                        color: vm.isOnline
                                            ? Colors.white
                                            : AppColors.textMuted,
                                        size: 24,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vm.isTogglingOnline
                                          ? 'UPDATING STATUS...'
                                          : (vm.isOnline
                                              ? l10n.youAreOnlineCaps
                                              : l10n.youAreOfflineCaps),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: vm.isTogglingOnline || vm.isOnline
                                            ? AppColors.primaryDark
                                            : AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      vm.isTogglingOnline
                                          ? 'Updating online status...'
                                          : (vm.isOnline
                                              ? l10n.readyToReceiveRideRequests
                                              : l10n.switchOnlineToStartEarning),
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
                        vm.isTogglingOnline
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : Switch.adaptive(
                                value: vm.isOnline,
                                activeTrackColor: AppColors.primary,
                                onChanged: (val) {
                                  final walletVm =
                                      context.read<WalletViewModel>();
                                  if (val && !walletVm.isPassActive) {
                                    _showPassRequiredDialog(
                                        context,
                                        driver?.id ?? '',
                                        walletVm.vehicleDailyFee);
                                    return;
                                  }
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
                    hasStops: booking.hasStops,
                    stopsCount: booking.stopsCount,
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
  final bool hasStops;
  final int stopsCount;

  const _TodayTripCard({
    required this.tripId,
    required this.pickup,
    required this.drop,
    required this.fare,
    required this.time,
    required this.paymentType,
    this.hasStops = false,
    this.stopsCount = 0,
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
                child: Row(
                  children: [
                    Flexible(
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
                    if (hasStops) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Text(
                          '+$stopsCount STOPS',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
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
