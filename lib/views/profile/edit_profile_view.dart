import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/gradient_button.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _selectedImageFile;
  String? _uploadedProfileUrl;
  bool _isUploadingImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = context.read<ProfileViewModel>();
      final driver = profileVM.driver;
      if (driver != null) {
        _nameController.text = driver.name;
        _phoneController.text = driver.phone;
        _emailController.text = driver.email;
        _addressController.text = driver.address ?? '';
        _uploadedProfileUrl = driver.profilePicUrl;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _selectedImageFile = File(picked.path);
        });
        await _uploadProfileImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImageFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final profileVM = context.read<ProfileViewModel>();
      final driverId = profileVM.driver?.id ?? 'driver';
      final fileName = 'profile_${driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final publicUrl = await SupabaseService.instance.uploadImage(
        bucket: 'documents',
        filePath: _selectedImageFile!.path,
        fileName: fileName,
      );

      setState(() {
        _uploadedProfileUrl = publicUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture uploaded successfully!'),
            backgroundColor: Color(0xFF09A234),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading profile picture: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Profile Picture 📸',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose how you want to update your profile photo',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                    label: const Text('Camera'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.photo_library_rounded, color: AppColors.textSecondary),
                    label: const Text('Gallery'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final profileVM = context.read<ProfileViewModel>();
    final driverId = profileVM.driver?.id;
    if (driverId == null || driverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver ID not found!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final email = _emailController.text.trim();
      final address = _addressController.text.trim();

      await SupabaseService.instance.updateDriverProfile(
        driverId: driverId,
        profilePicUrl: _uploadedProfileUrl,
        email: email,
        address: address,
      );

      if (mounted) {
        await profileVM.fetchProfile(driverId, context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Profile updated successfully!'),
            backgroundColor: Color(0xFF09A234),
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Profile Avatar with Camera Edit Badge
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerModal,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          backgroundImage: _selectedImageFile != null
                              ? FileImage(_selectedImageFile!) as ImageProvider
                              : (_uploadedProfileUrl != null && _uploadedProfileUrl!.isNotEmpty
                                  ? NetworkImage(_uploadedProfileUrl!)
                                  : null),
                          child: (_selectedImageFile == null &&
                                  (_uploadedProfileUrl == null || _uploadedProfileUrl!.isEmpty))
                              ? const Icon(Icons.person, color: AppColors.primary, size: 60)
                              : null,
                        ),
                      ),
                    ),
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _showImagePickerModal,
                icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                label: const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Driver Name Field (Disabled / Display Only)
              TextFormField(
                controller: _nameController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Phone Number Field (Disabled / Verified)
              TextFormField(
                controller: _phoneController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.textMuted),
                  suffixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 18),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Email Address Field (Editable)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'enter your email address',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surface,
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
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Email address cannot be empty';
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Operating / Home Address Field (Editable)
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter your residential / business address',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.location_on_outlined, color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
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
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Address cannot be empty';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Save Changes Button
              GradientButton(
                text: 'SAVE PROFILE CHANGES',
                isLoading: _isSaving || _isUploadingImage,
                icon: Icons.check_circle_outline_rounded,
                onPressed: _saveProfileChanges,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
