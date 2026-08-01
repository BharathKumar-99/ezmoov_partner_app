import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/services/supabase_service.dart';
import '../models/bank_details_model.dart';
import 'profile_viewmodel.dart';

class BankDetailsViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController upiIdController = TextEditingController();

  String? _passbookPicPath;
  String? get passbookPicPath => _passbookPicPath;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> pickPassbookImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        _passbookPicPath = pickedFile.path;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to pick image: $e');
    }
  }

  Future<void> submitBankDetails(BuildContext context, String driverId) async {
    final accountHolder = accountHolderController.text.trim();
    final bankName = bankNameController.text.trim();
    final accountNumber = accountNumberController.text.trim();
    final ifscCode = ifscCodeController.text.trim();
    final upiId = upiIdController.text.trim();

    if (accountHolder.isEmpty) {
      if (context.mounted) _showSnackBar(context, 'Please enter Account Holder Name');
      return;
    }
    if (bankName.isEmpty) {
      if (context.mounted) _showSnackBar(context, 'Please enter Bank Name');
      return;
    }
    if (accountNumber.isEmpty || accountNumber.length < 8) {
      if (context.mounted) _showSnackBar(context, 'Please enter a valid Bank Account Number');
      return;
    }
    if (ifscCode.isEmpty || ifscCode.length < 4) {
      if (context.mounted) _showSnackBar(context, 'Please enter valid IFSC Code');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      String? passbookUrl;
      if (_passbookPicPath != null) {
        passbookUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _passbookPicPath!,
          fileName: 'passbook_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      final bankModel = BankDetailsModel(
        driverId: driverId,
        accountHolderName: accountHolder,
        bankName: bankName,
        accountNumber: accountNumber,
        ifscCode: ifscCode.toUpperCase(),
        upiId: upiId.isNotEmpty ? upiId : null,
        passbookPicUrl: passbookUrl,
      );

      await _supabaseService.saveBankDetails(bankModel);

      setLoading(false);
      if (context.mounted) {
        // Refresh central ProfileViewModel
        await Provider.of<ProfileViewModel>(context, listen: false).fetchProfile(driverId);
        if (context.mounted) {
          context.go('/verification-pending', extra: {'driverId': driverId});
        }
      }
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      if (context.mounted) _showSnackBar(context, 'Error saving bank details: $e');
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
    accountHolderController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    upiIdController.dispose();
    super.dispose();
  }
}
