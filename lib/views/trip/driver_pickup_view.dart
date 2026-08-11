import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../models/booking_model.dart';
import '../../viewmodels/ride_request_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/gradient_button.dart';

class DriverPickupView extends StatefulWidget {
  final String bookingId;

  const DriverPickupView({
    super.key,
    required this.bookingId,
  });

  @override
  State<DriverPickupView> createState() => _DriverPickupViewState();
}

class _DriverPickupViewState extends State<DriverPickupView> {
  BookingModel? _booking;
  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  File? _pickupImageFile;
  bool _isUploadingPickup = false;
  File? _podImageFile;
  bool _isUploadingPod = false;
  Map<String, dynamic> _driverExtraCharges = {};
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
    _startStatusCheckTimer();
  }

  void _startStatusCheckTimer() {
    _statusCheckTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) return;
      final updatedBooking =
          await SupabaseService.instance.getBookingById(widget.bookingId);
      if (!mounted) return;
      if (updatedBooking != null) {
        if (updatedBooking.status == 'cancelled') {
          timer.cancel();
          _statusCheckTimer = null;
          if (mounted) {
            context.read<RideRequestViewModel>().clearActiveDriverTrip();
            context.read<ProfileViewModel>().setTripActive(false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Ride was cancelled by customer'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 4),
              ),
            );
            context.go('/home');
          }
          return;
        }
        if (_booking?.status != updatedBooking.status) {
          setState(() {
            _booking = updatedBooking;
          });
        }
      }
    });
  }

  Future<void> _loadBookingDetails() async {
    final booking =
        await SupabaseService.instance.getBookingById(widget.bookingId);
    if (mounted) {
      if (booking?.status == 'cancelled') {
        context.read<RideRequestViewModel>().clearActiveDriverTrip();
        context.read<ProfileViewModel>().setTripActive(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Ride was cancelled by customer'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
        context.go('/home');
        return;
      }
      setState(() {
        _booking = booking;
        _isLoading = false;
      });
      // Enable active trip location tracking (5-second interval + SnackBar)
      context.read<ProfileViewModel>().setTripActive(true, context);
    }
  }

  ProfileViewModel? _profileViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
    _profileViewModel?.setTripActive(false);
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer phone number not available'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    final Uri url = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make call: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendSms(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer phone number not available'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    final Uri url = Uri.parse('sms:$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open SMS: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openGoogleMaps({
    required double lat,
    required double lng,
    required String fallbackAddress,
  }) async {
    Uri url;
    if (lat != 0.0 && lng != 0.0) {
      url = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    } else if (fallbackAddress.isNotEmpty) {
      final encoded = Uri.encodeComponent(fallbackAddress);
      url = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$encoded&travelmode=driving');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location coordinates or address not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Google Maps: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(String newStatus, String successMessage) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await SupabaseService.instance
          .updateBookingStatus(widget.bookingId, newStatus);
      final reloadedBooking =
          await SupabaseService.instance.getBookingById(widget.bookingId);

      if (mounted) {
        setState(() {
          _booking = reloadedBooking ?? _booking?.copyWith(status: newStatus);
          _isUpdatingStatus = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (newStatus == 'completed') {
          context.read<ProfileViewModel>().setTripActive(false);
          context.read<RideRequestViewModel>().clearActiveDriverTrip();
          final driverId = _booking?.driverId;
          if (driverId != null && driverId.isNotEmpty) {
            context.read<ProfileViewModel>().fetchProfile(driverId, context);
            context.read<HomeViewModel>().loadDashboard(driverId);
          }
          _showCustomerRatingModal();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showStartTripOtpModal() {
    final otpController = TextEditingController();
    String? otpError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final expectedOtp = _booking?.otp;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_clock_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VERIFY START OTP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Ask customer for the 4-digit start PIN',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        hintText: '••••',
                        counterText: '',
                        errorText: otpError,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: (_) {
                        if (otpError != null) {
                          setModalState(() {
                            otpError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Proof of Pickup Photo Container
                    Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _pickupImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(_pickupImageFile!,
                                  fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 36,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Proof of Pickup Photo (MANDATORY)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: const Icon(Icons.camera_alt,
                                          size: 14),
                                      label: const Text('Camera',
                                          style: TextStyle(fontSize: 12)),
                                      onPressed: () async {
                                        final picked =
                                            await ImagePicker().pickImage(
                                          source: ImageSource.camera,
                                          imageQuality: 70,
                                        );
                                        if (picked != null) {
                                          setModalState(() {
                                            _pickupImageFile =
                                                File(picked.path);
                                            otpError = null;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: AppColors.border),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: const Icon(Icons.photo_library,
                                          size: 14,
                                          color: AppColors.textPrimary),
                                      label: const Text('Gallery',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textPrimary)),
                                      onPressed: () async {
                                        final picked =
                                            await ImagePicker().pickImage(
                                          source: ImageSource.gallery,
                                          imageQuality: 70,
                                        );
                                        if (picked != null) {
                                          setModalState(() {
                                            _pickupImageFile =
                                                File(picked.path);
                                            otpError = null;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      text: 'VERIFY & START TRIP',
                      icon: Icons.play_arrow_rounded,
                      isLoading: _isUploadingPickup,
                      onPressed: () async {
                        final inputOtp = otpController.text.trim();
                        if (inputOtp.length < 4) {
                          setModalState(() {
                            otpError = 'Please enter complete 4-digit OTP';
                          });
                          return;
                        }

                        if (_pickupImageFile == null) {
                          setModalState(() {
                            otpError =
                                'Proof of Pickup photo is MANDATORY before starting trip';
                          });
                          return;
                        }

                        if (expectedOtp != null &&
                            expectedOtp.isNotEmpty &&
                            inputOtp != expectedOtp) {
                          setModalState(() {
                            otpError =
                                'Incorrect OTP. Ask customer for start PIN.';
                          });
                          return;
                        }

                        setModalState(() {
                          _isUploadingPickup = true;
                        });
                        try {
                          await SupabaseService.instance.uploadPickupImage(
                            bookingId: widget.bookingId,
                            file: _pickupImageFile!,
                          );
                        } catch (e) {
                          debugPrint('Notice uploading pickup photo: $e');
                        }

                        if (context.mounted) {
                          Navigator.of(modalContext).pop();
                          _updateStatus(
                            'in_transit',
                            '🎉 OTP Verified & Pickup Photo Saved! Trip started.',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTripCancellationModal() {
    String selectedReason = 'Customer No-Show at Pickup';
    bool isCancelling = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final List<String> reasons = [
              'Customer No-Show at Pickup',
              'Oversized or Illegal Goods',
              'Vehicle Breakdown',
              'Unsafe Delivery Location',
              'Customer Requested Cancellation',
              'Other Operational Issue',
            ];

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CANCEL TRIP REQUEST',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Please select a cancellation reason',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...reasons.map((reason) {
                    final isSelected = selectedReason == reason;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedReason = reason;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.error.withValues(alpha: 0.08)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.error : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? AppColors.error
                                  : AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: isCancelling
                          ? null
                          : () async {
                              setModalState(() {
                                isCancelling = true;
                              });

                              try {
                                await SupabaseService.instance
                                    .cancelBookingWithReason(
                                  bookingId: widget.bookingId,
                                  reason: selectedReason,
                                );

                                if (context.mounted) {
                                  Navigator.of(modalContext).pop();
                                  context
                                      .read<RideRequestViewModel>()
                                      .clearActiveDriverTrip();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Trip cancelled.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  context.go('/home');
                                }
                              } catch (e) {
                                setModalState(() {
                                  isCancelling = false;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error cancelling trip: $e')),
                                  );
                                }
                              }
                            },
                      child: isCancelling
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'CONFIRM CANCELLATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddExtraChargesPopup(
      BuildContext dialogContext, StateSetter setParentModalState) {
    final chargeNameController = TextEditingController();
    final chargeAmountController = TextEditingController();
    Map<String, dynamic> tempChargesMap =
        Map<String, dynamic>.from(_driverExtraCharges);

    showDialog(
      context: dialogContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'ADD EXTRA CHARGES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add extra trip expenses (e.g. Toll, Gas, Parking):',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: chargeNameController,
                      decoration: InputDecoration(
                        labelText: 'Charge Name',
                        hintText: 'e.g. toll',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: chargeAmountController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[0-9]+(?:[.,][0-9]{1,2})?$')),
                      ],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Charge Number / Amount (₹)',
                        hintText: 'e.g. 55',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // + ADD Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('ADD',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        onPressed: () {
                          final name =
                              chargeNameController.text.trim().toLowerCase();
                          final amountText = chargeAmountController.text.trim();
                          final numVal = double.tryParse(amountText);

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please enter a charge name (e.g., toll)')),
                            );
                            return;
                          }
                          if (numVal == null || numVal <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please enter a valid numeric charge amount')),
                            );
                            return;
                          }

                          setDialogState(() {
                            tempChargesMap[name] =
                                numVal % 1 == 0 ? numVal.toInt() : numVal;
                            chargeNameController.clear();
                            chargeAmountController.clear();
                          });
                        },
                      ),
                    ),

                    if (tempChargesMap.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Added Charges List:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tempChargesMap.entries.map((entry) {
                          return Chip(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            label: Text(
                              '${entry.key}: ₹${entry.value}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            deleteIcon: const Icon(Icons.close,
                                size: 16, color: AppColors.error),
                            onDeleted: () {
                              setDialogState(() {
                                tempChargesMap.remove(entry.key);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setParentModalState(() {
                      _driverExtraCharges =
                          Map<String, dynamic>.from(tempChargesMap);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('SUBMIT',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProofOfDeliveryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROOF OF DELIVERY (POD)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Take a photo of delivered goods (MANDATORY)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Image Preview Box
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _podImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:
                                Image.file(_podImageFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined,
                                size: 44,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Proof of Delivery photo is MANDATORY',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon:
                                        const Icon(Icons.camera_alt, size: 16),
                                    label: const Text('Camera'),
                                    onPressed: () async {
                                      final picked =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 70,
                                      );
                                      if (picked != null) {
                                        setModalState(() {
                                          _podImageFile = File(picked.path);
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppColors.border),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.photo_library,
                                        size: 16, color: AppColors.textPrimary),
                                    label: const Text('Gallery',
                                        style: TextStyle(
                                            color: AppColors.textPrimary)),
                                    onPressed: () async {
                                      final picked =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 70,
                                      );
                                      if (picked != null) {
                                        setModalState(() {
                                          _podImageFile = File(picked.path);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),

                  if (!(_booking?.service?.toLowerCase().contains('bidding') ??
                      false)) ...[
                    const SizedBox(height: 16),

                    // Add Extra Charges Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          color: AppColors.primary),
                      label: const Text(
                        'ADD EXTRA CHARGES',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      onPressed: () {
                        _showAddExtraChargesPopup(modalContext, setModalState);
                      },
                    ),

                    if (_driverExtraCharges.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Driver Extra Charges:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showAddExtraChargesPopup(
                                        modalContext, setModalState);
                                  },
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: _driverExtraCharges.entries.map((e) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    '${e.key}: ₹${e.value}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 20),

                  GradientButton(
                    text: 'SUBMIT POD & UNLOAD CARGO',
                    icon: Icons.task_alt_rounded,
                    isLoading: _isUploadingPod,
                    onPressed: () async {
                      if (_podImageFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Proof of Delivery photo is MANDATORY before completing delivery.'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setModalState(() {
                        _isUploadingPod = true;
                      });
                      try {
                        if (_driverExtraCharges.isNotEmpty) {
                          await SupabaseService.instance.saveDriverCharges(
                            bookingId: widget.bookingId,
                            driverCharges: _driverExtraCharges,
                          );
                        }

                        await SupabaseService.instance.uploadPodImage(
                          bookingId: widget.bookingId,
                          file: _podImageFile!,
                        );
                      } catch (e) {
                        debugPrint('Notice uploading POD photo/charges: $e');
                      }

                      if (!modalContext.mounted) return;
                      Navigator.of(modalContext).pop();
                      await _loadBookingDetails();
                      await _updateStatus('drop_complete',
                          '📦 Cargo unloaded & POD submitted! Awaiting payment.');
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomerRatingModal() {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Column(
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFEAB308), size: 48),
                  SizedBox(height: 8),
                  Text(
                    'RATE THE CUSTOMER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'How was your experience with this trip?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      return IconButton(
                        icon: Icon(
                          starValue <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFEAB308),
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = starValue;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Add optional comment...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    GoRouter.of(context).go('/home');
                  },
                  child: const Text('SKIP'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final driverId =
                        context.read<ProfileViewModel>().driver?.id ?? '';
                    if (driverId.isNotEmpty && _booking != null) {
                      await SupabaseService.instance.submitCustomerRating(
                        bookingId: widget.bookingId,
                        customerId: _booking!.customerId,
                        driverId: driverId,
                        rating: selectedRating,
                        comment: commentController.text.trim(),
                      );
                    }
                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                      GoRouter.of(context).go('/home');
                    }
                  },
                  child: const Text('SUBMIT RATING',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = _booking?.status ?? 'accepted';
    final isTransit = currentStatus == 'in_transit' ||
        currentStatus == 'drop_complete' ||
        currentStatus == 'amount_paid';

    final navLat =
        isTransit ? (_booking?.dropLat ?? 0.0) : (_booking?.pickupLat ?? 0.0);
    final navLng =
        isTransit ? (_booking?.dropLng ?? 0.0) : (_booking?.pickupLng ?? 0.0);
    final navAddress = isTransit
        ? (_booking?.dropAddress ?? '')
        : (_booking?.pickupAddress ?? '');
    final navTargetLabel =
        isTransit ? 'Dropoff Location' : 'Customer Pickup Location';

    final customerPhone = _booking?.customerPhone ?? '';
    final customerName = _booking?.customerName ?? 'Customer';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentStatus == 'amount_paid'
              ? 'Payment Confirmed'
              : (currentStatus == 'drop_complete'
                  ? 'Awaiting Payment'
                  : (currentStatus == 'in_transit'
                      ? 'Trip in Transit'
                      : (currentStatus == 'arrived'
                          ? 'Arrived at Pickup'
                          : 'Pickup Navigation'))),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            tooltip: 'Cancel Trip',
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
            onPressed: _showTripCancellationModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: currentStatus == 'amount_paid'
                          ? const Color(0xFFDCFCE7)
                          : (currentStatus == 'drop_complete'
                              ? const Color(0xFFFEF3C7)
                              : (currentStatus == 'arrived'
                                  ? const Color(0xFFFEF3C7)
                                  : (currentStatus == 'in_transit'
                                      ? const Color(0xFFE0F2FE)
                                      : const Color(0xFFDCFCE7)))),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: currentStatus == 'amount_paid'
                            ? const Color(0xFF10B981)
                            : (currentStatus == 'drop_complete'
                                ? const Color(0xFFF59E0B)
                                : (currentStatus == 'arrived'
                                    ? const Color(0xFFF59E0B)
                                    : (currentStatus == 'in_transit'
                                        ? const Color(0xFF0284C7)
                                        : AppColors.primary))),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          currentStatus == 'amount_paid'
                              ? Icons.check_circle_rounded
                              : (currentStatus == 'drop_complete'
                                  ? Icons.payments_rounded
                                  : (currentStatus == 'arrived'
                                      ? Icons.location_city_rounded
                                      : (currentStatus == 'in_transit'
                                          ? Icons.local_shipping_rounded
                                          : Icons.navigation_rounded))),
                          color: currentStatus == 'amount_paid'
                              ? const Color(0xFF10B981)
                              : (currentStatus == 'drop_complete'
                                  ? const Color(0xFFD97706)
                                  : (currentStatus == 'arrived'
                                      ? const Color(0xFFD97706)
                                      : (currentStatus == 'in_transit'
                                          ? const Color(0xFF0284C7)
                                          : AppColors.primary))),
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentStatus == 'amount_paid'
                                    ? 'PAYMENT RECEIVED'
                                    : (currentStatus == 'drop_complete'
                                        ? 'UNLOADED / AWAITING PAYMENT'
                                        : (currentStatus == 'arrived'
                                            ? 'ARRIVED AT PICKUP LOCATION'
                                            : (currentStatus == 'in_transit'
                                                ? 'TRIP IN TRANSIT TO DROP POINT'
                                                : 'HEADING TO PICKUP'))),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: currentStatus == 'amount_paid'
                                      ? const Color(0xFF15803D)
                                      : (currentStatus == 'drop_complete'
                                          ? const Color(0xFFB45309)
                                          : (currentStatus == 'arrived'
                                              ? const Color(0xFFB45309)
                                              : (currentStatus == 'in_transit'
                                                  ? const Color(0xFF0369A1)
                                                  : AppColors.primaryDark))),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentStatus == 'amount_paid'
                                    ? 'Payment confirmed! Tap below to finalize trip completion.'
                                    : (currentStatus == 'drop_complete'
                                        ? 'Collect cash payment or wait for customer online payment.'
                                        : (currentStatus == 'arrived'
                                            ? 'Ask customer for 4-digit OTP to start trip'
                                            : (currentStatus == 'in_transit'
                                                ? 'On the way to dropoff destination'
                                                : 'Follow GPS route to customer location'))),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Customer Contact Quick Actions Card (Call / SMS)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.person,
                                    color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      customerPhone,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Call Customer',
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                              ),
                              icon: const Icon(Icons.call_rounded,
                                  color: AppColors.primary),
                              onPressed: () => _makePhoneCall(customerPhone),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Send SMS',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7)
                                    .withValues(alpha: 0.1),
                              ),
                              icon: const Icon(Icons.message_rounded,
                                  color: Color(0xFF0284C7)),
                              onPressed: () => _sendSms(customerPhone),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prominent Google Maps Navigation Card
                  InkWell(
                    onTap: () => _openGoogleMaps(
                      lat: navLat,
                      lng: navLng,
                      fallbackAddress: navAddress,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A73E8), Color(0xFF1557B0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF1A73E8).withValues(alpha: 0.3),
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
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.near_me_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'OPEN GOOGLE MAPS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Navigate to $navTargetLabel',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'GO',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A73E8),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Color(0xFF1A73E8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Booking Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'BOOKING #${widget.bookingId.length > 8 ? widget.bookingId.substring(0, 8).toUpperCase() : widget.bookingId}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                currentStatus.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Route (Pickup & Drop) with dedicated GMaps buttons
                        Row(
                          children: [
                            const Icon(Icons.circle,
                                color: AppColors.primary, size: 12),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _booking?.pickupAddress.isNotEmpty == true
                                    ? _booking!.pickupAddress
                                    : 'Customer Pickup Point',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Navigate to Pickup in GMaps',
                              icon: const Icon(Icons.directions_outlined,
                                  color: Color(0xFF1A73E8)),
                              onPressed: () => _openGoogleMaps(
                                lat: _booking?.pickupLat ?? 0.0,
                                lng: _booking?.pickupLng ?? 0.0,
                                fallbackAddress: _booking?.pickupAddress ?? '',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(left: 5, top: 2, bottom: 2),
                          height: 20,
                          width: 2,
                          color: AppColors.divider,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.error, size: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _booking?.dropAddress.isNotEmpty == true
                                    ? _booking!.dropAddress
                                    : 'Customer Dropoff Point',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Navigate to Dropoff in GMaps',
                              icon: const Icon(Icons.directions_outlined,
                                  color: Color(0xFF1A73E8)),
                              onPressed: () => _openGoogleMaps(
                                lat: _booking?.dropLat ?? 0.0,
                                lng: _booking?.dropLng ?? 0.0,
                                fallbackAddress: _booking?.dropAddress ?? '',
                              ),
                            ),
                          ],
                        ),

                        if (_booking != null && _booking!.fare > 0) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Delivery Fare:',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary),
                              ),
                              Text(
                                '₹ ${_booking!.amount?['total_price'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progressive Action Button (ARRIVED -> START TRIP (OTP) -> UNLOAD CARGO (POD) -> CASH PAYMENT -> CONFIRM COMPLETED)
                  if (currentStatus == 'accepted')
                    GradientButton(
                      text: 'ARRIVED AT PICKUP',
                      isLoading: _isUpdatingStatus,
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () => _updateStatus(
                        'arrived',
                        'Customer notified: Driver has arrived at pickup location!',
                      ),
                    )
                  else if (currentStatus == 'arrived')
                    GradientButton(
                      text: 'START TRIP (ENTER OTP)',
                      isLoading: _isUpdatingStatus,
                      icon: Icons.lock_clock_rounded,
                      onPressed: _showStartTripOtpModal,
                    )
                  else if (currentStatus == 'in_transit')
                    GradientButton(
                      text: 'UNLOAD CARGO & SUBMIT POD',
                      isLoading: _isUpdatingStatus,
                      icon: Icons.task_alt_rounded,
                      onPressed: _showProofOfDeliveryModal,
                    )
                  else if (currentStatus == 'drop_complete')
                    GradientButton(
                      text:
                          'Received Cash Payment (₹${(_booking?.amount?['total_price'] ?? 0).toStringAsFixed(0)})',
                      isLoading: _isUpdatingStatus,
                      icon: Icons.payments_rounded,
                      onPressed: () => _updateStatus(
                        'amount_paid',
                        'Cash Payment Received! Please confirm trip completion.',
                      ),
                    )
                  else if (currentStatus == 'amount_paid')
                    GradientButton(
                      text: 'Confirm Trip Completed',
                      isLoading: _isUpdatingStatus,
                      icon: Icons.check_circle_rounded,
                      onPressed: () => _updateStatus(
                        'completed',
                        '🎉 Delivery Completed Successfully!',
                      ),
                    )
                  else
                    GradientButton(
                      text: 'BACK TO HOME',
                      icon: Icons.home_rounded,
                      onPressed: () => context.go('/home'),
                    ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.cancel_outlined,
                              color: AppColors.error, size: 18),
                          label: const Text(
                            'Cancel Trip',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _showTripCancellationModal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => context.go('/home'),
                          child: const Text(
                            'Dashboard',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
