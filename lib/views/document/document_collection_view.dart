import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/document_upload_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/language_selector_button.dart';

class DocumentCollectionView extends StatelessWidget {
  final String driverId;
  final String? vehicleCategory;

  const DocumentCollectionView({
    super.key,
    required this.driverId,
    this.vehicleCategory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileVm = context.read<ProfileViewModel>();
    final vehicleType = profileVm.vehicle?.vehicleType?.toLowerCase() ?? '';
    final vehicleTypeId = profileVm.vehicle?.vehicleTypeId ?? '';
    // vehicleTypeId '2' = '3 Wheeler' in DB (vehicle_type name not joined in query)
    final isThreeWheeler = vehicleTypeId == '2' ||
        vehicleType.contains('3') ||
        vehicleType.contains('three') ||
        vehicleType.contains('rickshaw') ||
        vehicleType.contains('auto') ||
        vehicleCategory == '3W';
    final totalDocs = isThreeWheeler ? 6 : 12;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(l10n.documentVerification),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: LanguageSelectorButton(isCompact: true),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<DocumentViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.documentVerification,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.uploadRequiredDocumentsSubtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Aadhaar Card
                  DocumentUploadCard(
                    title: l10n.aadhaarCard,
                    buttonText: l10n.uploadAadhaarCard,
                    iconData: Icons.credit_card_rounded,
                    imagePath: vm.aadhaarPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.aadhaar, source),
                  ),

                  // 2. Driving License (Front)
                  if (!isThreeWheeler)
                    DocumentUploadCard(
                      title: l10n.drivingLicenseFront,
                      buttonText: l10n.uploadDrivingLicenseFront,
                      iconData: Icons.badge_rounded,
                      imagePath: vm.drivingLicensePath,
                      onImageSelected: (source) =>
                          vm.pickDocument(DocumentType.drivingLicense, source),
                    ),

                  // 3. Driving License (Back)
                  if (!isThreeWheeler)
                    DocumentUploadCard(
                      title: l10n.drivingLicenseBack,
                      buttonText: l10n.uploadDrivingLicenseBack,
                      iconData: Icons.badge_outlined,
                      imagePath: vm.dlBackPath,
                      onImageSelected: (source) =>
                          vm.pickDocument(DocumentType.dlBack, source),
                    ),

                  // 4. Vehicle RC (Front)
                  DocumentUploadCard(
                    title: l10n.vehicleRcFront,
                    buttonText: l10n.uploadVehicleRcFront,
                    iconData: Icons.directions_car_rounded,
                    imagePath: vm.vehicleRcPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.vehicleRc, source),
                  ),

                  // 5. Vehicle RC (Back)
                  DocumentUploadCard(
                    title: l10n.vehicleRcBack,
                    buttonText: l10n.uploadVehicleRcBack,
                    iconData: Icons.directions_car_outlined,
                    imagePath: vm.rcBackPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.rcBack, source),
                  ),

                  // 6. PAN Card
                  DocumentUploadCard(
                    title: l10n.panCard,
                    buttonText: l10n.uploadPanCard,
                    iconData: Icons.payment_rounded,
                    imagePath: vm.panCardPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.panCard, source),
                  ),

                  // 7. Vehicle Insurance
                  DocumentUploadCard(
                    title: l10n.vehicleInsurance,
                    buttonText: l10n.uploadVehicleInsurance,
                    iconData: Icons.shield_outlined,
                    imagePath: vm.insurancePath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.insurance, source),
                  ),

                  // 8. PUC Certificate
                  DocumentUploadCard(
                    title: l10n.pucCertificate,
                    buttonText: l10n.uploadPucCertificate,
                    iconData: Icons.assignment_outlined,
                    imagePath: vm.pucPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.puc, source),
                  ),

                  // 9. Vehicle Permit
                  if (!isThreeWheeler)
                    DocumentUploadCard(
                      title: l10n.vehiclePermit,
                      buttonText: l10n.uploadVehiclePermit,
                      iconData: Icons.verified_user_outlined,
                      imagePath: vm.permitPath,
                      onImageSelected: (source) =>
                          vm.pickDocument(DocumentType.permit, source),
                    ),

                  // 10. Fitness Certificate
                  if (!isThreeWheeler)
                    DocumentUploadCard(
                      title: l10n.fitnessCertificate,
                      buttonText: l10n.uploadFitnessCertificate,
                      iconData: Icons.health_and_safety_outlined,
                      imagePath: vm.fitnessPath,
                      onImageSelected: (source) =>
                          vm.pickDocument(DocumentType.fitness, source),
                    ),

                  // 11. Police Clearance Certificate
                  if (!isThreeWheeler)
                    DocumentUploadCard(
                      title: l10n.policeClearanceCertificate,
                      buttonText: l10n.uploadPoliceClearance,
                      iconData: Icons.verified_outlined,
                      imagePath: vm.policeClearancePath,
                      onImageSelected: (source) =>
                          vm.pickDocument(DocumentType.policeClearance, source),
                    ),

                  // 12. Selfie with Vehicle
                  if (!isThreeWheeler)
                    DocumentUploadCard(
                      title: l10n.selfieWithVehicle,
                      buttonText: l10n.uploadSelfieWithVehicle,
                      iconData: Icons.camera_front_rounded,
                      imagePath: vm.selfieWithVehiclePath,
                      onImageSelected: (source) =>
                          vm.pickDocument(DocumentType.selfieWithVehicle, source),
                    ),

                  const SizedBox(height: 24),

                  GradientButton(
                    text: '${l10n.submitDocuments} (${vm.uploadedCount}/$totalDocs)',
                    isLoading: vm.isLoading,
                    icon: Icons.cloud_upload_rounded,
                    onPressed: () => vm.submitDocuments(context, driverId),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
