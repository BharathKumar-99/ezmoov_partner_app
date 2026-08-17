import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

class DocumentUploadCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonText;
  final IconData iconData;
  final String? imagePath;
  final bool isRequired;
  final Function(ImageSource) onImageSelected;

  const DocumentUploadCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.buttonText,
    required this.iconData,
    this.imagePath,
    this.isRequired = true,
    required this.onImageSelected,
  });

  void _showPickerModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final takePhotoText = l10n?.takePhotoCamera ?? 'Take Photo with Camera';
    final chooseGalleryText = l10n?.chooseFromGallery ?? 'Choose from Gallery';

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
            Text(
              buttonText,
              style: const TextStyle(
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
              title: Text(takePhotoText),
              onTap: () {
                Navigator.pop(ctx);
                onImageSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFEF9C3),
                child: Icon(Icons.photo_library, color: Color(0xFFCA8A04)),
              ),
              title: Text(chooseGalleryText),
              onTap: () {
                Navigator.pop(ctx);
                onImageSelected(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool isUploaded = imagePath != null && imagePath!.isNotEmpty;
    final attachedText = l10n?.attached ?? 'Attached';
    final requiredText = l10n?.required ?? 'Required';
    final changeDocumentText = l10n?.changeDocument ?? 'Change Document';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUploaded ? const Color(0xFF09A234) : const Color(0xFFE5E7EB),
          width: isUploaded ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Icon + Title/Subtitle + Required Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUploaded ? const Color(0xFFDCFCE7) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isUploaded
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        iconData,
                        color: const Color(0xFF09A234),
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),

              // Title & Subtitle Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Required Badge
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUploaded ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUploaded ? attachedText : requiredText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUploaded ? const Color(0xFF166534) : const Color(0xFF854D0E),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Upload Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => _showPickerModal(context),
              icon: Icon(
                isUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                size: 18,
                color: isUploaded ? const Color(0xFF09A234) : AppColors.textSecondary,
              ),
              label: Text(
                isUploaded ? changeDocumentText : buttonText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isUploaded ? const Color(0xFF09A234) : AppColors.textSecondary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: isUploaded ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                side: BorderSide(
                  color: isUploaded ? const Color(0xFF09A234) : const Color(0xFFE5E7EB),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
