import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/services/supabase_service.dart';
import '../models/vehicle_model.dart';
import '../models/vehicle_type_model.dart';
import 'profile_viewmodel.dart';

class VehicleViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController rcNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();

  List<VehicleTypeModel> _vehicleTypes = [];
  List<VehicleTypeModel> get vehicleTypes =>
      _vehicleTypes.where((v) => v.isActive).toList();

  VehicleTypeModel? _selectedVehicleType;
  VehicleTypeModel? get selectedVehicleType => _selectedVehicleType;

  String? _rcPicPath;
  String? get rcPicPath => _rcPicPath;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  VehicleViewModel() {
    loadVehicleTypes();
  }

  Future<void> loadVehicleTypes() async {
    try {
      final list = await _supabaseService.fetchVehicleTypes();
      _vehicleTypes =
          list.isNotEmpty ? list : VehicleTypeModel.defaultVehicleTypes;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading vehicle types: $e');
      _vehicleTypes = VehicleTypeModel.defaultVehicleTypes;
      notifyListeners();
    }
  }

  void selectVehicleType(VehicleTypeModel? type) {
    _selectedVehicleType = type;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> pickRcImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile =
          await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        _rcPicPath = pickedFile.path;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to pick RC image: $e');
    }
  }

  Future<void> submitVehicleDetails(
      BuildContext context, String driverId) async {
    final vehicleNumber = vehicleNumberController.text.trim();
    final rcNumber = rcNumberController.text.trim();
    final address = addressController.text.trim();
    final ownerName = ownerNameController.text.trim();

    if (_selectedVehicleType == null) {
      if (context.mounted) {
        _showSnackBar(context, 'Please select a vehicle type');
      }
      return;
    }

    if (address.isEmpty) {
      if (context.mounted) {
        _showSnackBar(context, 'Please enter complete driver address');
      }
      return;
    }

    if (vehicleNumber.isEmpty) {
      if (context.mounted) {
        _showSnackBar(context, 'Please enter vehicle registration number');
      }
      return;
    }

    if (rcNumber.isEmpty) {
      if (context.mounted) {
        _showSnackBar(context, 'Please enter TC / RC permit number');
      }
      return;
    }

    if (_rcPicPath == null) {
      if (context.mounted) {
        _showSnackBar(context, 'Please upload RC photo');
      }
      return;
    }

    setLoading(true);
    setError(null);

    try {
      final rcPicUrl = await _supabaseService.uploadImage(
        bucket: 'vehicles',
        filePath: _rcPicPath!,
        fileName: 'rc_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final vehicle = VehicleModel(
        driverId: driverId,
        vehicleNumber: vehicleNumber,
        rcNumber: rcNumber,
        rcPicUrl: rcPicUrl,
        vehicleTypeId: _selectedVehicleType?.id,
        vehicleTypeName: _selectedVehicleType?.name,
        ownerName: ownerName.isNotEmpty ? ownerName : null,
      );

      await _supabaseService.saveVehicle(vehicle, address: address);

      setLoading(false);
      if (context.mounted) {
        // Refresh central ProfileViewModel
        await Provider.of<ProfileViewModel>(context, listen: false)
            .fetchProfile(driverId);
        if (context.mounted) {
          context.go('/document-collection', extra: {'driverId': driverId});
        }
      }
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      if (context.mounted) {
        _showSnackBar(context, 'Error saving vehicle details: $e');
      }
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
    vehicleNumberController.dispose();
    rcNumberController.dispose();
    addressController.dispose();
    ownerNameController.dispose();
    super.dispose();
  }
}
