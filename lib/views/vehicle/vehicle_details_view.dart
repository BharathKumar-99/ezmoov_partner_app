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
                    'Select vehicle catalog specifications and provide registration details.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        const Text(
                          'VEHICLE SPECIFICATIONS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 1. Vehicle Type Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vehicle Type',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<VehicleTypeModel>(
                              initialValue: vm.selectedVehicleType,
                              isExpanded: true,
                              itemHeight: 58.0,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.local_shipping_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                hintText: 'Select Vehicle Type',
                                hintStyle: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 2),
                                ),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textMuted,
                              ),
                              dropdownColor: AppColors.surface,
                              selectedItemBuilder: (BuildContext context) {
                                return vm.vehicleTypes.map<Widget>((vType) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${vType.name} (${vType.capacity})',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList();
                              },
                              items: vm.vehicleTypes.map((vType) {
                                return DropdownMenuItem<VehicleTypeModel>(
                                  value: vType,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _getVehicleIcon(vType.iconName.isEmpty ? vType.name : vType.iconName),
                                            color: AppColors.primary,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${vType.name} (${vType.capacity})',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Base: ₹${vType.baseFare.toStringAsFixed(0)} • Daily Fee: ₹${vType.dailyFee.toStringAsFixed(0)} / 24h',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) => vm.selectVehicleType(val),
                            ),
                          ],
                        ),

                        // Selected Vehicle Type info badge
                        if (vm.selectedVehicleType != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vm.selectedVehicleType!.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Payload: ${vm.selectedVehicleType!.capacity}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Base Fare: ₹${vm.selectedVehicleType!.baseFare.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Daily Fee: ₹${vm.selectedVehicleType!.dailyFee.toStringAsFixed(0)} / 24 hrs',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 24),

                        // Driver Full Address
                        CustomTextField(
                          controller: vm.addressController,
                          label: 'Full Operational Address',
                          hint: 'House No, Street, City, State - Pincode',
                          prefixIcon: Icons.home_work_rounded,
                        ),
                        const SizedBox(height: 16),

                        // Registration Number
                        CustomTextField(
                          controller: vm.vehicleNumberController,
                          label: 'Vehicle Registration Number',
                          hint: 'TS 01 AB 1234',
                          prefixIcon: Icons.directions_car_filled_rounded,
                        ),
                        const SizedBox(height: 16),

                        // Vehicle Owner Name (Optional)
                        CustomTextField(
                          controller: vm.ownerNameController,
                          label: 'Vehicle Owner Name (Optional)',
                          hint: 'Enter owner name if vehicle is registered to someone else',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),

                        // TC / Permit / RC Number
                        CustomTextField(
                          controller: vm.rcNumberController,
                          label: 'TC / RC Permit Number',
                          hint: 'TC9876543210',
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
                                color: vm.rcPicPath != null
                                    ? AppColors.primary
                                    : AppColors.border,
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
                          onPressed: () =>
                              vm.submitVehicleDetails(context, driverId),
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

  IconData _getVehicleIcon(String name) {
    switch (name.toLowerCase()) {
      case 'two_wheeler':
      case '2 wheeler':
        return Icons.two_wheeler_rounded;
      case 'electric_rickshaw':
      case '3 wheeler':
      case 'mini 3 wheeler':
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
}
