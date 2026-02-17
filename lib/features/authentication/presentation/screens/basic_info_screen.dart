import 'package:flutter/material.dart';
import 'package:vendor_app/core/utils/CustomStepper.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/features/authentication/data/models/request/vendor_create_request.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/category_model_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/subcategory_model_response.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/authentication/presentation/screens/phone_number_verified_screen.dart';
import 'package:vendor_app/features/home/presentation/screens/home_screen.dart';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


class BasicInfoScreen extends StatefulWidget {
  final String phone;
  const BasicInfoScreen({super.key, required this.phone});

  @override
  _BasicInfoScreenState createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  int _currentStep = 0;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Step-1
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadharController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();

  // Step-2
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();

  CategoryModelResponse? _selectedCategory;
  SubcategoryModelResponse? _selectedSubcategory;

  // Step-3
  final _benefitsController = TextEditingController();
  final _coverageController = TextEditingController();
  double _minPrice = 500.0;
  double _maxPrice = 5000.0;

  // Step-4 (uploads result paths from server)
  String? _businessPhotoPath;     // e.g. "vendors/..png"
  String? _adharPhotoPath;        // e.g. "uploads/..png"
  String? _certificatePhotoPath;  // e.g. "vendors/certificate_..jpg"

  // geo (placeholder)
  String _lat = '28.6139';
  String _lng = '77.2090';

