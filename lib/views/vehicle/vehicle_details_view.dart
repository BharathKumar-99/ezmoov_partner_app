import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
            final catItem = vm.selectedCatalogItem;

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

                        // 1. Wheel Count Dropdown
                        _buildDropdownField(
                          label: 'Wheel Count',
                          hint: 'Select Wheel Count',
                          value: vm.selectedWheelCount,
                          items: vm.wheelCountOptions,
                          icon: Icons.tire_repair_rounded,
                          onChanged: (val) => vm.selectWheelCount(val),
                        ),

                        const SizedBox(height: 16),

                        // 2. Brand Dropdown
                        _buildDropdownField(
                          label: 'Vehicle Brand',
                          hint: vm.selectedWheelCount == null
                              ? 'Select Wheel Count First'
                              : 'Select Brand',
                          value: vm.selectedBrand,
                          items: vm.brandOptions,
                          icon: Icons.branding_watermark_rounded,
                          enabled: vm.selectedWheelCount != null,
                          onChanged: (val) => vm.selectBrand(val),
                        ),

                        const SizedBox(height: 16),

                        // 3. Model Dropdown
                        _buildDropdownField(
                          label: 'Vehicle Model',
                          hint: vm.selectedBrand == null
                              ? 'Select Brand First'
                              : 'Select Model',
                          value: vm.selectedModel,
                          items: vm.modelOptions,
                          icon: Icons.local_shipping_rounded,
                          enabled: vm.selectedBrand != null,
                          onChanged: (val) => vm.selectModel(val),
                        ),

                        const SizedBox(height: 16),

                        // 4. Body Type Dropdown
                        _buildDropdownField(
                          label: 'Body Type',
                          hint: vm.selectedModel == null
                              ? 'Select Model First'
                              : 'Select Body Type',
                          value: vm.selectedBodyType,
                          items: vm.bodyTypeOptions,
                          icon: Icons.inventory_2_rounded,
                          enabled: vm.selectedModel != null,
                          onChanged: (val) => vm.selectBodyType(val),
                        ),

                        // Catalog Info summary badge if resolved
                        if (catItem != null) ...[
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
                                      '${catItem.brand} ${catItem.model}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Payload: ${catItem.payloadCapacity}',
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
                                      'Base: ₹${catItem.baseRate.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${catItem.ratePerKm.toStringAsFixed(0)} / km',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
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

                        // Registration Number
                        CustomTextField(
                          controller: vm.vehicleNumberController,
                          label: 'Vehicle Registration Number',
                          hint: 'TS 01 AB 1234',
                          prefixIcon: Icons.directions_car_filled_rounded,
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

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    bool enabled = true,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            filled: true,
            fillColor: enabled ? AppColors.background : const Color(0xFFF1F5F9),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted,
          ),
          dropdownColor: AppColors.surface,
          items: enabled
              ? items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList()
              : [],
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
