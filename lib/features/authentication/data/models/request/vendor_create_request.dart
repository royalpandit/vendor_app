 class VendorCreateRequest {
  final String name;
  final String phone;
  final String email;
  final String adharNumber;
  final String businessName;
  //final String businessCategory;
  final int businessCategory; // <-- was String, now int

  final int experienceInBusiness;
  final String priceRange;
  final String serviceCoverage;
  final String businessAddress;
  final String businessDescription;
  final String benefits;
  final String businessPhoto;    // already uploaded path (from master-image-upload)
  final String adharPhoto;       // already uploaded path
  final String certificatePhoto; // already uploaded path
  final bool status;
  final String latitude;   // API expects string per sample
  final String longitude;  // API expects string per sample

  VendorCreateRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.adharNumber,
    required this.businessName,
    required this.businessCategory,
    required this.experienceInBusiness,
    required this.priceRange,
    required this.serviceCoverage,
    required this.businessAddress,
    required this.businessDescription,
    required this.benefits,
    required this.businessPhoto,
    required this.adharPhoto,
    required this.certificatePhoto,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  factory VendorCreateRequest.fromJson(Map<String, dynamic> json) {
    int _asInt(dynamic v, {int or = 0}) =>
        v is int ? v : int.tryParse('$v') ?? or;
    return VendorCreateRequest(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      adharNumber: json['adhar_number']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? '',
     // businessCategory: json['business_category']?.toString() ?? '',
      businessCategory: _asInt(json['business_category']),

      experienceInBusiness: (json['experience_in_business'] as num?)?.toInt() ?? 0,
      priceRange: json['price_range']?.toString() ?? '',
      serviceCoverage: json['service_coverage']?.toString() ?? '',
      businessAddress: json['business_address']?.toString() ?? '',
      businessDescription: json['business_description']?.toString() ?? '',
      benefits: json['benefits']?.toString() ?? '',
      businessPhoto: json['business_photo']?.toString() ?? '',
      adharPhoto: json['adhar_photo']?.toString() ?? '',
      certificatePhoto: json['certificate_photo']?.toString() ?? '',
      status: json['status'] == true || (json['status'] is num && (json['status'] as num) == 1),
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
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
    'status': status, // backend accepts bool (per sample)
    'latitude': latitude,
    'longitude': longitude,
  };
}