  @override
  void initState() {
    super.initState();
    // Load categories as soon as screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchCategories();
    });
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // -------- IMAGE PICK + UPLOAD (master-image-upload) ----------
  Future<void> _pickAndUploadx({
    required String folder, // 'vendors' | 'venues' | 'services'
    required void Function(String serverPath) onUploaded,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (picked == null) return;

      final uploadProv = context.read<AuthProvider>();
      await uploadProv.upload(picked.path, folder);
      debugPrint('picked: ${picked?.path}');
      final resp = uploadProv.last;
      if (resp == null) {
        _showMsg(uploadProv.message ?? 'Upload failed');
        return;
      }
      // We need server "path" (not url) for create-vendor
     // onUploaded(resp.path);
      setState(() {
        onUploaded(resp.path); // ✅ यहीं state में set
      });

       _showMsg(resp.message);
      debugPrint('BUSINESS PATH: $_businessPhotoPath');
      debugPrint('AADHAR PATH: $_adharPhotoPath');
      debugPrint('CERT PATH: $_certificatePhotoPath');
    //  setState(() {}); // to refresh uploaded state UI
    } on PlatformException catch (e) {
      _showMsg('Picker error: ${e.message}');
    } catch (e) {
      _showMsg('Upload error: $e');
    }
  }
  Future<void> _pickAndUpload({
    required String folder,
    required void Function(String serverPath) onUploaded,
  }) async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (picked == null) return;

      final resp = await context.read<AuthProvider>().upload(picked.path, folder);
      if (resp == null || !resp.success || resp.path.trim().isEmpty) {
        _showMsg(context.read<AuthProvider>().message ?? 'Upload failed');
        return;
      }

      setState(() { onUploaded(resp.path); }); // ← यहीं state में set
      _showMsg(resp.message);

      debugPrint('BUSINESS PATH: $_businessPhotoPath');
      debugPrint('AADHAR PATH: $_adharPhotoPath');
      debugPrint('CERT PATH: $_certificatePhotoPath');
    } catch (e) {
      _showMsg('Upload error: $e');
    }
  }



  // -------- CREATE VENDOR ----------
  Future<void> _createVendor() async {
    if (_selectedCategory == null) {
      _showMsg('Please select a business category');
      return;
    }
    if (_selectedSubcategory == null) {
      _showMsg('Please select a subcategory');
      return;
    }
    if (_businessPhotoPath == null) {
      _showMsg('Please upload business photo');
      return;
    }
    if (_adharPhotoPath == null) {
      _showMsg('Please upload Aadhar photo');
      return;
    }
    if (_certificatePhotoPath == null) {
      _showMsg('Please upload business certificate');
      return;
    }

    final priceRange = '₹${_minPrice.toStringAsFixed(0)} - ₹${_maxPrice.toStringAsFixed(0)}';

    final req = VendorCreateRequest(
      name: _nameController.text.trim(),
      phone: widget.phone, // <- Optional: fill from logged in user's phone if available
      email: _emailController.text.trim(),
      adharNumber: _aadharController.text.trim(),
      businessName: _businessNameController.text.trim(),
    //  businessCategory: _selectedCategory!.name, // keeping name as per sample
      businessCategory: _selectedSubcategory!.id, // keeping name as per sample

      experienceInBusiness: int.tryParse(_experienceController.text.trim()) ?? 0,
      priceRange: priceRange,
      serviceCoverage: _coverageController.text.trim(),
      businessAddress: _businessAddressController.text.trim(),
      businessDescription: _descriptionController.text.trim(),
      benefits: _benefitsController.text.trim(),
      businessPhoto: _businessPhotoPath!,
      adharPhoto: _adharPhotoPath!,
      certificatePhoto: _certificatePhotoPath!,
      status: true,
      latitude: _lat,
      longitude: _lng,
    );

    final vendorProv = context.read<AuthProvider>();
    final ok = await vendorProv.create(req);

    if (ok) {
      _showMsg(vendorProv.message ?? 'Vendor created');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  HomeScreen(currentIndex: 0)),
      );
    } else {
      _showMsg(vendorProv.message ?? 'Failed to create vendor');
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

  // Content switch
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

  // ----------------- STEP 0: BASIC INFO -----------------
  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            'Fill in the following information which will let us know you better and take your business a flight',
            style: TextStyle(fontFamily: 'OnestRegular', fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          _buildCustomTextField(controller: _nameController, label: 'Your Name'),
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

          _buildCustomTextField(controller: _businessNameController, label: 'Your Business Name'),
          const SizedBox(height: 15),

          _buildCustomTextField(controller: _businessAddressController, label: 'Your Business Address'),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Next: Business Info', style: TextStyle(color: AppColors.whiteColor)),
            ),
          ),
        ]),
      ),
    );
  }

  // ----------------- STEP 1: BUSINESS INFO -----------------
  Widget _buildBusinessInfoStep(AuthProvider cats) {
    final categories = cats.categories;
    final subs = cats.subcategories;

    return Form(
      key: _formKey2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Business Info',
            style: TextStyle(fontFamily: 'OnestSemiBold', fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 10),
          const Text(
            'Fill in the following information which will let us know your business better at a deeper level',
            style: TextStyle(fontFamily: 'OnestRegular', fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Category Dropdown (from API)
          _buildCategoryDropdown(
            label: 'Business Category',
            value: _selectedCategory,
            items: categories,
            onChanged: (cat) async {
              setState(() {
                _selectedCategory = cat;
                _selectedSubcategory = null;
              });
              if (cat != null) {
                await context.read<AuthProvider>().fetchSubcategories(cat.id);
              }
            },
          ),
          const SizedBox(height: 15),

          // Subcategory dropdown (depends on selected category)
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
            keyboardType: TextInputType.text,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Next: Service Info', style: TextStyle(color: AppColors.whiteColor)),
            ),
          ),
        ]),
      ),
    );
  }

  // ----------------- STEP 2: SERVICE INFO -----------------
  Widget _buildServiceInfoStep() {
    return Form(
      key: _formKey3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Service Info',
            style: TextStyle(fontFamily: 'OnestSemiBold', fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 10),
          const Text(
            'Fill in the following information which will let us know your services better at a deeper level',
            style: TextStyle(fontFamily: 'OnestRegular', fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          _buildCustomTextField(controller: _benefitsController, label: 'Benefits', keyboardType: TextInputType.text),
          const SizedBox(height: 15),

          const Text(
            'Price Range',
            style: TextStyle(
              fontFamily: 'OnestMedium',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.labelColor,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 200000,
            divisions: 100,
            labels: RangeLabels('₹${_minPrice.toStringAsFixed(0)}', '₹${_maxPrice.toStringAsFixed(0)}'),
            activeColor: Colors.pink,
            inactiveColor: Colors.grey.shade400,
            onChanged: (values) => setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            }),
          ),
          const SizedBox(height: 10),
          Text(
            '₹${_minPrice.toStringAsFixed(0)} - ₹${_maxPrice.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.labelColor),
          ),
          const SizedBox(height: 15),

          _buildCustomTextField(controller: _coverageController, label: 'Service Coverage', keyboardType: TextInputType.text),
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
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Next: Document Upload', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  // ----------------- STEP 3: DOCUMENT UPLOAD -----------------
  Widget _buildDocumentUploadStep() {
    final uploader = context.watch<AuthProvider>();
    final upText = uploader.loading && uploader.progress > 0
        ? 'Uploading ${(uploader.progress * 100).toStringAsFixed(0)}%'
        : 'Upload';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'Document Upload',
          style: TextStyle(fontFamily: 'OnestSemiBold', fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 10),
        const Text(
          'Upload the following documents in order to pass through a short verification process',
          style: TextStyle(fontFamily: 'OnestRegular', fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        _buildDocumentButton(
          iconPath: AppIcons.photoIcon,
          text: _businessPhotoPath == null ? 'Add a photo of your business' : 'Business photo ✓',
          onPressed: () => _pickAndUpload(folder: 'vendors', onUploaded: (p) => _businessPhotoPath = p),
        ),
        const SizedBox(height: 16),

        _buildDocumentButton(
          iconPath: AppIcons.uploadIcon,
          text: _adharPhotoPath == null ? 'Upload your Aadhar ID' : 'Aadhar photo ✓',
          onPressed: () => _pickAndUpload(folder: 'vendors', onUploaded: (p) => _adharPhotoPath = p),
        ),
        const SizedBox(height: 16),

        _buildDocumentButton(
          iconPath: AppIcons.uploadIcon,
          text: _certificatePhotoPath == null ? 'Upload your business certificate' : 'Certificate photo ✓',
          onPressed: () => _pickAndUpload(folder: 'vendors', onUploaded: (p) => _certificatePhotoPath = p),
        ),
        const SizedBox(height: 10),

        if (uploader.loading) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(value: uploader.progress == 0 ? null : uploader.progress),
          const SizedBox(height: 8),
          Text(upText),
          const SizedBox(height: 12),
        ],

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _createVendor(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    );
  }

  // ----------------- Reusable pieces -----------------
  Widget _buildDocumentButton({
    required String iconPath,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(iconPath, width: 30, height: 30),
        label: Text(text, style: const TextStyle(fontSize: 16, fontFamily: 'OnestRegular')),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontFamily: 'OnestMedium',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.labelColor,
            )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: AppColors.textFieldColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.pinkColor, width: 2),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'Please enter your $label' : null,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown({
    required String label,
    required CategoryModelResponse? value,
    required List<CategoryModelResponse> items,
    required ValueChanged<CategoryModelResponse?> onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
            fontFamily: 'OnestMedium',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.labelColor,
          )),
      const SizedBox(height: 8),
      DropdownButtonFormField<CategoryModelResponse>(
        value: value,
        decoration: InputDecoration(
          hintText: 'Select your category',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textFieldColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textFieldColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.pinkColor, width: 2),
          ),
        ),
        items: items.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select category' : null,
      ),
    ]);
  }

  Widget _buildSubcategoryDropdown({
    required String label,
    required SubcategoryModelResponse? value,
    required List<SubcategoryModelResponse> items,
    required ValueChanged<SubcategoryModelResponse?> onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
            fontFamily: 'OnestMedium',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.labelColor,
          )),
      const SizedBox(height: 8),
      DropdownButtonFormField<SubcategoryModelResponse>(
        value: value,
        decoration: InputDecoration(
          hintText: 'Select your subcategory',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textFieldColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textFieldColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.pinkColor, width: 2),
          ),
        ),
        items: items.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select subcategory' : null,
      ),
    ]);
  }
}


