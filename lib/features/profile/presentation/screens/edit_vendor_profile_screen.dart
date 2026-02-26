import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/CustomStepper.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/category_model_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/subcategory_model_response.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/profile/data/models/resposne/vendor_details_model.dart';
import 'package:vendor_app/core/utils/app_message.dart';
import 'package:vendor_app/core/utils/result_popup.dart';
import 'package:vendor_app/features/profile/presentation/screens/profile_screen.dart';

class EditVendorProfileScreen extends StatefulWidget {
  final VendorDetails vendorDetails;
  
  const EditVendorProfileScreen({
    super.key,
    required this.vendorDetails,
  });

  @override
  _EditVendorProfileScreenState createState() => _EditVendorProfileScreenState();
}

class _EditVendorProfileScreenState extends State<EditVendorProfileScreen> {
  int _currentStep = 0;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Step-1 Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadharController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();

  // Step-2 Controllers
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();

  CategoryModelResponse? _selectedCategory;
  SubcategoryModelResponse? _selectedSubcategory;

  // Step-3 Controllers
  final _benefitsController = TextEditingController();
  final _coverageController = TextEditingController();
  double _minPrice = 500.0;
  double _maxPrice = 5000.0;

  // Photo paths from server
  String? _businessPhotoPath;
  String? _adharPhotoPath;
  String? _certificatePhotoPath;

  // Geo coordinates
  String _lat = '28.6139';
  String _lng = '77.2090';

  @override
  void initState() {
    super.initState();
    _prefillVendorData();
  }

