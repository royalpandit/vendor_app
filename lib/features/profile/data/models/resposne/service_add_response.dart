// service_add_response.dart


class ServiceAddResponse {
  final int id;
  final String name;
  final String description;
  final num basePrice;
  final String priceType;
  final String location;
  final bool status;
  final int verify;
  final String vendorName;
  final String subCategoryName;
  final String latitude;
  final String longitude;
  final String city;
  final String state;
  final ServiceAddImage? image;

  ServiceAddResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.priceType,
    required this.location,
    required this.status,
    required this.verify,
    required this.vendorName,
    required this.subCategoryName,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    required this.image,
  });

  factory ServiceAddResponse.fromJson(Map<String, dynamic> json) {
    return ServiceAddResponse(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      basePrice: json["base_price"] ?? 0,
      priceType: json["price_type"] ?? "",
      location: json["location"] ?? "",
      status: json["status"] == true || json["status"] == 1,
      verify: json["verify"] ?? 0,
      vendorName: json["vendor_name"] ?? "",
      subCategoryName: json["sub_category_name"] ?? "",
      latitude: json["latitude"]?.toString() ?? "",
      longitude: json["longitude"]?.toString() ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      image: json["image"] == null ? null : ServiceAddImage.fromJson(json["image"]),
    );
  }
}

class ServiceAddImage {
  final int id;
  final String url;
  final bool isPrimary;
  final int position;

  ServiceAddImage({
    required this.id,
    required this.url,
    required this.isPrimary,
    required this.position,
  });

  factory ServiceAddImage.fromJson(Map<String, dynamic> json) {
    return ServiceAddImage(
      id: json["id"] ?? 0,
      url: json["url"] ?? "",
      isPrimary: json["is_primary"] == true || json["is_primary"] == 1,
      position: json["position"] ?? 0,
    );
  }
}