/*
class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  _BasicInfoScreenState createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  int _currentStep = 0;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadharController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0), // Add margin from top
        child: Column(
          children: [
            CustomStepper(
              currentStep: _currentStep,
              onStepChanged: (step) {
                setState(() {
                  _currentStep = step;
                });
              },
            ),
            Expanded(child: SingleChildScrollView(child: _buildStepContent())),
          ],
        ),
      ),
    );
  }

  // Function to build content based on current step
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildBusinessInfoStep();
      case 2:
        return _buildServiceInfoStep();
      case 3:
        return _buildDocumentUploadStep();
      default:
        return const SizedBox();
    }
  }

  // Step 1: Basic Info
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
              'Fill in the following information which will let us know you better and take your business a flight',
              style: TextStyle(
                fontFamily: 'OnestRegular',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Name TextField with label above
            _buildCustomTextField(
              controller: _nameController,
              label: 'Your Name',
            ),
            const SizedBox(height: 15),

            // Email TextField with label above
            _buildCustomTextField(
              controller: _emailController,
              label: 'Your Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            // Aadhar Number TextField with label above
            _buildCustomTextField(
              controller: _aadharController,
              label: 'Aadhar Number',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            // Business Name TextField with label above
            _buildCustomTextField(
              controller: _businessNameController,
              label: 'Your Business Name',
            ),
            const SizedBox(height: 15),

            // Business Address TextField with label above
            _buildCustomTextField(
              controller: _businessAddressController,
              label: 'Your Business Address',
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity, // Makes the button take up the full width
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey1.currentState?.validate() ?? false) {
                    // Move to the next step
                    setState(() {
                      _currentStep = 1;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkColor,
                  // Correct color format
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
            // Next Button
          ],
        ),
      ),
    );
  }

  // Step 1: Basic Business Info
  Widget _buildBusinessInfoStep() {
    final _categoryController = TextEditingController();
    final _subCategoryController = TextEditingController();
    final _experienceController = TextEditingController();
    final _descriptionController = TextEditingController();

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
              'Fill in the following information which will let us know your business better at a deeper level',
              style: TextStyle(
                fontFamily: 'OnestRegular',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Business Category Dropdown
            _buildCustomDropdown(
              label: 'Business Category',
              items: ['Category 1', 'Category 2', 'Category 3'],
              controller: _categoryController,
              onChanged: (value) {
                setState(() {
                  _categoryController.text = value!;
                });
              },
            ),
            const SizedBox(height: 15),

            _buildCustomDropdown(
              label: 'Business Category',
              items: ['Category 1', 'Category 2', 'Category 3'],
              controller: _subCategoryController,
              onChanged: (value) {
                setState(() {
                  _subCategoryController.text = value!;
                });
              },
            ),
            const SizedBox(height: 15),

            // Experience in Business Field
            _buildCustomTextField(
              controller: _experienceController,
              label: 'Experience in Business',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            // Business Description Field
            _buildCustomTextField(
              controller: _descriptionController,
              label: 'Business Description',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 30),

            // Next Button
            SizedBox(
              width: double.infinity, // Makes the button take up the full width
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey2.currentState?.validate() ?? false) {
                    setState(() {
                      _currentStep = 2; // Move to the next step
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkColor,
                  // Correct color format
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

  // Service Info Step
  Widget _buildServiceInfoStep() {
    final _benefitsController = TextEditingController();
    final _priceRangeController = TextEditingController();
    final _priceRangeControllerMin = TextEditingController();
    final _priceRangeControllerMax = TextEditingController();
    final _coverageController = TextEditingController();
    double _minPrice = 50000;
    double _maxPrice = 200000;
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
              'Fill in the following information which will let us know your services better at a deeper level',
              style: TextStyle(
                fontFamily: 'OnestRegular',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Benefits Field
            _buildCustomTextField(
              controller: _benefitsController,
              label: 'Benefits',

              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 15),

            // Price Range Slider
            // Price Range Slider
            // Price Range Slider (RangeSlider)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label for the slider
                const Text(
                  'Price Range',
                  style: TextStyle(
                    fontFamily: 'OnestMedium',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.labelColor,
                  ),
                ),
                const SizedBox(height: 8),

                // RangeSlider widget
                RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: 0,
                  max: 200000,
                  divisions: 10,
                  labels: RangeLabels(
                    '₹${_minPrice.toStringAsFixed(0)}',
                    '₹${_maxPrice.toStringAsFixed(0)}',
                  ),
                  activeColor: Colors.pink,
                  inactiveColor: Colors.grey.shade400,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                      // _priceRangeControllerMin.text = _minPrice.toString();
                      // _priceRangeControllerMax.text = _maxPrice.toString();
                      // _priceRangeControllerMin.text = values.start.toStringAsFixed(0);
                      // _priceRangeControllerMax.text = values.end.toStringAsFixed(0);
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Display the current selected price range
                Text(
                  '₹${_minPrice.toStringAsFixed(0)} - ₹${_maxPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.labelColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Service Coverage Field
            _buildCustomTextField(
              controller: _coverageController,
              label: 'Service Coverage',

              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 30),

            // Next Button

            // Next Button
            SizedBox(
              width: double.infinity, // Full width button
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey3.currentState?.validate() ?? false) {
                    setState(() {
                      _currentStep = 3; // Move to the next step
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next: Document Upload',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Document Upload Step
  Widget _buildDocumentUploadStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Upload',
            style: TextStyle(
              fontFamily: 'OnestSemiBold',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload the following documents in order to pass through a short verification process',
            style: TextStyle(
              fontFamily: 'OnestRegular',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          // Add Photo Button
          _buildDocumentButton(
            iconPath: AppIcons.photoIcon, // Path to your icon
            text: 'Add a photo of your business',
            onPressed: () {
              // Implement file picker logic here
            },
          ),
          const SizedBox(height: 16),

          // Upload Aadhar ID Button
          _buildDocumentButton(
            iconPath: AppIcons.uploadIcon, // Path to your icon
            text: 'Upload your Aadhar ID',
            onPressed: () {
              // Implement file picker logic here
            },
          ),
          const SizedBox(height: 16),

          // Upload Business Certificate Button
          _buildDocumentButton(
            iconPath: AppIcons.uploadIcon, // Path to your icon
            text: 'Upload your business certificate',
            onPressed: () {
              // Implement file picker logic here
            },
          ),
        const SizedBox(height: 20),

          // "Next" Button
          SizedBox(
            width: double.infinity, // Full width button
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(currentIndex: 0),
                  ),
                );

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDocumentButton({
    required String iconPath,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity, // Makes the container take full width
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          iconPath, // Path to your custom icon
          width: 30,
          height: 30,
        ),
        label: Text(
          text,
          style: TextStyle(fontSize: 16, fontFamily: 'OnestRegular'),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }




  // Custom TextField for other inputs
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label for the input field
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'OnestMedium',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: AppColors.textFieldColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.pinkColor,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Custom Dropdown for Business Category
  Widget _buildCustomDropdown({
    required String label,
    required List<String> items,
    required TextEditingController controller,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'OnestMedium',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.labelColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          decoration: InputDecoration(
            hintText: 'Select your category',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textFieldColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.pinkColor,
                width: 2,
              ),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
*/
