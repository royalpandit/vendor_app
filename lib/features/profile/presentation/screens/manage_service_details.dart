import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/services/address_service.dart';
import 'package:vendor_app/core/services/lat_lng_service.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/core/utils/app_theme.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/subcategory_model_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/service_meta_field_response.dart';
import 'package:vendor_app/core/utils/app_message.dart';
import 'package:vendor_app/core/utils/result_popup.dart';
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
  bool _isVenue = false;

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
  final pincodeController = TextEditingController();
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
  // Dynamic meta fields for selected subcategory
  List<ServiceMetaFieldResponse> _metaFields = [];
  final Map<String, dynamic> _metaValues = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadAmenities(),
      _loadStates(),
      _prefillLocationFromGPS(),
    ]);
    // After parallel loads, resolve category from the vendor's subcategory ID
    await _resolveCategory();
  }

  /// Determine the parent category from `widget.subCategoryId`.
  /// Categories and subcategories are fetched from separate APIs.
  /// The vendor profile stores a subcategory ID in `business_category`,
  /// so we iterate through categories and fetch their subcategories to
  /// find which one contains the vendor's subcategory.
  Future<void> _resolveCategory() async {
    final prov = context.read<AuthProvider>();
    await prov.fetchCategories();
    final cats = prov.categories;
    if (cats.isEmpty) return;

    // If we have a subcategory ID from the vendor profile, find its parent category
    if (widget.subCategoryId > 0) {
      for (final cat in cats) {
        await prov.fetchSubcategories(cat.id);
        final subs = prov.subcategories;
        final match = subs.where((s) => s.id == widget.subCategoryId).firstOrNull;
        if (match != null) {
          if (!mounted) return;
          setState(() {
            _selectedCategoryId = cat.id;
            _selectedCategoryName = cat.name;
            categoryController.text = cat.name;
            _isVenue = cat.name.trim().toLowerCase() == 'venue';
          });
          // Subcategories are already fetched for this category
          return;
        }
      }
    }

    // Fallback: try to infer from widget.type
    if (_normalizedType.isNotEmpty) {
      for (final cat in cats) {
        if (cat.name.trim().toLowerCase() == _normalizedType ||
            cat.slug.trim().toLowerCase() == _normalizedType) {
          if (!mounted) return;
          setState(() {
            _selectedCategoryId = cat.id;
            _selectedCategoryName = cat.name;
            categoryController.text = cat.name;
            _isVenue = cat.name.trim().toLowerCase() == 'venue';
          });
          await prov.fetchSubcategories(cat.id);
          return;
        }
      }
    }

    // Final fallback: use first category
    if (!mounted) return;
    final first = cats.first;
    setState(() {
      _selectedCategoryId = first.id;
      _selectedCategoryName = first.name;
      categoryController.text = first.name;
      _isVenue = first.name.trim().toLowerCase() == 'venue';
    });
    await prov.fetchSubcategories(first.id);
  }

  Future<void> _loadAmenities() async {
    // ensure we are past the build phase before triggering provider notifications
    await Future.delayed(Duration.zero);
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
            final pincode = (parts.postalCode ?? '').trim();
            final fmt = parts.formatted.trim();

            if (city.isNotEmpty) cityController.text = city;
            if (state.isNotEmpty) stateController.text = state;
            if (pincode.isNotEmpty) pincodeController.text = pincode;

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
          // reverse geocoding error
        }
      }
    } catch (e) {
      // prefill error
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

    if (_imagePaths.isEmpty) {
      _showMsg('Please upload at least one image');
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

      if (_isVenue) {
        // Create venue request
        final minBooking = int.tryParse(minCapacityController.text.trim()) ?? 0;
        final maxCapacity = int.tryParse(maxCapacityController.text.trim()) ?? 0;
        final basePrice = num.tryParse(priceController.text.trim()) ?? 0;

        // Validate subcategory selection
        if (_selectedSubcategoryId == null) {
          _showMsg('Please select a subcategory');
          return;
        }
        
        // Validate city and pincode
        if (cityController.text.trim().isEmpty) {
          _showMsg('Please enter city');
          return;
        }
        
        if (pincodeController.text.trim().isEmpty) {
          _showMsg('Please enter pincode');
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
          pincode: pincodeController.text.trim(),
          latitude: latitudeController.text.trim(),
          longitude: longitudeController.text.trim(),
          details: details,
          amenities: amenities,
        );
        
        final ok = await context.read<AuthProvider>().createVenue(request);
        final vmsg = context.read<AuthProvider>().message ?? (ok ? 'Venue created successfully' : 'Failed to create venue');
        if (mounted) {
          await ResultPopup.show(context, success: ok, message: vmsg);
        }
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
          meta: _metaValues.isNotEmpty ? Map<String, dynamic>.from(_metaValues) : null,
        );
        
        final ok = await context.read<AuthProvider>().createService(request);
        final msg = context.read<AuthProvider>().message ?? (ok ? 'Service added successfully' : 'Failed to add service');
        if (mounted) {
          await ResultPopup.show(context, success: ok, message: msg);
        }
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
    // ignore: unawaited_futures
    AppMessage.show(context, message);
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
    pincodeController.dispose();
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
                      // Category is auto-selected from profile - show as read-only info
                      if (_selectedCategoryName != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDBE2EA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.category_outlined, color: Color(0xFFFF4678), size: 20),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Category', style: TextStyle(color: Color(0xFF746E85), fontSize: 12, fontFamily: 'Onest', fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 2),
                                  Text(_selectedCategoryName!, style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Onest', fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Subcategory
                      _buildDropdownField(
                        'Subcategory',
                        _selectedSubcategoryName ?? 'Select Subcategory',
                        onTap: () async {
                          if (_selectedCategoryId == null) {
                            _showMsg('Category not loaded yet. Please wait.');
                            return;
                          }
                          final picked = await _showSubcategoryPicker(context);
                          if (picked != null) {
                            setState(() {
                              _selectedSubcategoryId = picked.id;
                              _selectedSubcategoryName = picked.name;
                              subcategoryController.text = picked.name;
                            });
                            // fetch meta fields for this subcategory
                            await context.read<AuthProvider>().fetchServiceMetaFields(picked.id);
                            final meta = context.read<AuthProvider>().serviceMetaFields;
                            setState(() {
                              _metaFields = meta;
                              _metaValues.clear();
                              for (final f in _metaFields) {
                                final idKey = '${f.id}';
                                // initialize default values keyed by field id (string)
                                switch (f.type) {
                                  case 'toggle':
                                    _metaValues[idKey] = false;
                                    break;
                                  case 'multi_select':
                                    _metaValues[idKey] = <String>[];
                                    break;
                                  default:
                                    _metaValues[idKey] = null;
                                }
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dynamic Meta Fields
                      if (_metaFields.isNotEmpty) ...[
                        const Text(
                          'Additional Details',
                          style: TextStyle(
                            color: Color(0xFF746E85),
                            fontSize: 18,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._buildMetaFields(),
                        const SizedBox(height: 16),
                      ],
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
                      if (_isVenue) ...[
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
                      // State & City
                      Row(
                        children: [
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
                          const SizedBox(width: 16),
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Pincode
                      _buildTextField(
                        'Pincode',
                        'Enter pincode',
                        pincodeController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      // Amenities (for venues)
                      if (_isVenue) ...[
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
                            'Submit',
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
          style: AppTheme.bodyLarge.copyWith(
            color: const Color(0xFF746E85),
            fontWeight: FontWeight.w400,
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
              hintStyle: AppTheme.hintText.copyWith(fontSize: 16),
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
          style: AppTheme.inputText.copyWith(fontSize: 16),
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
          style: AppTheme.bodyLarge.copyWith(
            color: const Color(0xFF746E85),
            fontWeight: FontWeight.w400,
            fontSize: 16,
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
                  child: Builder(builder: (context) {
                    final isPlaceholder = value.toLowerCase().contains('select') || value == 'State' || value == 'City' || value == label;
                    return Text(
                      value,
                      style: isPlaceholder
                          ? AppTheme.hintText.copyWith(fontSize: 16)
                          : AppTheme.inputText.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFFF4678),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
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
              Text(
                'Select Subcategory',
                style: AppTheme.heading5.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prov.subcategories.length,
                  itemBuilder: (context, index) {
                    final subcat = prov.subcategories[index];
                    return ListTile(
                      title: Text(subcat.name, style: AppTheme.bodyRegular),
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
              Text(
                'Select State',
                style: AppTheme.heading5.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prov.states.length,
                  itemBuilder: (context, index) {
                    final state = prov.states[index];
                    return ListTile(
                      title: Text(state.name, style: AppTheme.bodyRegular),
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
              Text(
                'Select City',
                style: AppTheme.heading5.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prov.cities.length,
                  itemBuilder: (context, index) {
                    final city = prov.cities[index];
                    return ListTile(
                      title: Text(city.name, style: AppTheme.bodyRegular),
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

  List<Widget> _buildMetaFields() {
    return _metaFields.map((f) {
      final key = '${f.id}'; // use field id as the map key (string)
      switch (f.type) {
        case 'toggle':
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBE2EA)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(f.label, style: AppTheme.bodyLarge.copyWith(color: const Color(0xFF746E85), fontSize: 15)),
                  ),
                  Switch(
                    value: (_metaValues[key] as bool?) ?? false,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFFFF4678),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    onChanged: (v) => setState(() => _metaValues[key] = v),
                  ),
                ],
              ),
            ),
          );

        case 'select':
          final current = _metaValues[key] as String?;
          final opts = f.options ?? [];
          if (opts.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.label, style: AppTheme.bodyLarge.copyWith(color: const Color(0xFF746E85))),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: current,
                  decoration: InputDecoration(
                    hintText: f.label,
                    hintStyle: AppTheme.hintText.copyWith(fontSize: 16),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDBE2EA)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDBE2EA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(width: 2, color: Color(0xFFFF4678)),
                    ),
                  ),
                  onChanged: (v) => _metaValues[key] = v,
                  style: AppTheme.inputText.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.label, style: AppTheme.bodyLarge.copyWith(color: const Color(0xFF746E85))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBE2EA)),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: current,
                  hint: Text('Select ${f.label}', style: AppTheme.hintText.copyWith(fontSize: 16)),
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF4678)),
                  items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (v) => setState(() => _metaValues[key] = v),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );

        case 'multi_select':
          final List<String> selected = List<String>.from(_metaValues[key] ?? []);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.label, style: AppTheme.bodyLarge.copyWith(color: const Color(0xFF746E85))),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final res = await _showMultiSelectDialog(f);
                  if (res != null) setState(() => _metaValues[key] = res);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDBE2EA)),
                  ),
                  child: selected.isEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Select ${f.label}', style: AppTheme.hintText.copyWith(fontSize: 16)),
                            const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF4678)),
                          ],
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: selected.map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4678).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFF4678).withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(s, style: const TextStyle(color: Color(0xFFFF4678), fontSize: 13, fontFamily: 'Onest', fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selected.remove(s);
                                      _metaValues[key] = List<String>.from(selected);
                                    });
                                  },
                                  child: const Icon(Icons.close, size: 14, color: Color(0xFFFF4678)),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );

        case 'number':
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.label, style: AppTheme.bodyLarge.copyWith(color: const Color(0xFF746E85))),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _metaValues[key]?.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: f.label,
                  hintStyle: AppTheme.hintText.copyWith(fontSize: 16),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFDBE2EA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFDBE2EA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(width: 2, color: Color(0xFFFF4678)),
                  ),
                ),
                onChanged: (v) => _metaValues[key] = num.tryParse(v) ?? v,
                style: AppTheme.inputText.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
            ],
          );

        default:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.label, style: AppTheme.bodyLarge.copyWith(color: const Color(0xFF746E85))),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _metaValues[key]?.toString(),
                decoration: InputDecoration(
                  hintText: f.label,
                  hintStyle: AppTheme.hintText.copyWith(fontSize: 16),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFDBE2EA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFDBE2EA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(width: 2, color: Color(0xFFFF4678)),
                  ),
                ),
                onChanged: (v) => _metaValues[key] = v,
                style: AppTheme.inputText.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
            ],
          );
      }
    }).toList();
  }

  Future<List<String>?> _showMultiSelectDialog(ServiceMetaFieldResponse f) async {
    final opts = f.options ?? [];
    final idKey = '${f.id}';
    final current = List<String>.from(_metaValues[idKey] ?? []);
    final selected = <String>{...current};

    return showDialog<List<String>>(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Select ${f.label}'),
        content: StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: opts.map((o) {
                final isSel = selected.contains(o);
                return CheckboxListTile(
                  value: isSel,
                  title: Text(o),
                  onChanged: (v) => setState(() => v == true ? selected.add(o) : selected.remove(o)),
                );
              }).toList(),
            ),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, selected.toList()), child: const Text('OK')),
        ],
      );
    });
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
                  Text(
                    'Select Amenities',
                    style: AppTheme.heading5.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
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
                          title: Text(amenity.name, style: AppTheme.bodyRegular),
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
