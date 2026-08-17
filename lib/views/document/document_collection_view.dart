import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../widgets/document_upload_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/language_selector_button.dart';

class DocumentCollectionView extends StatelessWidget {
  final String driverId;

  const DocumentCollectionView({
    super.key,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

                  // 2. Driving License
                  DocumentUploadCard(
                    title: l10n.drivingLicense,
                    buttonText: l10n.uploadDrivingLicense,
                    iconData: Icons.badge_rounded,
                    imagePath: vm.drivingLicensePath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.drivingLicense, source),
                  ),

                  // 3. Vehicle RC
                  DocumentUploadCard(
                    title: l10n.vehicleRc,
                    buttonText: l10n.uploadVehicleRc,
                    iconData: Icons.directions_car_rounded,
                    imagePath: vm.vehicleRcPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.vehicleRc, source),
                  ),

                  // 4. PAN Card
                  DocumentUploadCard(
                    title: l10n.panCard,
                    buttonText: l10n.uploadPanCard,
                    iconData: Icons.payment_rounded,
                    imagePath: vm.panCardPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.panCard, source),
                  ),

                  // 5. Vehicle Insurance
                  DocumentUploadCard(
                    title: l10n.vehicleInsurance,
                    buttonText: l10n.uploadVehicleInsurance,
                    iconData: Icons.shield_outlined,
                    imagePath: vm.insurancePath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.insurance, source),
                  ),

                  // 6. PUC Certificate
                  DocumentUploadCard(
                    title: l10n.pucCertificate,
                    buttonText: l10n.uploadPucCertificate,
                    iconData: Icons.assignment_outlined,
                    imagePath: vm.pucPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.puc, source),
                  ),

                  // 7. Vehicle Permit
                  DocumentUploadCard(
                    title: l10n.vehiclePermit,
                    buttonText: l10n.uploadVehiclePermit,
                    iconData: Icons.verified_user_outlined,
                    imagePath: vm.permitPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.permit, source),
                  ),

                  // 8. Fitness Certificate
                  DocumentUploadCard(
                    title: l10n.fitnessCertificate,
                    buttonText: l10n.uploadFitnessCertificate,
                    iconData: Icons.health_and_safety_outlined,
                    imagePath: vm.fitnessPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.fitness, source),
                  ),

                  // 9. Police Clearance Certificate
                  DocumentUploadCard(
                    title: l10n.policeClearanceCertificate,
                    buttonText: l10n.uploadPoliceClearance,
                    iconData: Icons.verified_outlined,
                    imagePath: vm.policeClearancePath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.policeClearance, source),
                  ),

                  // 10. Selfie with Vehicle
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
                    text: '${l10n.submitDocuments} (${vm.uploadedCount}/10)',
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
