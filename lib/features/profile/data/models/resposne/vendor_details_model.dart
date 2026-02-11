// ================================
// FILE: lib/features/vendor/data/vendor_details_model.dart
// ================================
/// ─────────────────────────────────────────────────────────
/// NEW: Category wrapper to support multiple incoming shapes
class VendorCategory {
  final int? id;       // maps from "category_id" or bare int
  final String? name;  // maps from "name" or bare string

  const VendorCategory({this.id, this.name});

  factory VendorCategory.fromJson(dynamic raw) {
    if (raw == null) return const VendorCategory();

    // If API ever sent just an int
    if (raw is int) return VendorCategory(id: raw);

    // If API ever sent just a string
    if (raw is String) return VendorCategory(name: raw.trim().isEmpty ? null : raw.trim());

    // Normal case (new): { "category_id": 1, "name": "venue" }
    if (raw is Map<String, dynamic>) {
      int? asInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        if (v is String) return int.tryParse(v);
        return null;
      }

      String? asStr(dynamic v) => v == null ? null : v.toString();

      return VendorCategory(
        id: asInt(raw['category_id'] ?? raw['id']),
        name: asStr(raw['name']),
      );
    }

    // Fallback
    return const VendorCategory();
  }

  Map<String, dynamic> toJson() => {
    'category_id': id,
    'name': name,
  }..removeWhere((_, v) => v == null);
}

/// ─────────────────────────────────────────────────────────
/// UPDATED: VendorDetails model
class VendorDetails {
  final String? name;
  final String? phone;
  final String? email;

  final String? adharNumber;
  final String? businessName;

  /// UPDATED: now an object; still parses legacy string/int forms.
  final VendorCategory? businessCategory;

  /// Can be int or string from API; normalized to int?
  final int? experienceInBusiness;

  final String? priceRange;

  /// Server sends comma-separated string; keep raw and offer a helper list getter
  final String? serviceCoverage;

  final String? businessAddress;
  final String? businessDescription;
  final String? benefits;

  final String? businessPhoto;
  final String? adharPhoto;
  final String? certificatePhoto;

  /// Can come as bool/int/string; normalized to bool?
  final bool? status;

  /// API gives as strings; keep raw but expose parsed doubles via getters
  final String? latitude;
  final String? longitude;

  const VendorDetails({
    this.name,
    this.phone,
    this.email,
    this.adharNumber,
    this.businessName,
    this.businessCategory,
    this.experienceInBusiness,
    this.priceRange,
    this.serviceCoverage,
    this.businessAddress,
    this.businessDescription,
    this.benefits,
    this.businessPhoto,
    this.adharPhoto,
    this.certificatePhoto,
    this.status,
    this.latitude,
    this.longitude,
  });

  factory VendorDetails.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    bool? _toBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) {
        final s = v.toLowerCase().trim();
        if (s == 'true' || s == '1' || s == 'yes') return true;
        if (s == 'false' || s == '0' || s == 'no') return false;
      }
      return null;
    }

    return VendorDetails(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      adharNumber: json['adhar_number']?.toString(),
      businessName: json['business_name']?.toString(),

      // 👇 Accepts: map (new), string (old), or int (rare)
      businessCategory: VendorCategory.fromJson(json['business_category']),

      experienceInBusiness: _toInt(json['experience_in_business']),
      priceRange: json['price_range']?.toString(),
      serviceCoverage: json['service_coverage']?.toString(),
      businessAddress: json['business_address']?.toString(),
      businessDescription: json['business_description']?.toString(),
      benefits: json['benefits']?.toString(),
      businessPhoto: json['business_photo']?.toString(),
      adharPhoto: json['adhar_photo']?.toString(),
      certificatePhoto: json['certificate_photo']?.toString(),
      status: _toBool(json['status']),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'adhar_number': adharNumber,
    'business_name': businessName,

    // 👇 Send object back as {category_id, name}
    'business_category': businessCategory?.toJson(),

    'experience_in_business': experienceInBusiness,
    'price_range': priceRange,
    'service_coverage': serviceCoverage,
    'business_address': businessAddress,
    'business_description': businessDescription,
    'benefits': benefits,
    'business_photo': businessPhoto,
    'adhar_photo': adharPhoto,
    'certificate_photo': certificatePhoto,
    'status': status,
    'latitude': latitude,
    'longitude': longitude,
  }..removeWhere((_, v) => v == null);

  /// Helper: split service coverage into a string list.
  List<String> get serviceCoverageList => (serviceCoverage ?? '')
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  double? get lat => double.tryParse(latitude ?? '');
  double? get lng => double.tryParse(longitude ?? '');

  /// Convenience getters for category
  int? get categoryId => businessCategory?.id;
  String? get categoryName => businessCategory?.name;
}

/*
class VendorDetails {
  final String? name;
  final String? phone;
  final String? email;

  final String? adharNumber;
  final String? businessName;
  final String? businessCategory;

  /// Can be int or string from API; normalized to int?
  final int? experienceInBusiness;

  final String? priceRange;

  /// Server sends comma-separated string; keep raw and offer a helper list getter
  final String? serviceCoverage;

  final String? businessAddress;
  final String? businessDescription;
  final String? benefits;

  final String? businessPhoto;
  final String? adharPhoto;
  final String? certificatePhoto;

  /// Can come as bool/int/string; normalized to bool?
  final bool? status;

  /// API gives as strings; keep raw but expose parsed doubles via getters
  final String? latitude;
  final String? longitude;

  const VendorDetails({
    this.name,
    this.phone,
    this.email,
    this.adharNumber,
    this.businessName,
    this.businessCategory,
    this.experienceInBusiness,
    this.priceRange,
    this.serviceCoverage,
    this.businessAddress,
    this.businessDescription,
    this.benefits,
    this.businessPhoto,
    this.adharPhoto,
    this.certificatePhoto,
    this.status,
    this.latitude,
    this.longitude,
  });

  factory VendorDetails.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    bool? _toBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) {
        final s = v.toLowerCase();
        if (s == 'true' || s == '1' || s == 'yes') return true;
        if (s == 'false' || s == '0' || s == 'no') return false;
      }
      return null;
    }

    return VendorDetails(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      adharNumber: json['adhar_number']?.toString(),
      businessName: json['business_name']?.toString(),
      businessCategory: json['business_category']?.toString(),
      experienceInBusiness: _toInt(json['experience_in_business']),
      priceRange: json['price_range']?.toString(),
      serviceCoverage: json['service_coverage']?.toString(),
      businessAddress: json['business_address']?.toString(),
      businessDescription: json['business_description']?.toString(),
      benefits: json['benefits']?.toString(),
      businessPhoto: json['business_photo']?.toString(),
      adharPhoto: json['adhar_photo']?.toString(),
      certificatePhoto: json['certificate_photo']?.toString(),
      status: _toBool(json['status']),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'adhar_number': adharNumber,
    'business_name': businessName,
    'business_category': businessCategory,
    'experience_in_business': experienceInBusiness,
    'price_range': priceRange,
    'service_coverage': serviceCoverage,
    'business_address': businessAddress,
    'business_description': businessDescription,
    'benefits': benefits,
    'business_photo': businessPhoto,
    'adhar_photo': adharPhoto,
    'certificate_photo': certificatePhoto,
    'status': status,
    'latitude': latitude,
    'longitude': longitude,
  };

  /// Helper: split service coverage into a string list.
  List<String> get serviceCoverageList =>
      (serviceCoverage ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);

  double? get lat => double.tryParse(latitude ?? '');
  double? get lng => double.tryParse(longitude ?? '');
}
*/


