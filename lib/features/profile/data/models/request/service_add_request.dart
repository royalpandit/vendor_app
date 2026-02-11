class ServiceAddRequest {
  final int vendorId;
  final int subCategoryId;
  final String name;
  final String description;
  final num basePrice;
  final String priceType; // e.g. "day"
  final String location;
  final String city;
  final String state;
  final int status; // 1/0
  final int verify; // 0/1
  final String latitude;
  final String longitude;
  final String image; // server path like "uploads/services/wedding_photo_1.jpg"

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
    required this.image,
  });

  Map<String, dynamic> toJson() => {
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
    "image": image,
  };
}
