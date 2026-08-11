import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/services/supabase_service.dart';
import '../models/vehicle_model.dart';
import '../models/vehicle_catalog_model.dart';
import 'profile_viewmodel.dart';

class VehicleViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController rcNumberController = TextEditingController();

  List<VehicleCatalogModel> _catalogList = [];
  List<VehicleCatalogModel> get catalogList => _catalogList;

  String? _selectedWheelCount;
  String? get selectedWheelCount => _selectedWheelCount;

  String? _selectedBrand;
  String? get selectedBrand => _selectedBrand;

  String? _selectedModel;
  String? get selectedModel => _selectedModel;

  String? _selectedBodyType;
  String? get selectedBodyType => _selectedBodyType;

  VehicleCatalogModel? _selectedCatalogItem;
  VehicleCatalogModel? get selectedCatalogItem => _selectedCatalogItem;

  String? _rcPicPath;
  String? get rcPicPath => _rcPicPath;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  VehicleViewModel() {
    loadVehicleCatalog();
  }

  Future<void> loadVehicleCatalog() async {
    try {
      final list = await _supabaseService.fetchVehicleCatalog();
      _catalogList =
          list.isNotEmpty ? list : VehicleCatalogModel.defaultCatalog;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading vehicle catalog: $e');
      _catalogList = VehicleCatalogModel.defaultCatalog;
      notifyListeners();
    }
  }

  /// Unique Wheel Count options
  List<String> get wheelCountOptions {
    final set = <String>{};
    for (final item in _catalogList) {
      if (item.wheelCount.isNotEmpty) {
        set.add(item.wheelCount);
      }
    }
    return set.toList()..sort();
  }

  /// Unique Brand options filtered by selected Wheel Count
  List<String> get brandOptions {
    if (_selectedWheelCount == null) return [];
    final set = <String>{};
    for (final item in _catalogList) {
      if (item.wheelCount == _selectedWheelCount && item.brand.isNotEmpty) {
        set.add(item.brand);
      }
    }
    return set.toList()..sort();
  }

  /// Unique Model options filtered by selected Wheel Count & Brand
  List<String> get modelOptions {
    if (_selectedWheelCount == null || _selectedBrand == null) return [];
    final set = <String>{};
    for (final item in _catalogList) {
      if (item.wheelCount == _selectedWheelCount &&
          item.brand == _selectedBrand &&
          item.model.isNotEmpty) {
        set.add(item.model);
      }
    }
    return set.toList()..sort();
  }

  /// Unique Body Type options filtered by Wheel Count, Brand & Model
  List<String> get bodyTypeOptions {
    if (_selectedWheelCount == null ||
        _selectedBrand == null ||
        _selectedModel == null) {
      return [];
    }
    final set = <String>{};
    for (final item in _catalogList) {
      if (item.wheelCount == _selectedWheelCount &&
          item.brand == _selectedBrand &&
          item.model == _selectedModel &&
          item.bodyType.isNotEmpty) {
        set.add(item.bodyType);
      }
    }
    return set.toList()..sort();
  }

  void selectWheelCount(String? val) {
    _selectedWheelCount = val;
    _selectedBrand = null;
    _selectedModel = null;
    _selectedBodyType = null;
    _selectedCatalogItem = null;
    notifyListeners();
  }

  void selectBrand(String? val) {
    _selectedBrand = val;
    _selectedModel = null;
    _selectedBodyType = null;
    _selectedCatalogItem = null;
    notifyListeners();
  }

  void selectModel(String? val) {
    _selectedModel = val;
    _selectedBodyType = null;
    _selectedCatalogItem = null;
    notifyListeners();
  }

  void selectBodyType(String? val) {
    _selectedBodyType = val;
    _resolveCatalogItem();
    notifyListeners();
  }

  void _resolveCatalogItem() {
    if (_selectedWheelCount == null ||
        _selectedBrand == null ||
        _selectedModel == null ||
        _selectedBodyType == null) {
      _selectedCatalogItem = null;
      return;
    }

    try {
      _selectedCatalogItem = _catalogList.firstWhere(
        (item) =>
            item.wheelCount == _selectedWheelCount &&
            item.brand == _selectedBrand &&
            item.model == _selectedModel &&
            item.bodyType == _selectedBodyType,
      );
    } catch (_) {
      // Fallback matching by wheelCount, brand, model
      try {
        _selectedCatalogItem = _catalogList.firstWhere(
          (item) =>
              item.wheelCount == _selectedWheelCount &&
              item.brand == _selectedBrand &&
              item.model == _selectedModel,
        );
      } catch (_) {
        _selectedCatalogItem = null;
      }
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

    if (_selectedWheelCount == null) {
      if (context.mounted) _showSnackBar(context, 'Please select Wheel Count');
      return;
    }
    if (_selectedBrand == null) {
      if (context.mounted)
        _showSnackBar(context, 'Please select Vehicle Brand');
      return;
    }
    if (_selectedModel == null) {
      if (context.mounted)
        _showSnackBar(context, 'Please select Vehicle Model');
      return;
    }
    if (_selectedBodyType == null) {
      if (context.mounted) _showSnackBar(context, 'Please select Body Type');
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
      if (context.mounted) _showSnackBar(context, 'Please upload RC photo');
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

      final selectedCat = _selectedCatalogItem;
      final vehicleTypeId = selectedCat?.id;

      final vehicle = VehicleModel(
        driverId: driverId,
        vehicleNumber: vehicleNumber,
        rcNumber: rcNumber,
        rcPicUrl: rcPicUrl,
        vehicleTypeId: vehicleTypeId,
      );

      await _supabaseService.saveVehicle(vehicle);

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
    super.dispose();
  }
}
