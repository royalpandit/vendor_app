// venue_create_models.dart

class VenueAmenityReq {
  final int amenityId;
  final String value;

  VenueAmenityReq({required this.amenityId, required this.value});

  Map<String, dynamic> toJson() => {
    "amenity_id": amenityId,
    "value": value,
  };
}

class VenueDetailsReq {
  final int minBooking;
  final int maxCapacity;
  final num basePrice;
  final num extraGuestPrice;

  VenueDetailsReq({
    required this.minBooking,
    required this.maxCapacity,
    required this.basePrice,
    required this.extraGuestPrice,
  });

  Map<String, dynamic> toJson() => {
    "min_booking": minBooking,
    "max_capacity": maxCapacity,
    "base_price": basePrice,
    "extra_guest_price": extraGuestPrice,
  };
}

class VenueCreateRequest {
  final int vendorId;
  final int subCategoryId;
  final String name;
  final String description;
  final String image; // main image path (uploaded via master-image)
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String latitude;
  final String longitude;
  final VenueDetailsReq details;
  final List<VenueAmenityReq> amenities;

  VenueCreateRequest({
    required this.vendorId,
    required this.subCategoryId,
    required this.name,
    required this.description,
    required this.image,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.details,
    required this.amenities,
  });

  Map<String, dynamic> toJson() => {
    "vendor_id": vendorId,
    "sub_category_id": subCategoryId,
    "name": name,
    "description": description,
    "image": image,
    "address": address,
    "city": city,
    "state": state,
    "pincode": pincode,
    "latitude": latitude,
    "longitude": longitude,
    "details": details.toJson(),
    "amenities": amenities.map((e) => e.toJson()).toList(),
  };
}

// Response सिर्फ message देता है (sample के हिसाब से)
class VenueCreateResponse {
  final String? status;
  final int? code;
  final String? message;

  VenueCreateResponse({this.status, this.code, this.message});

  factory VenueCreateResponse.fromJson(Map<String, dynamic> json) {
    return VenueCreateResponse(
      status: json["status"],
      code: json["code"],
      message: json["message"],
    );
  }
}
