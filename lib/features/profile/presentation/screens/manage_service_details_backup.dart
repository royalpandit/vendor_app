import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
  import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/services/address_service.dart';
import 'package:vendor_app/core/services/lat_lng_service.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_message.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';  // For context.read()
import 'package:vendor_app/features/profile/data/models/request/service_add_request.dart';
import 'package:vendor_app/features/profile/data/models/request/venue_create_request.dart';
import 'package:vendor_app/features/profile/data/models/resposne/amenity_model_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/cities_data.dart';
import 'package:vendor_app/features/profile/data/models/resposne/states_data.dart';

class ManageServiceDetailsScreen extends StatefulWidget {
  const ManageServiceDetailsScreen({
    super.key,
    required this.type,         // 'service' | 'venue'
    required this.subCategoryId // selected sub-category id
  });

  final String type;
  final int subCategoryId;

  @override
  _ManageServiceDetailsScreenState createState() =>
      _ManageServiceDetailsScreenState();
}

class _ManageServiceDetailsScreenState extends State<ManageServiceDetailsScreen> {

  // ✅ Normalize type once and reuse
  String get _normalizedType => (widget.type).trim().toLowerCase();

  // ✅ Only 'venue' shows venue section, anything else → service section
  String? businessCoverImagePath; // selected local image path

  // Common fields
  final businessNameController = TextEditingController();
  final servicePriceController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final latitudeController = TextEditingController();   // HIDDEN (API only)
  final longitudeController = TextEditingController();  // HIDDEN (API only)

  // Venue-only
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final minBookingController = TextEditingController();
  final maxCapacityController = TextEditingController();
  final extraGuestPriceController = TextEditingController();

  bool _saving = false;      // submit progress
  bool _uploading = false;   // image upload progress
  bool _locLoading = false;  // location prefill progress

  // Amenities state (for multi-select)
  List<AmenityModelResponse> _allAmenities = [];
  final List<AmenityModelResponse> _selectedAmenities = [];

  // State/City picker state
  StateItem? _selState;
  CityItem?  _selCity;

