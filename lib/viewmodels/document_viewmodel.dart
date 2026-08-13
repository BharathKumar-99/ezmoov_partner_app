import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/services/supabase_service.dart';
import '../models/document_model.dart';
import 'profile_viewmodel.dart';

enum DocumentType {
  aadhaar,
  drivingLicense,
  vehicleRc,
  panCard,
  insurance,
  puc,
  permit,
  fitness,
  policeClearance,
  selfieWithVehicle,
}

class DocumentViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  String? _aadhaarPath;
  String? _drivingLicensePath;
  String? _vehicleRcPath;
  String? _panCardPath;
  String? _insurancePath;
  String? _pucPath;
  String? _permitPath;
  String? _fitnessPath;
  String? _policeClearancePath;
  String? _selfieWithVehiclePath;

  String? get aadhaarPath => _aadhaarPath;
  String? get drivingLicensePath => _drivingLicensePath;
  String? get vehicleRcPath => _vehicleRcPath;
  String? get panCardPath => _panCardPath;
  String? get insurancePath => _insurancePath;
  String? get pucPath => _pucPath;
  String? get permitPath => _permitPath;
  String? get fitnessPath => _fitnessPath;
  String? get policeClearancePath => _policeClearancePath;
  String? get selfieWithVehiclePath => _selfieWithVehiclePath;

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
          case DocumentType.aadhaar:
            _aadhaarPath = pickedFile.path;
            break;
          case DocumentType.drivingLicense:
            _drivingLicensePath = pickedFile.path;
            break;
          case DocumentType.vehicleRc:
            _vehicleRcPath = pickedFile.path;
            break;
          case DocumentType.panCard:
            _panCardPath = pickedFile.path;
            break;
          case DocumentType.insurance:
            _insurancePath = pickedFile.path;
            break;
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
          case DocumentType.selfieWithVehicle:
            _selfieWithVehiclePath = pickedFile.path;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to pick document: $e');
    }
  }

  int get uploadedCount {
    int count = 0;
    if (_aadhaarPath != null) count++;
    if (_drivingLicensePath != null) count++;
    if (_vehicleRcPath != null) count++;
    if (_panCardPath != null) count++;
    if (_insurancePath != null) count++;
    if (_pucPath != null) count++;
    if (_permitPath != null) count++;
    if (_fitnessPath != null) count++;
    if (_policeClearancePath != null) count++;
    if (_selfieWithVehiclePath != null) count++;
    return count;
  }

  bool get areAllDocumentsUploaded => uploadedCount >= 10;

  Future<void> submitDocuments(BuildContext context, String driverId) async {
    if (uploadedCount < 4) {
      if (context.mounted) {
        _showSnackBar(context, 'Please upload at least the core required documents (Aadhaar, License, RC, PAN).');
      }
      return;
    }

    setLoading(true);
    setError(null);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      String aadhaarUrl = '';
      if (_aadhaarPath != null) {
        aadhaarUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _aadhaarPath!,
          fileName: 'aadhaar_${driverId}_$timestamp.jpg',
        );
      }

      String drivingLicenseUrl = '';
      if (_drivingLicensePath != null) {
        drivingLicenseUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _drivingLicensePath!,
          fileName: 'dl_${driverId}_$timestamp.jpg',
        );
      }

      String vehicleRcUrl = '';
      if (_vehicleRcPath != null) {
        vehicleRcUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _vehicleRcPath!,
          fileName: 'rc_${driverId}_$timestamp.jpg',
        );
      }

      String panCardUrl = '';
      if (_panCardPath != null) {
        panCardUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _panCardPath!,
          fileName: 'pan_${driverId}_$timestamp.jpg',
        );
      }

      String insuranceUrl = '';
      if (_insurancePath != null) {
        insuranceUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _insurancePath!,
          fileName: 'insurance_${driverId}_$timestamp.jpg',
        );
      }

      String pucUrl = '';
      if (_pucPath != null) {
        pucUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _pucPath!,
          fileName: 'puc_${driverId}_$timestamp.jpg',
        );
      }

      String permitUrl = '';
      if (_permitPath != null) {
        permitUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _permitPath!,
          fileName: 'permit_${driverId}_$timestamp.jpg',
        );
      }

      String fitnessUrl = '';
      if (_fitnessPath != null) {
        fitnessUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _fitnessPath!,
          fileName: 'fitness_${driverId}_$timestamp.jpg',
        );
      }

      String policeClearanceUrl = '';
      if (_policeClearancePath != null) {
        policeClearanceUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _policeClearancePath!,
          fileName: 'police_clearance_${driverId}_$timestamp.jpg',
        );
      }

      String selfieWithVehicleUrl = '';
      if (_selfieWithVehiclePath != null) {
        selfieWithVehicleUrl = await _supabaseService.uploadImage(
          bucket: 'documents',
          filePath: _selfieWithVehiclePath!,
          fileName: 'selfie_with_vehicle_${driverId}_$timestamp.jpg',
        );
      }

      final docModel = DocumentModel(
        driverId: driverId,
        aadhaarUrl: aadhaarUrl,
        drivingLicenseUrl: drivingLicenseUrl,
        vehicleRcUrl: vehicleRcUrl,
        panCardUrl: panCardUrl,
        insuranceUrl: insuranceUrl,
        pucUrl: pucUrl,
        permitUrl: permitUrl,
        fitnessUrl: fitnessUrl,
        policeClearanceUrl: policeClearanceUrl,
        selfieWithVehicleUrl: selfieWithVehicleUrl,
        status: 'pending',
      );

      await _supabaseService.saveDocuments(docModel);

      // If selfieWithVehicleUrl is present, also update drivers table selfie_with_vehicle_url
      if (selfieWithVehicleUrl.isNotEmpty) {
        await _supabaseService.client.from('drivers').update({
          'selfie_with_vehicle_url': selfieWithVehicleUrl,
        }).eq('id', driverId);
      }

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
