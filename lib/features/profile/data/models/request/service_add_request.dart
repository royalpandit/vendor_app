class ServiceAddRequest {
  final int vendorId;
  final int subCategoryId;
  final String name;
  final String description;
  final num basePrice;
  final String priceType;
  final String location;
  final String city;
  final String state;

  final bool status;
  final bool verify;

  final String latitude;
  final String longitude;

  final String profileImage;
  final List<String> galleryImages;

  final String ownerName;
  final int experienceYears;

  final String contactNumber;
  final String whatsappNumber;
  final String email;
  final String serviceAreas;
  final String gstNumber;

  final Map<String, dynamic>? meta;

  ServiceAddRequest({
    required this.vendorId,
    required this.subCategoryId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.priceType,
    required this.location,
    required this.city,
    required this.state,
    required this.status,
    required this.verify,
    required this.latitude,
    required this.longitude,
    required this.profileImage,
    required this.galleryImages,
    required this.ownerName,
    required this.experienceYears,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.email,
    required this.serviceAreas,
    required this.gstNumber,
    this.meta,
  });

  Map<String, dynamic> toJson() {
    return {
      "vendor_id": vendorId,
      "sub_category_id": subCategoryId,
      "name": name,
      "description": description,
      "base_price": basePrice,
      "price_type": priceType,
      "location": location,
      "city": city,
      "state": state,
      "status": status,
      "verify": verify,
      "latitude": latitude,
      "longitude": longitude,
      "profile_image": profileImage,
      "gallery_images": galleryImages,
      "owner_name": ownerName,
      "experience_years": experienceYears,
      "contact_number": contactNumber,
      "whatsapp_number": whatsappNumber,
      "email": email,
      "service_areas": serviceAreas,
      "gst_number": gstNumber,
      if (meta != null) "meta": meta,
    };
  }
}