 // bool get isVenue => widget.type.toLowerCase() == 'venue';
  bool get isVenue => _normalizedType == 'venue';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1) Amenities
      final p = context.read<AuthProvider>();
      await p.fetchAmenities();
      setState(() => _allAmenities = p.amenities);

      // 2) States list (for picker)
      await context.read<AuthProvider>().loadStates();

      // 3) Location prefill (lat/lng + address parts)
      await _prefillLocationFromGPS();
    });
  }

  @override
  void dispose() {
    businessNameController.dispose();
    servicePriceController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    cityController.dispose();
    stateController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    minBookingController.dispose();
    maxCapacityController.dispose();
    extraGuestPriceController.dispose();
    super.dispose();
  }

  // ────────────────────────── Prefill Location (AUTO) ──────────────────────────
  Future<void> _prefillLocationFromGPS() async {
    try {
      setState(() => _locLoading = true);

      final coords = await LatLngService.getLatLng(context);
      if (coords != null) {
        final lat = coords['lat']!;
        final lng = coords['lng']!;
        latitudeController.text  = '$lat';
        longitudeController.text = '$lng';
        // Prefill lat/lng available

        try {
          final parts = await AddressService.addressPartsFromLatLng(lat: lat, lng: lng);
          if (parts != null) {
            final city   = (parts.locality ?? '').trim();
            final state  = (parts.administrativeArea ?? '').trim();
            final fmt    = (parts.formatted ).trim();

            if (city.isNotEmpty)  cityController.text = city;
            if (state.isNotEmpty) stateController.text = state;

            // Set picker selection if present in master lists (optional best-effort)
            final prov = context.read<AuthProvider>();
            if (state.isNotEmpty && prov.states.isNotEmpty) {
              final match = prov.states.firstWhere(
                    (s) => s.name.toLowerCase() == state.toLowerCase(),
                orElse: () => prov.states.first,
              );
              _selState = match;
              // cities for this state
              await prov.loadCities(match.id);
              if (city.isNotEmpty && prov.cities.isNotEmpty) {
                final cmatch = prov.cities.firstWhere(
                      (c) => c.name.toLowerCase() == city.toLowerCase(),
                  orElse: () => prov.cities.first,
                );
                _selCity = cmatch;
              }
            }

            // location field
            if (fmt.isNotEmpty) {
              locationController.text = fmt;
              if (isVenue) addressController.text = fmt;
            } else if (cityController.text.isNotEmpty) {
              locationController.text = cityController.text;
            }
          }
        } catch (e) {
          // Reverse geocoding error
        }
      } else {
        // Location not available (coords=null)
      }
    } catch (e) {
      // Prefill error
    } finally {
      if (mounted) setState(() => _locLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuthProvider>(); // amenities/states/cities loading etc.

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: Text(isVenue ? "Manage Venue Details" : "Manage Service Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                if (_locLoading)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  const Icon(Icons.my_location, size: 18, color: Colors.green),
                const SizedBox(width: 6),
                Text(_locLoading ? 'Locating…' : 'Location set',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: businessCoverImagePath == null
                    ? Center(
                  child: _uploading
                      ? const SizedBox(
                    height: 26, width: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                      : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                )
                    : Image.file(File(businessCoverImagePath!), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // Common fields
            _buildLabel("Business Name"),
            _tf(businessNameController, hint: "Enter Business Name"),
            _sp8(),

            _buildLabel(isVenue ? "Base Price" : "Service Price"),
            _tf(servicePriceController, hint: "e.g. 5000", type: TextInputType.number),
            _sp8(),

            _buildLabel("Description"),
            _tf(descriptionController, hint: "Write something..."),
            _sp8(),

            _buildLabel("Location"),
            _tf(locationController, hint: "e.g. Mumbai"),
            _sp8(),

            // ─────────── State / City PICKERS (API-Backed) ───────────
            _buildLabel("State & City"),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _SelectField(
                    label: 'State',
                    value: _selState?.name.isNotEmpty == true
                        ? _selState!.name
                        : (stateController.text.isNotEmpty ? stateController.text : null),
                    loading: p.loading,
                    onTap: () async {
                      final picked = await _showStatePicker(context);
                      if (picked != null) {
                        setState(() {
                          _selState = picked;
                          stateController.text = picked.name;
                          _selCity = null;
                          cityController.clear();
                        });
                        await context.read<AuthProvider>().loadCities(picked.id);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SelectField(
                    label: 'City',
                    value: _selCity?.name.isNotEmpty == true
                        ? _selCity!.name
                        : (cityController.text.isNotEmpty ? cityController.text : null),
                    loading: p.loading,
                    onTap: () async {
                      final sid = _selState?.id;
                      if (sid == null) {
                        _showMsg('Please select a State first');
                        return;
                      }
                      final picked = await _showCityPicker(context, sid);
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
            _sp12(),

            // Venue-only fields
            if (isVenue) ...[
              _buildLabel("Address"),
              _tf(addressController, hint: "123 Event Street"),
              _sp8(),

              Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Pincode"),
                      _tf(pincodeController, hint: "110001", type: TextInputType.number),
                    ],
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Min Booking"),
                      _tf(minBookingController, hint: "50", type: TextInputType.number),
                    ],
                  )),
                ],
              ),
              _sp8(),

              Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Max Capacity"),
                      _tf(maxCapacityController, hint: "200", type: TextInputType.number),
                    ],
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Extra Guest Price"),
                      _tf(extraGuestPriceController, hint: "100", type: TextInputType.number),
                    ],
                  )),
                ],
              ),
              _sp12(),

              // -------------------- Amenities (API + Multi-select) --------------------
              _buildLabel("Amenities"),
              const SizedBox(height: 6),

              if (p.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('Loading amenities…'),
                    ],
                  ),
                ),

              if (!p.loading && _allAmenities.isEmpty)
                Row(
                  children: [
                    const Expanded(child: Text('No amenities found')),
                    TextButton(
                      onPressed: () async {
                        await context.read<AuthProvider>().fetchAmenities();
                        setState(() => _allAmenities = context.read<AuthProvider>().amenities);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),

              if (!p.loading && _allAmenities.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.playlist_add_check_rounded),
                    label: const Text('Select Amenities'),
                    onPressed: _openAmenityPicker,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.pinkColor),
                      foregroundColor: AppColors.pinkColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

              if (_selectedAmenities.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: -6,
                  children: _selectedAmenities.map((a) => _AmenityChip(
                    text: a.name,
                    onRemove: () {
                      setState(() => _selectedAmenities.removeWhere((x) => x.id == a.id));
                    },
                  )).toList(),
                ),
              ],
              _sp12(),
            ],

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_saving ? 'Saving…' : 'Save', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────── Image Pick + Upload ──────────────────────────
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;

    setState(() => businessCoverImagePath = picked.path);
    await _uploadCoverToServer();
  }

  Future<String?> _uploadCoverToServer() async {
    if (businessCoverImagePath == null) return null;

    try {
      setState(() => _uploading = true);
      final resp = await context.read<AuthProvider>().upload(
        businessCoverImagePath!,
        isVenue ? 'venues' : 'services',
      );
      setState(() => _uploading = false);

      if (resp == null || !resp.success || resp.path.trim().isEmpty) {
        _showMsg(context.read<AuthProvider>().message ?? 'Image upload failed');
        return null;
      }
      _showMsg(resp.message);
      return resp.path;
    } catch (e) {
      setState(() => _uploading = false);
      _showMsg('Image upload error: $e');
      return null;
    }
  }

  // ────────────────────────── Amenities Picker ──────────────────────────
  Future<void> _openAmenityPicker() async {
    String query = '';
    final picked = await showModalBottomSheet<List<AmenityModelResponse>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final tempSelected = _selectedAmenities.map((e) => e.id).toSet();

        return StatefulBuilder(
          builder: (ctx, set) {
            final items = _allAmenities.where((a) {
              if (query.isEmpty) return true;
              return a.name.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(ctx).viewInsets.bottom + 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHandle(),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select Amenities',
                        style: TextStyle(fontFamily: 'OnestMedium', fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search amenity…',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.textFieldColor),
                      ),
                    ),
                    onChanged: (v) => set(() => query = v.trim()),
                  ),
                  const SizedBox(height: 10),

                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('No amenities'),
                    )
                  else
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final a = items[i];
                          final selected = tempSelected.contains(a.id);
                          return ListTile(
                            onTap: () {
                              set(() {
                                if (selected) {
                                  tempSelected.remove(a.id);
                                } else {
                                  tempSelected.add(a.id);
                                }
                              });
                            },
                            leading: Icon(
                              selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              color: selected ? AppColors.pinkColor : AppColors.accentColor,
                            ),
                            title: Text(a.name),
                            subtitle: a.type != null ? Text(a.type!) : null,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, null),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.textFieldColor),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final finalList = _allAmenities.where((a) => tempSelected.contains(a.id)).toList();
                            Navigator.pop(ctx, finalList);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkColor),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedAmenities
          ..clear()
          ..addAll(picked);
      });
    }
  }

  // ────────────────────────── State / City Pickers ──────────────────────────
  Future<StateItem?> _showStatePicker(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.loadStates();

    return showModalBottomSheet<StateItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.accentColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, set) {
            final isLoading = auth.loading;
            final items = auth.states.where((s) {
              if (query.isEmpty) return true;
              return s.name.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHandle(),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select State', style: TextStyle(
                      fontFamily: 'OnestMedium', fontWeight: FontWeight.w600, fontSize: 16,
                    )),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search state...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.textFieldColor),
                      ),
                    ),
                    onChanged: (v) => set(() => query = v.trim()),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  if (!isLoading)
                    Flexible(
                      child: items.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No states found'),
                      )
                          : ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = items[i];
                          return ListTile(
                            title: Text(s.name),
                            onTap: () => Navigator.pop(ctx, s),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<CityItem?> _showCityPicker(BuildContext context, int stateId) async {
    final auth = context.read<AuthProvider>();
    await auth.loadCities(stateId);

    return showModalBottomSheet<CityItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.accentColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, set) {
            final isLoading = auth.loading;
            final items = auth.cities.where((c) {
              if (query.isEmpty) return true;
              return c.name.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHandle(),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select City', style: TextStyle(
                      fontFamily: 'OnestMedium', fontWeight: FontWeight.w600, fontSize: 16,
                    )),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.textFieldColor),
                      ),
                    ),
                    onChanged: (v) => set(() => query = v.trim()),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  if (!isLoading)
                    Flexible(
                      child: items.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No cities found'),
                      )
                          : ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final c = items[i];
                          return ListTile(
                            title: Text(c.name),
                            onTap: () => Navigator.pop(ctx, c),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ────────────────────────── Submit (Create) ──────────────────────────
  Future<void> _onSubmit() async {
    if (businessNameController.text.trim().isEmpty) {
      _showMsg('Please enter Business Name'); return;
    }
    if (servicePriceController.text.trim().isEmpty) {
      _showMsg(isVenue ? 'Please enter Base Price' : 'Please enter Service Price'); return;
    }

    // ensure image uploaded
    String? uploadedPath;
    if (businessCoverImagePath != null) {
      uploadedPath = await _uploadCoverToServer();
      if (uploadedPath == null) return;
    }

    // Make sure controllers carry picker values (API expects names)
    if (_selState != null) stateController.text = _selState!.name;
    if (_selCity  != null) cityController.text  = _selCity!.name;

    setState(() => _saving = true);
    try {
      final user = await TokenStorage.getUserData();
      final vendorId = user?.id ?? 0;

      if (!isVenue) {
        // SERVICE CREATE
        final priceNum = num.tryParse(servicePriceController.text.trim()) ?? 0;

        final req = ServiceAddRequest(
          vendorId: vendorId,
          subCategoryId: widget.subCategoryId,          name: businessNameController.text.trim(),
          description: descriptionController.text.trim(),
          basePrice: priceNum,
          priceType: "event",

          location: addressController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),

          status: true,
          verify: false,

          latitude: latitudeController.text.trim(),
          longitude: longitudeController.text.trim(),

          profileImage:  "",
          galleryImages: [""],

          ownerName: businessNameController.text.trim(),
          experienceYears: 0,

          contactNumber: "",
          whatsappNumber: "",
          email: "",
          serviceAreas: "",
          gstNumber: "",

          meta: null,
        );


        final ok = await context.read<AuthProvider>().createService(req);
        _showMsg(context.read<AuthProvider>().message ?? (ok ? 'Service added' : 'Failed'));
        if (ok && mounted) Navigator.pop(context);

      } else {
        // VENUE CREATE
        final minBooking = int.tryParse(minBookingController.text.trim().isEmpty ? '0' : minBookingController.text.trim()) ?? 0;
        final maxCapacity = int.tryParse(maxCapacityController.text.trim().isEmpty ? '0' : maxCapacityController.text.trim()) ?? 0;
        final basePrice  = num.tryParse(servicePriceController.text.trim().isEmpty ? '0' : servicePriceController.text.trim()) ?? 0;
        final extraGuest = num.tryParse(extraGuestPriceController.text.trim().isEmpty ? '0' : extraGuestPriceController.text.trim()) ?? 0;

        final amenities = _selectedAmenities
            .map((a) => VenueAmenityReq(amenityId: a.id, value: a.name))
            .toList();

        final details = VenueDetailsReq(
          minBooking: minBooking,
          maxCapacity: maxCapacity,
          basePrice: basePrice,
          extraGuestPrice: extraGuest,
        );

        final req = VenueCreateRequest(
          vendorId: vendorId,
          subCategoryId: widget.subCategoryId,
          name: businessNameController.text.trim(),
          description: descriptionController.text.trim(),
          image: uploadedPath ?? '',
          address: addressController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: pincodeController.text.trim(),
          latitude: latitudeController.text.trim(),   // auto (hidden)
          longitude: longitudeController.text.trim(), // auto (hidden)
          details: details,
          amenities: amenities,
        );

        final ok = await context.read<AuthProvider>().createVenue(req);
        _showMsg(context.read<AuthProvider>().message ?? (ok ? 'Venue created' : 'Failed'));
        if (ok && mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showMsg('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ────────────────────────── UI helpers ──────────────────────────
  Widget _buildLabel(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: 'OnestMedium',
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColors.labelColor,
    ),
  );

  Widget _tf(TextEditingController c, {String? hint, TextInputType? type}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint ?? '',
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
    );
  }

  SizedBox _sp8() => const SizedBox(height: 10);
  SizedBox _sp12() => const SizedBox(height: 12);

  Widget _sheetHandle() => Container(
    width: double.infinity,
    alignment: Alignment.center,
    child: Container(
      width: 44, height: 5,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.black12, borderRadius: BorderRadius.circular(999),
      ),
    ),
  );

  void _showMsg(String? message) {
    if (!mounted) return;
    // ignore: unawaited_futures
    AppMessage.show(context, message ?? 'Something went wrong');
  }
}

// ---------- small chip widget for selected amenities ----------
class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.text, required this.onRemove});
  final String text;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        text,
        style: TextStyle(
          fontFamily: 'Onest',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: AppColors.accentColor,
    );
  }
}

