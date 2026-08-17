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

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String _selectedCity = 'Hyderabad';
  String get selectedCity => _selectedCity;

  String _selectedBodyDetail = '8 feet (1.2 Ton)';
  String get selectedBodyDetail => _selectedBodyDetail;

  String _selectedBodyType = 'Open';
  String get selectedBodyType => _selectedBodyType;

  String _selectedFuelType = 'Petrol';
  String get selectedFuelType => _selectedFuelType;

  final List<String> cities = ['Hyderabad'];
  final List<String> bodyDetailOptions = [
    'Tata Ace (750 Kg)',
    '8 feet (1.2 Ton)',
    '9 feet (1.7 Ton)',
    '10 feet (2 Tons)',
  ];
  final List<String> bodyTypes = ['Open', 'Closed'];
  final List<String> fuelTypes = ['Petrol', 'CNG', 'EV', 'Diesel'];

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
      _syncSelectedVehicleType();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading vehicle types: $e');
      _vehicleTypes = VehicleTypeModel.defaultVehicleTypes;
      _syncSelectedVehicleType();
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _syncSelectedVehicleType();
    notifyListeners();
  }

  void selectCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  void selectBodyDetail(String detail) {
    _selectedBodyDetail = detail;
    _syncSelectedVehicleType();
    notifyListeners();
  }

  void selectBodyType(String bodyType) {
    _selectedBodyType = bodyType;
    notifyListeners();
  }

  void selectFuelType(String fuelType) {
    _selectedFuelType = fuelType;
    notifyListeners();
  }

  void selectVehicleType(VehicleTypeModel? type) {
    _selectedVehicleType = type;
    notifyListeners();
  }

  void _syncSelectedVehicleType() {
    if (_selectedCategory == '3W') {
      _selectedVehicleType = _vehicleTypes.firstWhere(
        (v) => v.id == '2' || v.name.toLowerCase().contains('3 wheeler'),
        orElse: () => VehicleTypeModel.defaultVehicleTypes[1], // 3 Wheeler
      );
    } else if (_selectedCategory == 'Truck') {
      String targetId = '5'; // default 8ft
      if (_selectedBodyDetail.contains('Tata Ace') || _selectedBodyDetail.contains('750')) {
        targetId = '4'; // 4 Wheeler (750 Kgs)
      } else if (_selectedBodyDetail.contains('9')) {
        targetId = '6'; // 9 Ft Vehicle
      } else if (_selectedBodyDetail.contains('10')) {
        targetId = '7'; // 10 Ft Vehicle
      } else {
        targetId = '5'; // 8 Ft Vehicle
      }
      _selectedVehicleType = _vehicleTypes.firstWhere(
        (v) => v.id == targetId,
        orElse: () => VehicleTypeModel.defaultVehicleTypes.firstWhere(
          (v) => v.id == targetId,
          orElse: () => VehicleTypeModel.defaultVehicleTypes[2], // 4 Wheeler (ID 4)
        ),
      );
    }
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

    final effectiveAddress = address.isNotEmpty ? address : _selectedCity;

    if (_selectedCategory == null && _selectedVehicleType == null) {
      if (context.mounted) {
        _showSnackBar(context, 'Please select a vehicle type');
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
        bodyType: _selectedBodyType,
        fuelType: _selectedFuelType,
        cityOfOperation: _selectedCity,
      );

      await _supabaseService.saveVehicle(vehicle, address: effectiveAddress);

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
