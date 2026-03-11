class ServiceDetailsResponse {
  final int id;
  final int vendorId;
  final int subCategoryId;
  final String name;
  final String? description;
  final double basePrice;
  final String priceType;
  final String location;
  final bool status;
  final int verify;
  final String? latitude;
  final String? longitude;
  final String? city;
  final String? state;
  final String type;
  final List<ServiceImage> images;
  final VendorInfo? vendor;
  final SubcategoryInfo? subcategory;
  final Map<String, dynamic>? meta;

  // Venue-specific fields
  final int? serviceId;
  final String? address;
  final String? pincode;
  final int? minBooking;
  final int? maxCapacity;
  final double? extraGuestPrice;
  final List<AmenityInfo> amenities;
  final String? primaryImageUrl;

  ServiceDetailsResponse({
    required this.id,
    required this.vendorId,
    required this.subCategoryId,
    required this.name,
    this.description,
    required this.basePrice,
    required this.priceType,
    required this.location,
    required this.status,
    required this.verify,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    required this.type,
    required this.images,
    this.vendor,
    this.subcategory,
    this.meta,
    this.serviceId,
    this.address,
    this.pincode,
    this.minBooking,
    this.maxCapacity,
    this.extraGuestPrice,
    this.amenities = const [],
    this.primaryImageUrl,
  });

  factory ServiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    // Handle both single service and nested response formats
    var data = json['service'] ?? json['venue'] ?? json;
    
    // If data has a 'details' object (for venues), merge it with the main data
    if (data is Map<String, dynamic> && data['details'] != null && data['details'] is Map) {
      final details = data['details'] as Map<String, dynamic>;
      // Create a merged map with details fields taking precedence
      data = {
        ...data,
        ...details,
        'details': details, // Keep original details ref if needed
      };
    }
    
    return ServiceDetailsResponse(
      id: _safeInt(data['id']),
      vendorId: _safeInt(data['vendor_id']),
      subCategoryId: _safeInt(data['sub_category_id']),
      name: _safeString(data['name']),
      description: _safeStringNullable(data['description']),
      basePrice: _safeDouble(data['base_price']),
      priceType: _safeString(data['price_type']),
      location: _safeString(data['location'] ?? data['address'] ?? ''),
      status: _safeBool(data['status']),
      verify: _safeInt(data['verify']),
      latitude: _safeStringNullable(data['latitude']),
      longitude: _safeStringNullable(data['longitude']),
      city: _safeStringNullable(data['city']),
      state: _safeStringNullable(data['state']),
      type: _safeString(data['type'] ?? 'service'),
      images: _safeImageList(data['images'] ?? data['portfolio_images']),
      vendor: data['vendor'] != null ? VendorInfo.fromJson(data['vendor']) : null,
      subcategory: data['subcategory'] != null
          ? SubcategoryInfo.fromJson(data['subcategory'])
          : null,
      meta: _safeCastMeta(data['meta']),
      serviceId: data['service_id'] != null ? _safeInt(data['service_id']) : null,
      address: _safeStringNullable(data['address']),
      pincode: _safeStringNullable(data['pincode']),
      minBooking: data['min_booking'] != null ? _safeInt(data['min_booking']) : null,
      maxCapacity: data['max_capacity'] != null ? _safeInt(data['max_capacity']) : null,
      extraGuestPrice: data['extra_guest_price'] != null ? _safeDouble(data['extra_guest_price']) : null,
      amenities: _safeAmenityList(data['amenities']),
      primaryImageUrl: _safeStringNullable(data['primary_image_url']),
    );
  }

  // Safe type conversion helpers
  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String? _safeStringNullable(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) return null;
    if (value is String) return value;
    return value.toString();
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static List<ServiceImage> _safeImageList(dynamic images) {
    if (images == null) return [];
    if (images is! List) return [];
    try {
      return images
          .map((e) => e is Map<String, dynamic> ? ServiceImage.fromJson(e) : null)
          .whereType<ServiceImage>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<AmenityInfo> _safeAmenityList(dynamic amenities) {
    if (amenities == null) return [];
    if (amenities is! List) return [];
    try {
      return amenities
          .map((e) => e is Map<String, dynamic> ? AmenityInfo.fromJson(e) : null)
          .whereType<AmenityInfo>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  bool get isVenue => type.toLowerCase() == 'venue' || serviceId != null;
}

class ServiceImage {
  final int id;
  final int serviceId;
  final String imagePath;
  final bool isPrimary;
  final int position;
  final String imageUrl;

  ServiceImage({
    required this.id,
    required this.serviceId,
    required this.imagePath,
    required this.isPrimary,
    required this.position,
    required this.imageUrl,
  });

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    String getFullImageUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('http')) return url;
      // Convert relative path to full URL
      return 'https://sevenoath.shofus.com/storage/$url';
    }

    return ServiceImage(
      id: ServiceDetailsResponse._safeInt(json['id']),
      serviceId: ServiceDetailsResponse._safeInt(json['service_id'] ?? json['venue_id']),
      imagePath: ServiceDetailsResponse._safeString(json['image_path']),
      isPrimary: ServiceDetailsResponse._safeBool(json['is_primary']),
      position: ServiceDetailsResponse._safeInt(json['position']),
      imageUrl: getFullImageUrl(
        ServiceDetailsResponse._safeStringNullable(
          json['image_url'] ?? json['image_path'],
        ),
      ),
    );
  }
}

class VendorInfo {
  final int id;
  final String name;

  VendorInfo({
    required this.id,
    required this.name,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      id: ServiceDetailsResponse._safeInt(json['id']),
      name: ServiceDetailsResponse._safeString(json['name']),
    );
  }
}

class SubcategoryInfo {
  final int id;
  final String name;

  SubcategoryInfo({
    required this.id,
    required this.name,
  });

  factory SubcategoryInfo.fromJson(Map<String, dynamic> json) {
    return SubcategoryInfo(
      id: ServiceDetailsResponse._safeInt(json['id']),
      name: ServiceDetailsResponse._safeString(json['name']),
    );
  }
}

class AmenityInfo {
  final int id;
  final String name;

  AmenityInfo({required this.id, required this.name});

  factory AmenityInfo.fromJson(Map<String, dynamic> json) {
    // Handle both direct amenity and pivot-style (API sends 'value' for venue amenities)
    return AmenityInfo(
      id: ServiceDetailsResponse._safeInt(json['amenity_id'] ?? json['id']),
      name: ServiceDetailsResponse._safeString(json['value'] ?? json['name'] ?? ''),
    );
  }
}

// Helper function to safely cast meta field to Map<String, dynamic>
Map<String, dynamic>? _safeCastMeta(dynamic meta) {
  if (meta == null) return null;
  
  if (meta is Map<String, dynamic>) {
    return meta;
  }
  
  if (meta is Map) {
    try {
      final result = <String, dynamic>{};
      meta.forEach((key, value) {
        if (key is String) {
          result[key] = value;
        }
      });
      return result.isEmpty ? null : result;
    } catch (e) {
      return null;
    }
  }
  
  return null;
}