// ---------- small select field (read-only tap) ----------
class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.onTap,
    this.value,
    this.loading = false,
  });

  final String label;
  final String? value;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textFieldColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textFieldColor),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? 'Select $label',
                style: TextStyle(
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: value == null ? AppColors.textFieldColor : const Color(0xFF171719),
                ),
              ),
            ),
            if (loading)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            else
              const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}


/*class ManageServiceDetailsScreen extends StatefulWidget {
  const ManageServiceDetailsScreen({
    super.key,
    required this.type,         // 'service' | 'venue'
    required this.subCategoryId // selected sub-category id
  });

  final String type;
  final int subCategoryId;

  @override
  _ManageServiceDetailsScreenState createState() =>
      _ManageServiceDetailsScreenState();
}

class _ManageServiceDetailsScreenState extends State<ManageServiceDetailsScreen> {
  String? businessCoverImagePath; // selected local image path

  // Common fields
  final businessNameController = TextEditingController();
  final servicePriceController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Venue-only
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final minBookingController = TextEditingController();
  final maxCapacityController = TextEditingController();
  final extraGuestPriceController = TextEditingController();

  bool _saving = false;      // submit progress
  bool _uploading = false;   // image upload progress

  // Amenities state (for multi-select)
  List<AmenityModelResponse> _allAmenities = [];
  final List<AmenityModelResponse> _selectedAmenities = [];

  bool get isVenue => widget.type.toLowerCase() == 'venue';

  @override
  void initState() {
    super.initState();
    // स्क्रीन खुलते ही amenities fetch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<AuthProvider>();
      await p.fetchAmenities();
      setState(() {
        _allAmenities = p.amenities;
      });
    });
  }

  @override
  void dispose() {
    businessNameController.dispose();
    servicePriceController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    cityController.dispose();
    stateController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    minBookingController.dispose();
    maxCapacityController.dispose();
    extraGuestPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuthProvider>(); // amenities loading etc.

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: Text(isVenue ? "Manage Venue Details" : "Manage Service Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: businessCoverImagePath == null
                    ? Center(
                  child: _uploading
                      ? const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                      : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                )
                    : Image.file(File(businessCoverImagePath!), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // Common fields
            _buildLabel("Business Name"),
            _tf(businessNameController, hint: "Enter Business Name"),
            _sp8(),

            _buildLabel(isVenue ? "Base Price" : "Service Price"),
            _tf(servicePriceController, hint: "e.g. 5000", type: TextInputType.number),
            _sp8(),

            _buildLabel("Description"),
            _tf(descriptionController, hint: "Write something..."),
            _sp8(),

            _buildLabel("Location"),
            _tf(locationController, hint: "e.g. Mumbai"),
            _sp8(),

            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("City"),
                    _tf(cityController, hint: "e.g. Mumbai"),
                  ],
                )),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("State"),
                    _tf(stateController, hint: "e.g. Maharashtra"),
                  ],
                )),
              ],
            ),
            _sp8(),

            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Latitude"),
                    _tf(latitudeController, hint: "19.0760", type: TextInputType.number),
                  ],
                )),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Longitude"),
                    _tf(longitudeController, hint: "72.8777", type: TextInputType.number),
                  ],
                )),
              ],
            ),
            _sp12(),

            // Venue-only fields
            if (isVenue) ...[
              _buildLabel("Address"),
              _tf(addressController, hint: "123 Event Street"),
              _sp8(),

              Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Pincode"),
                      _tf(pincodeController, hint: "110001", type: TextInputType.number),
                    ],
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Min Booking"),
                      _tf(minBookingController, hint: "50", type: TextInputType.number),
                    ],
                  )),
                ],
              ),
              _sp8(),

              Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Max Capacity"),
                      _tf(maxCapacityController, hint: "200", type: TextInputType.number),
                    ],
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Extra Guest Price"),
                      _tf(extraGuestPriceController, hint: "100", type: TextInputType.number),
                    ],
                  )),
                ],
              ),
              _sp12(),

              // -------------------- Amenities (API + Multi-select) --------------------
              _buildLabel("Amenities"),
              const SizedBox(height: 6),

              // Loader / Retry
              if (p.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Loading amenities…'),
                    ],
                  ),
                ),
              if (!p.loading && _allAmenities.isEmpty)
                Row(
                  children: [
                    const Expanded(child: Text('No amenities found')),
                    TextButton(
                      onPressed: () async {
                        await context.read<AuthProvider>().fetchAmenities();
                        setState(() {
                          _allAmenities = context.read<AuthProvider>().amenities;
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),

              // Select button
              if (!p.loading && _allAmenities.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.playlist_add_check_rounded),
                    label: const Text('Select Amenities'),
                    onPressed: _openAmenityPicker,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.pinkColor),
                      foregroundColor: AppColors.pinkColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

              // Selected chips
              if (_selectedAmenities.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: -6,
                  children: _selectedAmenities.map((a) => _AmenityChip(
                    text: a.name,
                    onRemove: () {
                      setState(() {
                        _selectedAmenities.removeWhere((x) => x.id == a.id);
                      });
                    },
                  )).toList(),
                ),
              ],
              _sp12(),
            ],

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_saving ? 'Saving…' : 'Save', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────── Image Pick + Upload ──────────────────────────
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;

    setState(() {
      businessCoverImagePath = picked.path;
    });

    // तुरंत सर्वर पर अपलोड भी कर दें (Master Image Upload)
    await _uploadCoverToServer();
  }

  Future<String?> _uploadCoverToServer() async {
    if (businessCoverImagePath == null) return null;

    try {
      setState(() => _uploading = true);
      final resp = await context.read<AuthProvider>().upload(
        businessCoverImagePath!,
        isVenue ? 'venues' : 'services', // folder नाम
      );
      setState(() => _uploading = false);

      if (resp == null || !resp.success || resp.path.trim().isEmpty) {
        _showMsg(context.read<AuthProvider>().message ?? 'Image upload failed');
        return null;
      }
      _showMsg(resp.message);
      // resp.path ही बाद में create payload में "image" के रूप में जाएगा
      return resp.path;
    } catch (e) {
      setState(() => _uploading = false);
      _showMsg('Image upload error: $e');
      return null;
    }
  }

  // ────────────────────────── Amenities Picker ──────────────────────────
  Future<void> _openAmenityPicker() async {
    String query = '';
    final picked = await showModalBottomSheet<List<AmenityModelResponse>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        // Local selection set (start with current selection)
        final tempSelected = _selectedAmenities.map((e) => e.id).toSet();

        return StatefulBuilder(
          builder: (ctx, set) {
            final items = _allAmenities.where((a) {
              if (query.isEmpty) return true;
              return a.name.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(ctx).viewInsets.bottom + 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHandle(),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Amenities',
                      style: TextStyle(fontFamily: 'OnestMedium', fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search amenity…',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.textFieldColor),
                      ),
                    ),
                    onChanged: (v) => set(() => query = v.trim()),
                  ),
                  const SizedBox(height: 10),

                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('No amenities'),
                    )
                  else
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final a = items[i];
                          final selected = tempSelected.contains(a.id);
                          return ListTile(
                            onTap: () {
                              set(() {
                                if (selected) {
                                  tempSelected.remove(a.id);
                                } else {
                                  tempSelected.add(a.id);
                                }
                              });
                            },
                            leading: Icon(
                              selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              color: selected ? AppColors.pinkColor : AppColors.accentColor,
                            ),
                            title: Text(a.name),
                            subtitle: a.type != null ? Text(a.type!) : null,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, null),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.textFieldColor),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final finalList = _allAmenities.where((a) => tempSelected.contains(a.id)).toList();
                            Navigator.pop(ctx, finalList);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkColor),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedAmenities
          ..clear()
          ..addAll(picked);
      });
    }
  }

  // ────────────────────────── Submit (Create) ──────────────────────────
  Future<void> _onSubmit() async {
    // basic checks
    if (businessNameController.text.trim().isEmpty) {
      _showMsg('Please enter Business Name'); return;
    }
    if (servicePriceController.text.trim().isEmpty) {
      _showMsg(isVenue ? 'Please enter Base Price' : 'Please enter Service Price'); return;
    }

    // ensure image path from server (if user selected image but not uploaded yet)
    String? uploadedPath;
    if (businessCoverImagePath != null) {
      uploadedPath = await _uploadCoverToServer();
      if (uploadedPath == null) return; // uploading failed
    }

    setState(() => _saving = true);
    try {
      final user = await TokenStorage.getUserData();
      final vendorId = user?.id ?? 0; // आपके बैकएंड में vendor_id = user_id मैप है

      if (!isVenue) {
        // ============== SERVICE CREATE ==============
        final priceNum = num.tryParse(servicePriceController.text.trim()) ?? 0;
        final req = ServiceAddRequest(
          vendorId: vendorId,
          subCategoryId: widget.subCategoryId,
          name: businessNameController.text.trim(),
          description: descriptionController.text.trim(),
          basePrice: priceNum,
          priceType: 'day', // UI से चुनना हो तो जोड़ें
          location: locationController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          status: 1,
          verify: 0,
          latitude: latitudeController.text.trim(),
          longitude: longitudeController.text.trim(),
          image: uploadedPath ?? '', // master upload ka path
        );

        final ok = await context.read<AuthProvider>().createService(req);
        _showMsg(context.read<AuthProvider>().message ?? (ok ? 'Service added' : 'Failed'));
        if (ok && mounted) Navigator.pop(context);

      } else {
        // ============== VENUE CREATE ==============
        final minBooking = int.tryParse(minBookingController.text.trim().isEmpty ? '0' : minBookingController.text.trim()) ?? 0;
        final maxCapacity = int.tryParse(maxCapacityController.text.trim().isEmpty ? '0' : maxCapacityController.text.trim()) ?? 0;
        final basePrice  = num.tryParse(servicePriceController.text.trim().isEmpty ? '0' : servicePriceController.text.trim()) ?? 0;
        final extraGuest = num.tryParse(extraGuestPriceController.text.trim().isEmpty ? '0' : extraGuestPriceController.text.trim()) ?? 0;

        // ✅ amenities: multi-select से आये —> [{amenity_id, value}]
        final amenities = _selectedAmenities
            .map((a) => VenueAmenityReq(amenityId: a.id, value: a.name))
            .toList();

        final details = VenueDetailsReq(
          minBooking: minBooking,
          maxCapacity: maxCapacity,
          basePrice: basePrice,
          extraGuestPrice: extraGuest,
        );

        final req = VenueCreateRequest(
          vendorId: vendorId,
          subCategoryId: widget.subCategoryId,
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

        final ok = await context.read<AuthProvider>().createVenue(req);
        _showMsg(context.read<AuthProvider>().message ?? (ok ? 'Venue created' : 'Failed'));
        if (ok && mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showMsg('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ────────────────────────── UI helpers ──────────────────────────
  Widget _buildLabel(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: 'OnestMedium',
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColors.labelColor,
    ),
  );

  Widget _tf(TextEditingController c, {String? hint, TextInputType? type}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      style: TextStyle(
        fontFamily: 'Onest',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: const Color(0xFF171719),
      ),
      decoration: InputDecoration(
        hintText: hint ?? '',
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
    );
  }

  SizedBox _sp8() => const SizedBox(height: 10);
  SizedBox _sp12() => const SizedBox(height: 12);

  Widget _sheetHandle() => Container(
    width: double.infinity,
    alignment: Alignment.center,
    child: Container(
      width: 44, height: 5,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.black12, borderRadius: BorderRadius.circular(999),
      ),
    ),
  );

  void _showMsg(String? message) {
    if (!mounted) return;
    // ignore: unawaited_futures
    AppMessage.show(context, message ?? 'Something went wrong');
  }
}

// ---------- small chip widget for selected amenities ----------
class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.text, required this.onRemove});
  final String text;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: AppColors.accentColor,
    );
  }
}

 */

