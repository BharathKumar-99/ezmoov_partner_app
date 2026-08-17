import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  void _showBodyDetailsPicker(BuildContext context, VehicleViewModel vm) {
    String tempSelection = vm.selectedBodyDetail;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Vehicle Body Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...vm.bodyDetailOptions.map((option) {
                    final isSelected = tempSelection == option;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          tempSelection = option;
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Continue',
                    onPressed: () {
                      vm.selectBodyDetail(tempSelection);
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<VehicleViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Card Container
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
                        // 1. Full Operational Address
                        CustomTextField(
                          controller: vm.addressController,
                          label: 'Full Operational Address *',
                          hint: 'House No, Street, City, State - Pincode',
                          prefixIcon: Icons.home_work_rounded,
                        ),
                        const SizedBox(height: 18),

                        // 2. Vehicle Registration Number
                        CustomTextField(
                          controller: vm.vehicleNumberController,
                          label: 'Vehicle Registration Number *',
                          hint: 'TS10FD8547',
                          prefixIcon: Icons.directions_car_filled_rounded,
                        ),
                        const SizedBox(height: 18),

                        // 3. Vehicle Owner Name (Optional)
                        CustomTextField(
                          controller: vm.ownerNameController,
                          label: 'Vehicle Owner Name (Optional)',
                          hint:
                              'Enter owner name if vehicle is registered to someone else',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 18),

                        // 4. TC / RC Permit Number
                        CustomTextField(
                          controller: vm.rcNumberController,
                          label: 'TC / RC Permit Number *',
                          hint: 'TC9876543210',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 18),

                        // 5. Upload RC Image Container Card
                        const Text(
                          'Upload RC Picture *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Vehicle RC Photo',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          vm.rcPicPath != null
                                              ? Icons.cloud_done_rounded
                                              : Icons.cloud_upload_outlined,
                                          size: 18,
                                          color: vm.rcPicPath != null
                                              ? AppColors.primary
                                              : AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            vm.rcPicPath != null
                                                ? 'Uploaded'
                                                : 'Tap to attach clear photo of RC',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: vm.rcPicPath != null
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: vm.rcPicPath != null
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded,
                                    color: AppColors.primary),
                                onPressed: () => _showImagePicker(context, vm),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 6. Select the City of Operation (Only Hyderabad)
                        const Text(
                          'Select the city of operation',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: 'Hyderabad',
                          isExpanded: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.location_city_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
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
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'Hyderabad',
                              child: Text(
                                'Hyderabad',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) vm.selectCity(val);
                          },
                        ),
                        const SizedBox(height: 18),

                        // 7. Select Vehicle Type (Truck & 3W)
                        const Text(
                          'Select Vehicle Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (vm.selectedCategory == null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildCategoryCard(
                                  title: 'Truck',
                                  icon: Icons.local_shipping_rounded,
                                  isSelected: false,
                                  onTap: () => vm.selectCategory('Truck'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCategoryCard(
                                  title: '3W',
                                  icon: Icons.electric_rickshaw_rounded,
                                  isSelected: false,
                                  onTap: () => vm.selectCategory('3W'),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
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
                                Row(
                                  children: [
                                    Icon(
                                      vm.selectedCategory == 'Truck'
                                          ? Icons.local_shipping_rounded
                                          : Icons.electric_rickshaw_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      vm.selectedCategory == 'Truck'
                                          ? 'Truck'
                                          : '3W',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded,
                                      color: AppColors.primary),
                                  onPressed: () {
                                    vm.selectCategoryAgain();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Additional fields when vehicle category is selected
                        if (vm.selectedCategory != null) ...[
                          const SizedBox(height: 18),

                          // 8. Vehicle Body Details (For Truck)
                          if (vm.selectedCategory == 'Truck') ...[
                            const Text(
                              'Select Vehicle Body Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _showBodyDetailsPicker(context, vm),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      vm.selectedBodyDetail,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Icon(Icons.edit_rounded,
                                        color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          // 9. Vehicle Body Type Selection (Open / Closed)
                          const Text(
                            'Select the vehicle body type',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildBodyTypeCard(
                                  title: 'Open',
                                  icon: FontAwesomeIcons.truckPickup,
                                  isSelected: vm.selectedBodyType == 'Open',
                                  onTap: () => vm.selectBodyType('Open'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildBodyTypeCard(
                                  title: 'Closed',
                                  icon: FontAwesomeIcons.truck,
                                  isSelected: vm.selectedBodyType == 'Closed',
                                  onTap: () => vm.selectBodyType('Closed'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // 10. Vehicle Fuel Type Selection Dropdown
                          const Text(
                            'Select the vehicle fuel type',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: vm.selectedFuelType,
                            isExpanded: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.local_gas_station_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
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
                            items: vm.fuelTypes.map((fuel) {
                              return DropdownMenuItem<String>(
                                value: fuel,
                                child: Text(
                                  fuel,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) vm.selectFuelType(val);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Gradient Submit Button
                  GradientButton(
                    text: 'Save & Continue',
                    isLoading: vm.isLoading,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => vm.submitVehicleDetails(context, driverId),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color:
                    isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyTypeCard({
    required String title,
    required dynamic icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            FaIcon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color:
                    isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
