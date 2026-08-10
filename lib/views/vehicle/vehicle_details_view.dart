import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/vehicle_type_model.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class VehicleDetailsView extends StatelessWidget {
  final String driverId;

  const VehicleDetailsView({
    super.key,
    required this.driverId,
  });

  void _showVehicleTypePicker(BuildContext context, VehicleViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SELECT VEHICLE TYPE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose your vehicle category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: vm.vehicleTypes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final type = vm.vehicleTypes[index];
                  final isSelected = vm.selectedVehicleType?.id == type.id;
                  return _VehicleTypeCard(
                    vehicleType: type,
                    isSelected: isSelected,
                    onTap: () {
                      vm.selectVehicleType(type);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context, VehicleViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload RC Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: const Text('Take Photo with Camera'),
              onTap: () {
                Navigator.pop(ctx);
                vm.pickRcImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFEF9C3),
                child: Icon(Icons.photo_library, color: Color(0xFFCA8A04)),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                vm.pickRcImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Consumer<VehicleViewModel>(
          builder: (context, vm, child) {
            final selectedType = vm.selectedVehicleType;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Registration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Provide details of the vehicle you will drive with EZMoov.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // VEHICLE TYPE SELECTOR DROPDOWN
                        const Text(
                          'VEHICLE TYPE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () => _showVehicleTypePicker(context, vm),
                          borderRadius: BorderRadius.circular(16),
                          child: selectedType != null
                              ? _VehicleTypeCard(
                                  vehicleType: selectedType,
                                  isSelected: true,
                                  isDropdown: true,
                                  onTap: () => _showVehicleTypePicker(context, vm),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Select Vehicle Category',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                                    ],
                                  ),
                                ),
                        ),

                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: vm.vehicleNumberController,
                          label: 'Vehicle Registration Number',
                          hint: 'KA 01 AB 1234',
                          prefixIcon: Icons.directions_car_filled_rounded,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: vm.rcNumberController,
                          label: 'RC Number',
                          hint: 'RC9876543210',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Upload Registration Certificate (RC) Photo',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => _showImagePicker(context, vm),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: vm.rcPicPath != null ? AppColors.primary : AppColors.border,
                                width: vm.rcPicPath != null ? 2 : 1,
                              ),
                            ),
                            child: vm.rcPicPath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Image.file(
                                      File(vm.rcPicPath!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: AppColors.primary,
                                        size: 36,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tap to attach clear photo of RC',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        GradientButton(
                          text: 'Save & Continue',
                          isLoading: vm.isLoading,
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => vm.submitVehicleDetails(context, driverId),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  final VehicleTypeModel vehicleType;
  final bool isSelected;
  final bool isDropdown;
  final VoidCallback? onTap;

  const _VehicleTypeCard({
    required this.vehicleType,
    required this.isSelected,
    this.isDropdown = false,
    this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'electric_rickshaw':
        return Icons.electric_rickshaw_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      case 'fire_truck':
        return Icons.fire_truck_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      case 'local_shipping':
      default:
        return Icons.local_shipping_rounded;
    }
  }

  Color _getIconColor(String name) {
    if (name.contains('Mini 3W')) return const Color(0xFFCA8A04);
    if (name.contains('3 Wheeler')) return const Color(0xFF16A34A);
    if (name.contains('Tata Ace')) return const Color(0xFF0D9488);
    if (name.contains('Pickup 8ft')) return const Color(0xFF2563EB);
    if (name.contains('Pickup 1.7')) return const Color(0xFFEA580C);
    if (name.contains('14ft Container')) return const Color(0xFF4F46E5);
    return const Color(0xFFDC2626);
  }

  Color _getBgColor(String name) {
    if (name.contains('Mini 3W')) return const Color(0xFFFEF9C3);
    if (name.contains('3 Wheeler')) return const Color(0xFFDCFCE7);
    if (name.contains('Tata Ace')) return const Color(0xFFCCFBF1);
    if (name.contains('Pickup 8ft')) return const Color(0xFFDBEAFE);
    if (name.contains('Pickup 1.7')) return const Color(0xFFFFEDD5);
    if (name.contains('14ft Container')) return const Color(0xFFE0E7FF);
    return const Color(0xFFFEE2E2);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor(vehicleType.name);
    final bgColor = _getBgColor(vehicleType.name);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF16A34A) : AppColors.border,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Vehicle Icon in Rounded Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getIconData(vehicleType.iconName),
                    color: iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Vehicle Name & Capacity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleType.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Capacity: ${vehicleType.capacity}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Selection / Dropdown Indicator
                if (isDropdown)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  )
                else if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 24,
                    color: Color(0xFF16A34A),
                  )
                else
                  const Icon(
                    Icons.radio_button_unchecked_rounded,
                    size: 22,
                    color: AppColors.textMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