/*class ManageServiceDetailsScreen extends StatefulWidget {
  @override
  _ManageServiceDetailsScreenState createState() =>
      _ManageServiceDetailsScreenState();
}

class _ManageServiceDetailsScreenState extends State<ManageServiceDetailsScreen> {
  String? businessCoverImagePath; // To hold the selected cover image path
  String businessName = '';
  String servicePrice = '';
  String description = '';
  String location = '';
  String amenities = '';

  final businessNameController = TextEditingController();
  final servicePriceController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final amenitiesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: Text("Manage Service Details"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Cover Image Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: businessCoverImagePath == null
                      ? Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey,
                    ),
                  )
                      : Image.file(
                    File(businessCoverImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Business Name Field
              _buildCustomTextField(
                controller: businessNameController,
                label: "Business Name",
              ),
              SizedBox(height: 10),

              // Service Price Field
              _buildCustomTextField(
                controller: servicePriceController,
                label: "Service Price",
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),

              // Description Field
              _buildCustomTextField(
                controller: descriptionController,
                label: "Description",
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 10),

              // Location Field
              _buildCustomTextField(
                controller: locationController,
                label: "Location",
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 10),

              // Amenities Field
              _buildCustomTextField(
                controller: amenitiesController,
                label: "Amenities",
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateServiceDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Update', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pick Image from Gallery or Camera
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery, // or ImageSource.camera to pick from the camera
    );

    if (pickedFile != null) {
      setState(() {
        businessCoverImagePath = pickedFile.path;
      });
    }
  }

  // Update Service Details Method
  Future<void> _updateServiceDetails() async {
    if (businessCoverImagePath != null) {
      // First, upload the image
      final resp = await context.read<AuthProvider>().upload(
        businessCoverImagePath!,
        'business_cover', // You can specify the folder where it should go
      );

      if (resp == null || !resp.success || resp.path.trim().isEmpty) {
        _showMsg(context.read<AuthProvider>().message ?? 'Image upload failed');
        return;
      }

      // Now send the form data to your service update API
      await _uploadServiceDetails(resp.path);
    } else {
      // Proceed with service update even without a business image
      await _uploadServiceDetails('');
    }
  }

  // Method to upload service details (image path, etc.)
  Future<void> _uploadServiceDetails(String imagePath) async {
    final request = ServiceDetailsRequest(
      businessName: businessNameController.text,
      servicePrice: servicePriceController.text,
      description: descriptionController.text,
      location: locationController.text,
      amenities: amenitiesController.text,
      imagePath: imagePath,
    );
    // Call the API to save service details
  }

  // Helper function to show messages
  void _showMsg(String message) {
    // ignore: unawaited_futures
    AppMessage.show(context, message);
  }

  // Custom TextField Widget
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'OnestMedium',
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
              borderSide: const BorderSide(color: AppColors.pinkColor, width: 2),
            ),
          ),
          validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter your $label' : null,
        ),
      ],
    );
  }
}

// The request model for service details
class ServiceDetailsRequest {
  final String businessName;
  final String servicePrice;
  final String description;
  final String location;
  final String amenities;
  final String imagePath;

  ServiceDetailsRequest({
    required this.businessName,
    required this.servicePrice,
    required this.description,
    required this.location,
    required this.amenities,
    required this.imagePath,
  });
}*/
