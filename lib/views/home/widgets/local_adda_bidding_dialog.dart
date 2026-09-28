import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/booking_model.dart';
import '../../../viewmodels/ride_request_viewmodel.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../../viewmodels/wallet_viewmodel.dart';
import '../../../widgets/gradient_button.dart';
import '../../../widgets/route_location_tile.dart';

void showLocalAddaBiddingDialog(
    BuildContext context, BookingModel booking, String driverId) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom,
        ),
        child: LocalAddaBiddingDialog(booking: booking, driverId: driverId),
      );
    },
  ).then((_) {
    if (context.mounted) {
      Provider.of<RideRequestViewModel>(context, listen: false).onModalClosed();
    }
  });
}

class LocalAddaBiddingDialog extends StatefulWidget {
  final BookingModel booking;
  final String driverId;

  const LocalAddaBiddingDialog({
    super.key,
    required this.booking,
    required this.driverId,
  });

  @override
  State<LocalAddaBiddingDialog> createState() => _LocalAddaBiddingDialogState();
}

class _LocalAddaBiddingDialogState extends State<LocalAddaBiddingDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _bidController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // 3-Minute (180s) Countdown Timer
  static const int _totalTimerSeconds = 180;
  int _remainingSeconds = _totalTimerSeconds;
  Timer? _countdownTimer;

  late double _baseFare;
  double _selectedBidAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _baseFare = widget.booking.fare > 0
        ? widget.booking.fare
        : BookingModel.extractFare(widget.booking.toJson());
    if (_baseFare <= 0) _baseFare = 150.0; // Fallback estimate

    _selectedBidAmount = _baseFare;
    _bidController = TextEditingController(
      text: _baseFare.toStringAsFixed(0),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          // Timer expired: auto-decline and dismiss
          final vm = Provider.of<RideRequestViewModel>(context, listen: false);
          vm.declineRide(widget.booking.id);
          Navigator.of(context).pop();
        }
      }
    });
  }

  void _selectQuickBid(double amount) {
    setState(() {
      _selectedBidAmount = amount;
      _bidController.text = amount.toStringAsFixed(0);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _bidController.dispose();
    super.dispose();
  }

  String _formatTimerText(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor(double progress) {
    if (progress > 0.5) return const Color(0xFF09A234); // Green
    if (progress > 0.2) return const Color(0xFFD97706); // Amber
    return const Color(0xFFDC2626); // Red
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final timerProgress = _remainingSeconds / _totalTimerSeconds;
    final timerColor = _getTimerColor(timerProgress);

    return Consumer<RideRequestViewModel>(
      builder: (context, vm, child) {
        final activeBooking = vm.activeBroadcastBooking ?? widget.booking;
        final customerDisplayName = (activeBooking.customerName != null &&
                activeBooking.customerName!.isNotEmpty)
            ? activeBooking.customerName!
            : (l10n?.customer ?? 'Customer');

        final baseFare = activeBooking.fare > 0
            ? activeBooking.fare
            : BookingModel.extractFare(activeBooking.toJson());

        final estDistanceKm = vm.calculateTripDistance(activeBooking);

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull pill bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 1. Header with Badge & Live 3-Min Countdown Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE9FE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.gavel_rounded,
                                color: Color(0xFF7C3AED),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Local Adda Trip Request',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7C3AED),
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Real-time bidding trip',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary
                                          .withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Countdown Timer Badge with live progress indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: timerColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: timerColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                value: timerProgress,
                                strokeWidth: 2.2,
                                color: timerColor,
                                backgroundColor:
                                    timerColor.withValues(alpha: 0.2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatTimerText(_remainingSeconds),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: timerColor,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 2. Customer Info & Suggested Base Rate
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerDisplayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              if (widget.booking.customerPhone != null &&
                                  widget.booking.customerPhone!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined,
                                        size: 12, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.booking.customerPhone!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  'Customer trip: ${estDistanceKm.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Base Estimate',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              baseFare > 0
                                  ? '₹${baseFare.toStringAsFixed(0)}'
                                  : '₹0',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Multi-Stops Badge Indicator (if any)
                  if (activeBooking.hasStops) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.alt_route_rounded,
                              size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${activeBooking.stopsCount} intermediate stop${activeBooking.stopsCount > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 3. Route Container (Pickup -> Stops -> Drop with Live Distances)
                  Builder(
                    builder: (context) {
                      final driverPos = LocationService.instance.currentPosition;
                      double driverLat = driverPos?.latitude ?? 0.0;
                      double driverLng = driverPos?.longitude ?? 0.0;

                      if (driverLat == 0.0 || driverLng == 0.0) {
                        try {
                          final profileVm = Provider.of<ProfileViewModel>(context,
                              listen: false);
                          if (profileVm.latitude != 0.0 &&
                              profileVm.longitude != 0.0) {
                            driverLat = profileVm.latitude;
                            driverLng = profileVm.longitude;
                          }
                        } catch (_) {}
                      }

                      final pickupDistKm = (driverLat != 0.0 &&
                              driverLng != 0.0 &&
                              activeBooking.pickupLat != 0.0 &&
                              activeBooking.pickupLng != 0.0)
                          ? vm.calculateDistance(
                              driverLat,
                              driverLng,
                              activeBooking.pickupLat,
                              activeBooking.pickupLng,
                              applyRoadFactor: true,
                            )
                          : 0.0;

                      final dropDistKm = vm.calculateTripDistance(activeBooking);

                      // Trigger background fetch for Google Directions road distance if available
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (vm.getCachedRoadDistance(activeBooking.id) == null) {
                          vm.fetchBookingRoadDistance(activeBooking);
                        }
                      });

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RouteLocationTile(
                              type: LocationTileType.pickup,
                              address: activeBooking.pickupAddress,
                              distanceKm: pickupDistKm,
                            ),
                            const DashedLineConnector(
                                height: 18, color: Color(0xFF10B981)),
                            if (activeBooking.hasStops)
                              ...activeBooking.effectiveIntermediateStops
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final i = entry.key;
                                final idx = i + 1;
                                final stop = entry.value;

                                final double prevLat = (i == 0)
                                    ? activeBooking.pickupLat
                                    : activeBooking
                                        .effectiveIntermediateStops[i - 1]
                                        .latitude;
                                final double prevLng = (i == 0)
                                    ? activeBooking.pickupLng
                                    : activeBooking
                                        .effectiveIntermediateStops[i - 1]
                                        .longitude;

                                final stopDistKm = vm.calculateSegmentDistance(
                                  prevLat,
                                  prevLng,
                                  stop.latitude,
                                  stop.longitude,
                                );

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RouteLocationTile(
                                      type: LocationTileType.stop,
                                      address: stop.address,
                                      distanceKm: stopDistKm,
                                      stopIndex: idx,
                                    ),
                                    const DashedLineConnector(
                                        height: 18, color: Color(0xFFF59E0B)),
                                  ],
                                );
                              }),
                            RouteLocationTile(
                              type: LocationTileType.drop,
                              address: activeBooking.dropAddress,
                              distanceKm: dropDistKm,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 4. Quick Bid Selection Chips
                  const Text(
                    'QUICK QUOTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_baseFare - 30 > 0) ...[
                          _QuickBidChip(
                            label: '-₹30',
                            subLabel: '₹${(_baseFare - 30).toStringAsFixed(0)}',
                            isSelected: _selectedBidAmount == (_baseFare - 30),
                            onTap: () => _selectQuickBid(_baseFare - 30),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (_baseFare - 20 > 0) ...[
                          _QuickBidChip(
                            label: '-₹20',
                            subLabel: '₹${(_baseFare - 20).toStringAsFixed(0)}',
                            isSelected: _selectedBidAmount == (_baseFare - 20),
                            onTap: () => _selectQuickBid(_baseFare - 20),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _QuickBidChip(
                          label: '₹${_baseFare.toStringAsFixed(0)}',
                          subLabel: 'Base',
                          isSelected: _selectedBidAmount == _baseFare,
                          onTap: () => _selectQuickBid(_baseFare),
                        ),
                        const SizedBox(width: 8),
                        _QuickBidChip(
                          label: '+₹20',
                          subLabel: '₹${(_baseFare + 20).toStringAsFixed(0)}',
                          isSelected: _selectedBidAmount == (_baseFare + 20),
                          onTap: () => _selectQuickBid(_baseFare + 20),
                        ),
                        const SizedBox(width: 8),
                        _QuickBidChip(
                          label: '+₹30',
                          subLabel: '₹${(_baseFare + 30).toStringAsFixed(0)}',
                          isSelected: _selectedBidAmount == (_baseFare + 30),
                          onTap: () => _selectQuickBid(_baseFare + 30),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 5. Driver Bid Amount Input Field
                  const Text(
                    'YOUR BID QUOTE (₹)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _bidController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val.trim());
                      if (parsed != null) {
                        setState(() {
                          _selectedBidAmount = parsed;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: 'Enter your quote amount',
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF7C3AED), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a bid amount';
                      }
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid quote amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 6. Action Buttons: Decline & Submit Bid
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                                color: AppColors.border, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  vm.declineRide(widget.booking.id);
                                  Navigator.of(context).pop();
                                },
                          child: const Text(
                            'Decline',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GradientButton(
                          text: _selectedBidAmount > 0
                              ? 'Submit Bid (₹${_selectedBidAmount.toStringAsFixed(0)})'
                              : 'Submit Bid',
                          isLoading: _isSubmitting,
                          icon: Icons.send_rounded,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            final walletVm = Provider.of<WalletViewModel>(context, listen: false);
                            final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
                            final isFreeAdda = profileVm.isFreeDriverAdda || walletVm.isFreeDriverAdda;

                            if (!isFreeAdda && !walletVm.isLocalAddaPassActive) {
                              _showLocalAddaPassRequiredModal(context, widget.driverId, walletVm.localAddaMonthlyFee);
                              return;
                            }

                            final bidAmount =
                                double.parse(_bidController.text.trim());

                            final navigator = Navigator.of(context);

                            setState(() {
                              _isSubmitting = true;
                            });

                            final success = await vm.submitBid(
                              bookingId: widget.booking.id,
                              driverId: widget.driverId,
                              currentRate: baseFare,
                              driverBid: bidAmount,
                              context: context,
                            );

                            if (!mounted) return;
                            setState(() {
                              _isSubmitting = false;
                            });
                            if (success) {
                              navigator.pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLocalAddaPassRequiredModal(BuildContext context, String driverId, double fee) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.alt_route_rounded, color: Color(0xFF7C3AED), size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.localAddaPassRequired,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            l10n.localAddaPassRequiredDesc,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.cancel, style: const TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                Navigator.of(context).pop();
                context.push('/wallet?driverId=$driverId');
              },
              child: Text(l10n.viewWallet, style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogCtx);
                if (driverId.isNotEmpty) {
                  context.read<WalletViewModel>().payLocalAddaMonthlyFee(driverId: driverId, context: context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.flash_on_rounded, size: 16),
              label: Text(l10n.payMonthlyFeeWallet(fee.toStringAsFixed(0))),
            ),
          ],
        );
      },
    );
  }
}

class _QuickBidChip extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickBidChip({
    required this.label,
    required this.subLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF7C3AED);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.12)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? selectedColor : AppColors.border,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? selectedColor : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? selectedColor.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