  void _prefillVendorData() {
    final vendor = widget.vendorDetails;
    
    // Basic Info
    _nameController.text = vendor.name ?? '';
    _emailController.text = vendor.email ?? '';
    _aadharController.text = vendor.adharNumber ?? '';
    _businessNameController.text = vendor.businessName ?? '';
    _businessAddressController.text = vendor.businessAddress ?? '';

    // Business Info
    _experienceController.text = vendor.experienceInBusiness?.toString() ?? '';
    _descriptionController.text = vendor.businessDescription ?? '';

    // Service Info
    _benefitsController.text = vendor.benefits ?? '';
    _coverageController.text = vendor.serviceCoverage ?? '';
    
    // Parse price range
    if (vendor.priceRange != null) {
      final priceMatch = RegExp(r'₹(\d+)\s*-\s*₹(\d+)').firstMatch(vendor.priceRange!);
      if (priceMatch != null) {
        _minPrice = double.tryParse(priceMatch.group(1) ?? '0') ?? 500.0;
        _maxPrice = double.tryParse(priceMatch.group(2) ?? '5000') ?? 5000.0;
      }
    }

    // Photos
    _businessPhotoPath = vendor.businessPhoto;
    _adharPhotoPath = vendor.adharPhoto;
    _certificatePhotoPath = vendor.certificatePhoto;

    // Coordinates
    _lat = vendor.latitude ?? '28.6139';
    _lng = vendor.longitude ?? '77.2090';

    // Category/Subcategory will be set after fetching from API
    // Note: vendor.categoryId is actually the SUBCATEGORY ID stored in business_category
    if (vendor.categoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveAndLoadCategorySubcategory(vendor.categoryId!);
      });
    }
  }

  /// The vendor profile stores a subcategory ID in `business_category`.
  /// Categories and subcategories are from separate APIs.
  /// We iterate through categories and find which one contains the vendor's subcategory.
  Future<void> _resolveAndLoadCategorySubcategory(int subcategoryId) async {
    final prov = context.read<AuthProvider>();
    await prov.fetchCategories();
    final cats = prov.categories;
    if (cats.isEmpty) return;

    for (final cat in cats) {
      await prov.fetchSubcategories(cat.id);
      final subs = prov.subcategories;
      final match = subs.where((s) => s.id == subcategoryId).firstOrNull;
      if (match != null) {
        if (!mounted) return;
        setState(() {
          _selectedCategory = cat;
          _selectedSubcategory = match;
        });
        return;
      }
    }

    // Fallback: no match found, just select first category
    if (!mounted) return;
    setState(() {
      _selectedCategory = cats.first;
    });
    await prov.fetchSubcategories(cats.first.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _aadharController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    _benefitsController.dispose();
    _coverageController.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    if (!mounted || msg.isEmpty) return;
    // ignore: unawaited_futures
    AppMessage.show(context, msg);
  }

  Future<void> _pickAndUpload({
    required String folder,
    required void Function(String serverPath) onUploaded,
  }) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) return;

      final resp = await context.read<AuthProvider>().upload(picked.path, folder);
      if (resp == null || !resp.success || resp.path.trim().isEmpty) {
        _showMsg(context.read<AuthProvider>().message ?? 'Upload failed');
        return;
      }

      setState(() {
        onUploaded(resp.path);
      });
      _showMsg(resp.message);
    } catch (e) {
      _showMsg('Upload error: $e');
    }
  }

  Future<void> _updateVendor() async {
    final user = await TokenStorage.getUserData();
    if (user == null) {
      _showMsg('User not found');
      return;
    }

    if (_selectedCategory == null) {
      _showMsg('Category not loaded yet. Please wait.');
      return;
    }

    if (_selectedSubcategory == null) {
      _showMsg('Please select a subcategory');
      return;
    }

    final priceRange = '₹${_minPrice.toStringAsFixed(0)} - ₹${_maxPrice.toStringAsFixed(0)}';

    final data = {
      'name': _nameController.text.trim(),
      'phone': widget.vendorDetails.phone ?? '',
      'email': _emailController.text.trim(),
      'adhar_number': _aadharController.text.trim(),
      'business_name': _businessNameController.text.trim(),
      'business_category': _selectedSubcategory!.id,
      'experience_in_business': int.tryParse(_experienceController.text.trim()) ?? 0,
      'price_range': priceRange,
      'service_coverage': _coverageController.text.trim(),
      'business_address': _businessAddressController.text.trim(),
      'business_description': _descriptionController.text.trim(),
      'benefits': _benefitsController.text.trim(),
      'business_photo': _businessPhotoPath ?? '',
      'adhar_photo': _adharPhotoPath ?? '',
      'certificate_photo': _certificatePhotoPath ?? '',
      'status': true,
      'latitude': _lat,
      'longitude': _lng,
    };

    final vendorId = user.id ?? 0;
    final vendorProv = context.read<AuthProvider>();
    final ok = await vendorProv.updateVendorData(vendorId, data);

    if (ok) {
      if (!mounted) return;
      await ResultPopup.show(context, success: true, message: vendorProv.message ?? 'Profile updated successfully');
      if (!mounted) return;
      // Navigate to profile screen (replace current route so back button doesn't return here)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen(currentIndex: 3)),
      );
    } else {
      if (!mounted) return;
      await ResultPopup.show(context, success: false, message: vendorProv.message ?? 'Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<AuthProvider>();
    final uploader = context.watch<AuthProvider>();
    final vendorProv = context.watch<AuthProvider>();

    final anyLoading = cats.loading || uploader.loading || vendorProv.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (anyLoading) const LinearProgressIndicator(minHeight: 3),
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Column(
              children: [
                CustomStepper(
                  currentStep: _currentStep,
                  onStepChanged: (step) => setState(() => _currentStep = step),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildStepContent(cats),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(AuthProvider cats) {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildBusinessInfoStep(cats);
      case 2:
        return _buildServiceInfoStep();
      case 3:
        return _buildDocumentUploadStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 0: BASIC INFO
  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Info',
              style: TextStyle(
                fontFamily: 'OnestSemiBold',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Update your basic information',
              style: TextStyle(
                fontFamily: 'OnestRegular',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            _buildCustomTextField(
              controller: _nameController,
              label: 'Your Name',
            ),
            const SizedBox(height: 15),
            _buildCustomTextField(
              controller: _emailController,
              label: 'Your Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            _buildCustomTextField(
              controller: _aadharController,
              label: 'Aadhar Number',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            _buildCustomTextField(
              controller: _businessNameController,
              label: 'Your Business Name',
            ),
            const SizedBox(height: 15),
            _buildCustomTextField(
              controller: _businessAddressController,
              label: 'Your Business Address',
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey1.currentState?.validate() ?? false) {
                    setState(() => _currentStep = 1);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next: Business Info',
                  style: TextStyle(color: AppColors.whiteColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: BUSINESS INFO
  Widget _buildBusinessInfoStep(AuthProvider cats) {
    final subs = cats.subcategories;

    return Form(
      key: _formKey2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Info',
              style: TextStyle(
                fontFamily: 'OnestSemiBold',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Update your business information',
              style: TextStyle(
                fontFamily: 'OnestRegular',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            // Category is auto-resolved and non-editable
            if (_selectedCategory != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category_outlined, color: Color(0xFFFF4678), size: 20),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Business Category', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(_selectedCategory!.name, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text('Loading category...', style: TextStyle(color: Colors.grey.shade500)),
              ),
            ],
            const SizedBox(height: 15),
            _buildSubcategoryDropdown(
              label: 'Subcategory',
              value: _selectedSubcategory,
              items: subs,
              onChanged: (sub) => setState(() => _selectedSubcategory = sub),
            ),
            const SizedBox(height: 15),
            _buildCustomTextField(
              controller: _experienceController,
              label: 'Experience in Business (years)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            _buildCustomTextField(
              controller: _descriptionController,
              label: 'Business Description',
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey2.currentState?.validate() ?? false) {
                    setState(() => _currentStep = 2);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next: Service Info',
                  style: TextStyle(color: AppColors.whiteColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: SERVICE INFO
  Widget _buildServiceInfoStep() {
    return Form(
      key: _formKey3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Info',
              style: TextStyle(
                fontFamily: 'OnestSemiBold',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Update your service details',
              style: TextStyle(
                fontFamily: 'OnestRegular',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 100000,
              divisions: 200,
              activeColor: AppColors.pinkColor,
              labels: RangeLabels(
                '₹${_minPrice.toStringAsFixed(0)}',
                '₹${_maxPrice.toStringAsFixed(0)}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
            ),
            Text(
              '₹${_minPrice.toStringAsFixed(0)} - ₹${_maxPrice.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildCustomTextField(
              controller: _coverageController,
              label: 'Service Coverage Area',
            ),
            const SizedBox(height: 15),
            _buildCustomTextField(
              controller: _benefitsController,
              label: 'Benefits',
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey3.currentState?.validate() ?? false) {
                    setState(() => _currentStep = 3);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next: Documents',
                  style: TextStyle(color: AppColors.whiteColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3: DOCUMENT UPLOAD
  Widget _buildDocumentUploadStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Documents',
            style: TextStyle(
              fontFamily: 'OnestSemiBold',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Update your business documents',
            style: TextStyle(
              fontFamily: 'OnestRegular',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          _buildPhotoUploadCard(
            title: 'Business Photo',
            subtitle: 'Upload a photo of your business',
            photoPath: _businessPhotoPath,
            onTap: () {
              _pickAndUpload(
                folder: 'vendors',
                onUploaded: (path) => _businessPhotoPath = path,
              );
            },
          ),
          const SizedBox(height: 15),
          _buildPhotoUploadCard(
            title: 'Aadhar Card Photo',
            subtitle: 'Upload your Aadhar card',
            photoPath: _adharPhotoPath,
            onTap: () {
              _pickAndUpload(
                folder: 'vendors',
                onUploaded: (path) => _adharPhotoPath = path,
              );
            },
          ),
          const SizedBox(height: 15),
          _buildPhotoUploadCard(
            title: 'Business Certificate',
            subtitle: 'Upload your business certificate',
            photoPath: _certificatePhotoPath,
            onTap: () {
              _pickAndUpload(
                folder: 'vendors',
                onUploaded: (path) => _certificatePhotoPath = path,
              );
            },
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateVendor,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Update Profile',
                style: TextStyle(color: AppColors.whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildSubcategoryDropdown({
    required String label,
    required SubcategoryModelResponse? value,
    required List<SubcategoryModelResponse> items,
    required void Function(SubcategoryModelResponse?) onChanged,
  }) {
    // Ensure value is either null or exists in items list
    SubcategoryModelResponse? safeValue;
    if (value != null && items.isNotEmpty) {
      try {
        safeValue = items.firstWhere((item) => item.id == value.id);
      } catch (e) {
        safeValue = null; // Value not found in items, set to null
      }
    }

    return DropdownButtonFormField<SubcategoryModelResponse>(
      value: safeValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((sub) {
        return DropdownMenuItem<SubcategoryModelResponse>(
          value: sub,
          child: Text(sub.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPhotoUploadCard({
    required String title,
    required String subtitle,
    required String? photoPath,
    required VoidCallback onTap,
  }) {
    final bool hasPhoto = photoPath != null && photoPath.isNotEmpty;
    final String fullUrl = hasPhoto && !photoPath.startsWith('http')
        ? 'https://sevenoath.shofus.com/storage/$photoPath'
        : photoPath ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: hasPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fullUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.camera_alt, color: Colors.grey);
                        },
                      ),
                    )
                  : const Icon(Icons.camera_alt, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasPhoto ? 'Tap to change' : subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
