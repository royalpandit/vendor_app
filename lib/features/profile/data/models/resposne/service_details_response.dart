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
  });

  factory ServiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsResponse(
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      subCategoryId: json['sub_category_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      basePrice: (() {
        final v = json['base_price'];
        if (v == null) return 0.0;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString()) ?? 0.0;
      })(),
      priceType: json['price_type'] ?? 'fixed',
      location: json['location'] ?? '',
      status: json['status'] ?? false,
      verify: json['verify'] ?? 0,
      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
      state: json['state'],
      type: json['type'] ?? 'service',
      images: (json['images'] as List?)
              ?.map((e) => ServiceImage.fromJson(e))
              .toList() ??
          [],
      vendor: json['vendor'] != null ? VendorInfo.fromJson(json['vendor']) : null,
      subcategory: json['subcategory'] != null
          ? SubcategoryInfo.fromJson(json['subcategory'])
          : null,
      meta: json['meta'] != null && json['meta'] is Map
          ? (json['meta'] as Map).cast<String, dynamic>()
          : null,
    );
  }
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
    return ServiceImage(
      id: json['id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      position: json['position'] ?? 0,
      imageUrl: json['image_url'] ?? '',
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
