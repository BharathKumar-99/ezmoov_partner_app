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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Document Collection'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Consumer<DocumentViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Partner Verification Documents',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Upload clear photos of all 4 required certificates to activate your driver account.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. PUC Certificate
                  DocumentUploadCard(
                    title: 'PUC Certificate',
                    description: 'Pollution Under Control certificate',
                    imagePath: vm.pucPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.puc, source),
                  ),

                  // 2. Vehicle Permit
                  DocumentUploadCard(
                    title: 'Vehicle Permit',
                    description: 'Commercial vehicle transport permit',
                    imagePath: vm.permitPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.permit, source),
                  ),

                  // 3. Fitness Certificate
                  DocumentUploadCard(
                    title: 'Fitness Certificate',
                    description: 'Vehicle fitness & safety certificate',
                    imagePath: vm.fitnessPath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.fitness, source),
                  ),

                  // 4. Police Clearance Certificate
                  DocumentUploadCard(
                    title: 'Police Clearance Certificate',
                    description: 'Background verification certificate',
                    imagePath: vm.policeClearancePath,
                    onImageSelected: (source) =>
                        vm.pickDocument(DocumentType.policeClearance, source),
                  ),

                  const SizedBox(height: 24),

                  GradientButton(
                    text: 'Submit Documents',
                    isLoading: vm.isLoading,
                    icon: Icons.cloud_upload_rounded,
                    onPressed: () => vm.submitDocuments(context, driverId),
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
