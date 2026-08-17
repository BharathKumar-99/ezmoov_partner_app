import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/fcm_service.dart';
import '../models/driver_model.dart';
import 'profile_viewmodel.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  final TextEditingController loginPhoneController = TextEditingController();
  
  final TextEditingController signupNameController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPhoneController = TextEditingController();
  final TextEditingController signupReferralCodeController = TextEditingController();
  
  String _otpCode = '';
  String get otpCode => _otpCode;
  set otpCode(String val) {
    _otpCode = val;
    notifyListeners();
  }

  String? _profilePicPath;
  String? get profilePicPath => _profilePicPath;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoginFlow = true;
  bool get isLoginFlow => _isLoginFlow;

  DriverModel? _currentDriver;
  DriverModel? get currentDriver => _currentDriver;

  DriverModel? _signupDraftDriver;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> pickProfilePicture(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        _profilePicPath = pickedFile.path;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to pick image: $e');
    }
  }

  String _formatPhone(String rawPhone) {
    final clean = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '+91$clean';
    } else if (!clean.startsWith('+')) {
      return '+$clean';
    }
    return clean;
  }

  /// LOGIN FLOW: Check driver existence, if exists go to OTP else show SnackBar
  Future<void> handleLogin(BuildContext context) async {
    final rawPhone = loginPhoneController.text.trim();
    if (rawPhone.isEmpty || rawPhone.length < 10) {
      if (context.mounted) _showSnackBar(context, 'Please enter a valid phone number');
      return;
    }

    final formattedPhone = _formatPhone(rawPhone);
    setLoading(true);
    setError(null);

    try {
      final existingDriver = await _supabaseService.getDriverByPhone(formattedPhone);

      if (!context.mounted) return;

      if (existingDriver != null) {
        _currentDriver = existingDriver;
        _isLoginFlow = true;
        setLoading(false);
        context.push('/otp', extra: {'phone': formattedPhone});
      } else {
        setLoading(false);
        _showSnackBar(context, 'Driver not registered. Please Sign Up first.');
      }
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      if (context.mounted) _showSnackBar(context, 'Error checking account: $e');
    }
  }

  /// SIGNUP FLOW: Check driver existence, if exists show SnackBar else go to OTP
  Future<void> handleSignup(BuildContext context) async {
    final name = signupNameController.text.trim();
    final email = signupEmailController.text.trim();
    final rawPhone = signupPhoneController.text.trim();

    if (name.isEmpty) {
      if (context.mounted) _showSnackBar(context, 'Please enter your name');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      if (context.mounted) _showSnackBar(context, 'Please enter a valid email address');
      return;
    }
    if (rawPhone.isEmpty || rawPhone.length < 10) {
      if (context.mounted) _showSnackBar(context, 'Please enter a valid phone number');
      return;
    }

    final formattedPhone = _formatPhone(rawPhone);
    setLoading(true);
    setError(null);

    try {
      final existingDriver = await _supabaseService.getDriverByPhone(formattedPhone);

      if (!context.mounted) return;

      if (existingDriver != null) {
        setLoading(false);
        _showSnackBar(context, 'User already exists. Please login.');
      } else {
        String? profileUrl;
        if (_profilePicPath != null) {
          try {
            profileUrl = await _supabaseService.uploadImage(
              bucket: 'profile',
              filePath: _profilePicPath!,
              fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
          } catch (e) {
            debugPrint('Failed uploading profile image, continuing: $e');
          }
        }

        final referralInput = signupReferralCodeController.text.trim().toUpperCase();

        _signupDraftDriver = DriverModel(
          name: name,
          email: email,
          phone: formattedPhone,
          profilePicUrl: profileUrl,
          referredByCode: referralInput.isNotEmpty ? referralInput : null,
        );
        _isLoginFlow = false;
        setLoading(false);
        if (context.mounted) {
          context.push('/otp', extra: {'phone': formattedPhone});
        }
      }
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      if (context.mounted) _showSnackBar(context, 'Error checking registration: $e');
    }
  }

  Future<void> sendOtpToPhone(String phone) async {
    setLoading(true);
    try {
      await _supabaseService.sendPhoneOtp(phone);
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }

  Future<void> verifyOtp(BuildContext context, String phone) async {
    if (_otpCode.length < 6) {
      if (context.mounted) _showSnackBar(context, 'Please enter a valid 6-digit OTP');
      return;
    }

    setLoading(true);
    setError(null);

    // 1. Verify Phone OTP via Supabase Auth
    try {
      await _supabaseService.verifyPhoneOtp(phone, _otpCode);
    } catch (e) {
      debugPrint('Supabase SMS verification error: $e');
      setLoading(false);
      final msg = e is AuthException ? e.message : e.toString();
      setError(msg);
      if (context.mounted) {
        _showSnackBar(context, 'Verification failed: $msg');
      }
      return; // Do NOT move forward if OTP verification fails!
    }

    if (!context.mounted) return;

    try {
      if (_isLoginFlow) {
        var driver = _currentDriver ?? await _supabaseService.getDriverByPhone(phone);
        if (driver == null) {
          setLoading(false);
          if (context.mounted) _showSnackBar(context, 'Driver record not found.');
          return;
        }
        _currentDriver = driver;
        setLoading(false);

        if (driver.id != null) {
          FcmService.instance.saveUserFcmToken(driver.id!);
        }

        if (!context.mounted) return;

        // Sync with central ProfileViewModel
        if (driver.id != null) {
          await Provider.of<ProfileViewModel>(context, listen: false).fetchProfile(driver.id!);
        }

        if (!context.mounted) return;

        if (!driver.isVehicleAdded) {
          context.go('/vehicle-details', extra: {'driverId': driver.id});
        } else if (!driver.isDocumentsUploaded) {
          context.go('/document-collection', extra: {'driverId': driver.id});
        } else if (!driver.isBankDetailsAdded) {
          context.go('/bank-details', extra: {'driverId': driver.id});
        } else if (!driver.isFullyVerified) {
          context.go('/verification-pending', extra: {'driverId': driver.id});
        } else {
          context.go('/home', extra: {'driverId': driver.id});
        }
      } else {
        if (_signupDraftDriver != null) {
          final createdDriver = await _supabaseService.createDriver(_signupDraftDriver!);
          _currentDriver = createdDriver;
          setLoading(false);
          if (createdDriver.id != null) {
            FcmService.instance.saveUserFcmToken(createdDriver.id!);

            // Auto-generate referral code for new driver
            await _supabaseService.ensureDriverReferralCode(createdDriver);

            // Redeem inviter's referral code if provided
            if (_signupDraftDriver!.referredByCode != null &&
                _signupDraftDriver!.referredByCode!.isNotEmpty) {
              await _supabaseService.applyReferralCode(
                driverId: createdDriver.id!,
                referralCode: _signupDraftDriver!.referredByCode!,
              );
            }
          }
          if (context.mounted) {
            if (createdDriver.id != null) {
              await Provider.of<ProfileViewModel>(context, listen: false).fetchProfile(createdDriver.id!);
            }
            if (context.mounted) {
              context.go('/vehicle-details', extra: {'driverId': createdDriver.id});
            }
          }
        } else {
          setLoading(false);
          if (context.mounted) {
            _showSnackBar(context, 'Signup data lost. Please try again.');
            context.go('/signup');
          }
        }
      }
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      if (context.mounted) _showSnackBar(context, 'Error loading profile: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    loginPhoneController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPhoneController.dispose();
    super.dispose();
  }
}
