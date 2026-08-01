import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/services/supabase_service.dart';
import '../models/document_model.dart';
import 'profile_viewmodel.dart';

enum DocumentType { puc, permit, fitness, policeClearance }

class DocumentViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  String? _pucPath;
  String? _permitPath;
  String? _fitnessPath;
  String? _policeClearancePath;

  String? get pucPath => _pucPath;
  String? get permitPath => _permitPath;
  String? get fitnessPath => _fitnessPath;
  String? get policeClearancePath => _policeClearancePath;

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

  Future<void> pickDocument(DocumentType type, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        switch (type) {
          case DocumentType.puc:
            _pucPath = pickedFile.path;
            break;
          case DocumentType.permit:
            _permitPath = pickedFile.path;
            break;
          case DocumentType.fitness:
            _fitnessPath = pickedFile.path;
            break;
          case DocumentType.policeClearance:
            _policeClearancePath = pickedFile.path;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to pick document: $e');
    }
  }

  bool get areAllDocumentsUploaded =>
      _pucPath != null &&
      _permitPath != null &&
      _fitnessPath != null &&
      _policeClearancePath != null;

  Future<void> submitDocuments(BuildContext context, String driverId) async {
    if (!areAllDocumentsUploaded) {
      if (context.mounted) {
        _showSnackBar(context, 'Please upload all 4 required certificates.');
      }
      return;
    }

    setLoading(true);
    setError(null);

    try {
      final pucUrl = await _supabaseService.uploadImage(
        bucket: 'documents',
        filePath: _pucPath!,
        fileName: 'puc_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final permitUrl = await _supabaseService.uploadImage(
        bucket: 'documents',
        filePath: _permitPath!,
        fileName: 'permit_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final fitnessUrl = await _supabaseService.uploadImage(
        bucket: 'documents',
        filePath: _fitnessPath!,
        fileName: 'fitness_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final policeClearanceUrl = await _supabaseService.uploadImage(
        bucket: 'documents',
        filePath: _policeClearancePath!,
        fileName: 'police_clearance_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final docModel = DocumentModel(
        driverId: driverId,
        pucUrl: pucUrl,
        permitUrl: permitUrl,
        fitnessUrl: fitnessUrl,
        policeClearanceUrl: policeClearanceUrl,
        status: 'pending',
      );

      await _supabaseService.saveDocuments(docModel);

      setLoading(false);
      if (context.mounted) {
        // Refresh central ProfileViewModel
        await Provider.of<ProfileViewModel>(context, listen: false).fetchProfile(driverId);
        if (context.mounted) {
          context.go('/bank-details', extra: {'driverId': driverId});
        }
      }
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      if (context.mounted) _showSnackBar(context, 'Error uploading documents: $e');
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
}
