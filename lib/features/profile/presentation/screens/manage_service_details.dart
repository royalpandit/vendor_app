import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/services/address_service.dart';
import 'package:vendor_app/core/services/lat_lng_service.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/category_model_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/subcategory_model_response.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/profile/data/models/request/service_add_request.dart';
import 'package:vendor_app/features/profile/data/models/request/venue_create_request.dart';
import 'package:vendor_app/features/profile/data/models/resposne/amenity_model_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/cities_data.dart';
import 'package:vendor_app/features/profile/data/models/resposne/states_data.dart';

class ManageServiceDetailsScreen extends StatefulWidget {
  const ManageServiceDetailsScreen({
    super.key,
    required this.type,
    required this.subCategoryId,
  });

  final String type;
  final int subCategoryId;

  @override
  _ManageServiceDetailsScreenState createState() =>
      _ManageServiceDetailsScreenState();
}

class _ManageServiceDetailsScreenState
    extends State<ManageServiceDetailsScreen> {
  String get _normalizedType => (widget.type).trim().toLowerCase();
  bool get isVenue => _normalizedType == 'venue';

  // Image carousel
  List<String> _imagePaths = [];
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  // Controllers
  final businessNameController = TextEditingController();
  final categoryController = TextEditingController();
  final subcategoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final maxCapacityController = TextEditingController();
  final minCapacityController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final amenitiesController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // States
  bool _saving = false;
  List<AmenityModelResponse> _allAmenities = [];
  final List<AmenityModelResponse> _selectedAmenities = [];
  StateItem? _selState;
  CityItem? _selCity;
  int? _selectedCategoryId;
  String? _selectedCategoryName;
  int? _selectedSubcategoryId;
  String? _selectedSubcategoryName;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadAmenities(),
      _loadStates(),
      _loadCategories(),
      _prefillLocationFromGPS(),
    ]);
  }

  Future<void> _loadCategories() async {
    await context.read<AuthProvider>().fetchCategories();
  }

  Future<void> _loadAmenities() async {
    final p = context.read<AuthProvider>();
    await p.fetchAmenities();
    if (mounted) setState(() => _allAmenities = p.amenities);
  }

  Future<void> _loadStates() async {
    await context.read<AuthProvider>().loadStates();
  }

  Future<void> _prefillLocationFromGPS() async {
    try {

      final coords = await LatLngService.getLatLng(context);
      if (coords != null) {
        final lat = coords['lat']!;
        final lng = coords['lng']!;
        latitudeController.text = '$lat';
        longitudeController.text = '$lng';

        try {
          final parts =
              await AddressService.addressPartsFromLatLng(lat: lat, lng: lng);
          if (parts != null) {
            final city = (parts.locality ?? '').trim();
            final state = (parts.administrativeArea ?? '').trim();
            final fmt = parts.formatted.trim();

            if (city.isNotEmpty) cityController.text = city;
            if (state.isNotEmpty) stateController.text = state;

            final prov = context.read<AuthProvider>();
            if (state.isNotEmpty && prov.states.isNotEmpty) {
              final match = prov.states.firstWhere(
                (s) => s.name.toLowerCase() == state.toLowerCase(),
                orElse: () => prov.states.first,
              );
              _selState = match;
              await prov.loadCities(match.id);
              if (city.isNotEmpty && prov.cities.isNotEmpty) {
                final cmatch = prov.cities.firstWhere(
                  (c) => c.name.toLowerCase() == city.toLowerCase(),
                  orElse: () => prov.cities.first,
                );
                _selCity = cmatch;
              }
            }

            if (fmt.isNotEmpty) {
              addressController.text = fmt;
            }
          }
        } catch (e) {
          debugPrint('⚠️ Reverse geocoding error: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Prefill error: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      setState(() {
        _imagePaths.add(picked.path);
        _currentImageIndex = _imagePaths.length - 1;
      });
    } catch (e) {
      _showMsg('Failed to pick image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
      if (_currentImageIndex >= _imagePaths.length && _imagePaths.isNotEmpty) {
        _currentImageIndex = _imagePaths.length - 1;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_saving) return;

    if (businessNameController.text.trim().isEmpty) {
      _showMsg('Please enter business name');
      return;
    }

    if (priceController.text.trim().isEmpty) {
      _showMsg('Please enter price');
      return;
    }

    setState(() => _saving = true);

    try {
      final user = await TokenStorage.getUserData();
      if (user == null) {
        _showMsg('User not found');
        return;
      }

      final vendorId = user.id ?? 0;

      // Upload first image (business cover)
      String? uploadedPath;
      if (_imagePaths.isNotEmpty) {
        final resp = await context
            .read<AuthProvider>()
            .upload(_imagePaths.first, 'business_photos');
        if (resp != null && resp.success && resp.path.trim().isNotEmpty) {
          uploadedPath = resp.path;
        }
      }

      if (isVenue) {
        // Create venue request
        final minBooking = int.tryParse(minCapacityController.text.trim()) ?? 0;
        final maxCapacity = int.tryParse(maxCapacityController.text.trim()) ?? 0;
        final basePrice = num.tryParse(priceController.text.trim()) ?? 0;

        // Validate subcategory selection
        if (_selectedSubcategoryId == null) {
          _showMsg('Please select a subcategory');
          return;
        }

        final amenities = _selectedAmenities
            .map((a) => VenueAmenityReq(amenityId: a.id, value: a.name))
            .toList();

        final details = VenueDetailsReq(
          minBooking: minBooking,
          maxCapacity: maxCapacity,
          basePrice: basePrice,
          extraGuestPrice: 0,
        );

        final request = VenueCreateRequest(
          vendorId: vendorId,
          subCategoryId: _selectedSubcategoryId!,
          name: businessNameController.text.trim(),
          description: descriptionController.text.trim(),
          image: uploadedPath ?? '',
          address: addressController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: '',
          latitude: latitudeController.text.trim(),
          longitude: longitudeController.text.trim(),
          details: details,
          amenities: amenities,
        );
        
        final ok = await context.read<AuthProvider>().createVenue(request);
        _showMsg(context.read<AuthProvider>().message ?? (ok ? 'Venue created' : 'Failed'));
        if (ok && mounted) Navigator.pop(context);
      } else {
        // Create service request
        final priceNum = num.tryParse(priceController.text.trim()) ?? 0;
        
        // Validate subcategory selection
        if (_selectedSubcategoryId == null) {
          _showMsg('Please select a subcategory');
          return;
        }
        
        final request = ServiceAddRequest(
          vendorId: vendorId,
          subCategoryId: _selectedSubcategoryId!,
          name: businessNameController.text.trim(),
          description: descriptionController.text.trim(),
          basePrice: priceNum,
          priceType: 'day',
          location: addressController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          status: 1,
          verify: 0,
          latitude: latitudeController.text.trim(),
          longitude: longitudeController.text.trim(),
          image: uploadedPath ?? '',
        );
        
        final ok = await context.read<AuthProvider>().createService(request);
        _showMsg(context.read<AuthProvider>().message ?? (ok ? 'Service added' : 'Failed'));
        if (ok && mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showMsg('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMsg(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    businessNameController.dispose();
    categoryController.dispose();
    subcategoryController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    maxCapacityController.dispose();
    minCapacityController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    amenitiesController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel or Upload Button
                      if (_imagePaths.isNotEmpty) ...[
                        _buildImageCarousel(),
                        const SizedBox(height: 16),
                      ],
                      // Business Name
                      _buildTextField(
                        'Business Name',
                        'Enter your business name',
                        businessNameController,
                      ),
                      const SizedBox(height: 16),
                      // Category
                      _buildDropdownField(
                        'Category',
                        _selectedCategoryName ?? 'Select Category',
                        onTap: () async {
                          final picked = await _showCategoryPicker(context);
                          if (picked != null) {
                            setState(() {
                              _selectedCategoryId = picked.id;
                              _selectedCategoryName = picked.name;
                              _selectedSubcategoryId = null;
                              _selectedSubcategoryName = null;
                              categoryController.text = picked.name;
                            });
                            await context.read<AuthProvider>().fetchSubcategories(picked.id);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Subcategory
                      _buildDropdownField(
                        'Subcategory',
                        _selectedSubcategoryName ?? 'Select Subcategory',
                        onTap: () async {
                          if (_selectedCategoryId == null) {
                            _showMsg('Please select a category first');
                            return;
                          }
                          final picked = await _showSubcategoryPicker(context);
                          if (picked != null) {
                            setState(() {
                              _selectedSubcategoryId = picked.id;
                              _selectedSubcategoryName = picked.name;
                              subcategoryController.text = picked.name;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description
                      _buildTextField(
                        'Description',
                        'Add Description',
                        descriptionController,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      // Price
                      _buildTextField(
                        'Price',
                        'Enter your service price',
                        priceController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      // Booking Capacity (for venues)
                      if (isVenue) ...[
                        const Text(
                          'Booking Capacity',
                          style: TextStyle(
                            color: Color(0xFF746E85),
                            fontSize: 18,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Maximum Capacity',
                                '300',
                                maxCapacityController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'Minimum Capacity',
                                '50',
                                minCapacityController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Address
                      _buildTextField(
                        'Address',
                        'Enter your address',
                        addressController,
                      ),
                      const SizedBox(height: 16),
                      // City & State
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'City',
                              _selCity?.name ?? (cityController.text.isEmpty
                                  ? 'City'
                                  : cityController.text),
                              onTap: () async {
                                final sid = _selState?.id;
                                if (sid == null) {
                                  _showMsg('Please select a State first');
                                  return;
                                }
                                final picked =
                                    await _showCityPicker(context, sid);
                                if (picked != null) {
                                  setState(() {
                                    _selCity = picked;
                                    cityController.text = picked.name;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              'State',
                              _selState?.name ?? (stateController.text.isEmpty
                                  ? 'State'
                                  : stateController.text),
                              onTap: () async {
                                final picked = await _showStatePicker(context);
                                if (picked != null) {
                                  setState(() {
                                    _selState = picked;
                                    stateController.text = picked.name;
                                    _selCity = null;
                                    cityController.clear();
                                  });
                                  await context
                                      .read<AuthProvider>()
                                      .loadCities(picked.id);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Amenities (for venues)
                      if (isVenue) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              'Amenties',
                              _selectedAmenities.isEmpty
                                  ? 'Enter your amenties you provide'
                                  : _selectedAmenities
                                      .map((a) => a.name)
                                      .join(', '),
                              amenitiesController,
                              readOnly: true,
                              onTap: _openAmenityPicker,
                            ),
                            if (_selectedAmenities.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                height: 24,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: Text(
                                        'Min ${minCapacityController.text.isEmpty ? "30" : minCapacityController.text}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF171719),
                                          fontSize: 12,
                                          fontFamily: 'Onest',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: Text(
                                        'Max ${maxCapacityController.text.isEmpty ? "4000" : maxCapacityController.text}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF171719),
                                          fontSize: 12,
                                          fontFamily: 'Onest',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),
              ),
              // Update Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4678),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              'assets/icons/arrow-left.png',
              width: 24,
              height: 24,
            ),
          ),
          const Expanded(
            child: Text(
              'Manage Service Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _pickImage,
            child: Image.asset(
              AppIcons.galleryExportIcon,
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: _imagePaths.length,
            options: CarouselOptions(
              height: 200,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() => _currentImageIndex = index);
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return Stack(
                children: [
                  Image.file(
                    File(_imagePaths[index]),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _imagePaths.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: ShapeDecoration(
                    color: _currentImageIndex == index
                        ? const Color(0xFFFF4678)
                        : const Color(0xFFDDDDDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF746E85),
            fontSize: 16,
            fontFamily: 'Onest',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF7C9BBF),
              fontSize: 16,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 1,
                color: Color(0xFFDBE2EA),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 1,
                color: Color(0xFFDBE2EA),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 2,
                color: Color(0xFFFF4678),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    {required VoidCallback onTap}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF746E85),
            fontSize: 16,
            fontFamily: 'Onest',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFFDBE2EA),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0A2C2738),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF7C9BBF),
                      fontSize: 16,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF7C9BBF),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<CategoryModelResponse?> _showCategoryPicker(BuildContext context) async {
    final prov = context.read<AuthProvider>();
    if (prov.categories.isEmpty) {
      _showMsg('No categories available');
      return null;
    }

    return await showModalBottomSheet<CategoryModelResponse>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Onest',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prov.categories.length,
                  itemBuilder: (context, index) {
                    final cat = prov.categories[index];
                    return ListTile(
                      title: Text(
                        cat.name,
                        style: const TextStyle(fontFamily: 'Onest'),
                      ),
                      onTap: () => Navigator.pop(context, cat),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<SubcategoryModelResponse?> _showSubcategoryPicker(BuildContext context) async {
    final prov = context.read<AuthProvider>();
    if (prov.subcategories.isEmpty) {
      _showMsg('No subcategories available');
      return null;
    }

    return await showModalBottomSheet<SubcategoryModelResponse>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Subcategory',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Onest',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prov.subcategories.length,
                  itemBuilder: (context, index) {
                    final subcat = prov.subcategories[index];
                    return ListTile(
                      title: Text(
                        subcat.name,
                        style: const TextStyle(fontFamily: 'Onest'),
                      ),
                      onTap: () => Navigator.pop(context, subcat),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<StateItem?> _showStatePicker(BuildContext context) async {
    final prov = context.read<AuthProvider>();
    if (prov.states.isEmpty) {
      _showMsg('No states available');
      return null;
    }

    return await showModalBottomSheet<StateItem>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select State',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Onest',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prov.states.length,
                  itemBuilder: (context, index) {
                    final state = prov.states[index];
                    return ListTile(
                      title: Text(state.name),
                      onTap: () => Navigator.pop(context, state),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<CityItem?> _showCityPicker(BuildContext context, int stateId) async {
    final prov = context.read<AuthProvider>();
    await prov.loadCities(stateId);

    if (prov.cities.isEmpty) {
      _showMsg('No cities available');
      return null;
    }

    return await showModalBottomSheet<CityItem>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select City',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Onest',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prov.cities.length,
                  itemBuilder: (context, index) {
                    final city = prov.cities[index];
                    return ListTile(
                      title: Text(city.name),
                      onTap: () => Navigator.pop(context, city),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAmenityPicker() async {
    if (_allAmenities.isEmpty) {
      _showMsg('No amenities available');
      return;
    }

    final selected = await showModalBottomSheet<List<AmenityModelResponse>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const Text(
                    'Select Amenities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Onest',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allAmenities.length,
                      itemBuilder: (context, index) {
                        final amenity = _allAmenities[index];
                        final isSelected =
                            _selectedAmenities.contains(amenity);
                        return CheckboxListTile(
                          title: Text(amenity.name),
                          value: isSelected,
                          onChanged: (checked) {
                            setModalState(() {
                              if (checked == true) {
                                _selectedAmenities.add(amenity);
                              } else {
                                _selectedAmenities.remove(amenity);
                              }
                            });
                          },
                          activeColor: const Color(0xFFFF4678),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _selectedAmenities);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4678),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        amenitiesController.text =
            _selectedAmenities.map((a) => a.name).join(', ');
      });
    }
  }
}
