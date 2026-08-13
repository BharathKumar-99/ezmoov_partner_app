import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../widgets/document_upload_card.dart';
import '../../widgets/gradient_button.dart';

class DocumentCollectionView extends StatelessWidget {
  final String driverId;

  const DocumentCollectionView({
    super.key,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Document Verification'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Consumer<DocumentViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Document Verification',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Upload required documentation for verification',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Aadhaar Card
                  DocumentUploadCard(
                    title: 'Aadhaar Card',
                    subtitle: 'Auto-Verified via DigiLocker API',
                    buttonText: 'Upload Aadhaar Card',
                    iconData: Icons.credit_card_rounded,
                    imagePath: vm.aadhaarPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.aadhaar, source),
                  ),

                  // 2. Driving License
                  DocumentUploadCard(
                    title: 'Driving License',
                    subtitle: 'Auto-Verified via API',
                    buttonText: 'Upload Driving License',
                    iconData: Icons.badge_rounded,
                    imagePath: vm.drivingLicensePath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.drivingLicense, source),
                  ),

                  // 3. Vehicle RC
                  DocumentUploadCard(
                    title: 'Vehicle RC',
                    subtitle: 'Auto-verified via vahan API',
                    buttonText: 'Upload Vehicle RC',
                    iconData: Icons.directions_car_rounded,
                    imagePath: vm.vehicleRcPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.vehicleRc, source),
                  ),

                  // 4. PAN Card
                  DocumentUploadCard(
                    title: 'PAN Card',
                    subtitle: 'Auto-verified via API',
                    buttonText: 'Upload PAN Card',
                    iconData: Icons.payment_rounded,
                    imagePath: vm.panCardPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.panCard, source),
                  ),

                  // 5. Vehicle Insurance
                  DocumentUploadCard(
                    title: 'Vehicle Insurance',
                    subtitle: 'Certificate upload',
                    buttonText: 'Upload Vehicle Insurance',
                    iconData: Icons.shield_outlined,
                    imagePath: vm.insurancePath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.insurance, source),
                  ),

                  // 6. PUC Certificate
                  DocumentUploadCard(
                    title: 'PUC Certificate',
                    subtitle: 'Certificate upload',
                    buttonText: 'Upload PUC Certificate',
                    iconData: Icons.assignment_outlined,
                    imagePath: vm.pucPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.puc, source),
                  ),

                  // 7. Vehicle Permit
                  DocumentUploadCard(
                    title: 'Vehicle Permit',
                    subtitle: 'Auto-Verified via Digilocker API',
                    buttonText: 'Upload Vehicle Permit',
                    iconData: Icons.verified_user_outlined,
                    imagePath: vm.permitPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.permit, source),
                  ),

                  // 8. Fitness Certificate
                  DocumentUploadCard(
                    title: 'Fitness Certificate',
                    subtitle: 'Auto-Verified via Digilocker API',
                    buttonText: 'Upload Fitness Certificate',
                    iconData: Icons.health_and_safety_outlined,
                    imagePath: vm.fitnessPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.fitness, source),
                  ),

                  // 9. Police Clearance Certificate
                  DocumentUploadCard(
                    title: 'Police Clearance Certificate',
                    subtitle: 'Official state citizen portal',
                    buttonText: 'Upload Police Clearence Certificate',
                    iconData: Icons.verified_outlined,
                    imagePath: vm.policeClearancePath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.policeClearance, source),
                  ),

                  // 10. Selfie with Vehicle
                  DocumentUploadCard(
                    title: 'Selfie with Vehicle',
                    subtitle: 'Clear photo of driver standing with vehicle',
                    buttonText: 'Upload Selfie with Vehicle',
                    iconData: Icons.camera_front_rounded,
                    imagePath: vm.selfieWithVehiclePath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.selfieWithVehicle, source),
                  ),

                  const SizedBox(height: 24),

                  GradientButton(
                    text: 'Submit Documents (${vm.uploadedCount}/10)',
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
