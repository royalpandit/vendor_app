// lib/services/address_service.dart
import 'package:geocoding/geocoding.dart';

class AddressService {
  /// lat/lng se Placemark list laata hai. Usually index 0 sabse relevant hota hai.
  static Future<Placemark?> placemarkFromLatLng({
    required double lat,
    required double lng,
  }) async {
    final places = await placemarkFromCoordinates(lat, lng);
    if (places.isEmpty) return null;
    return places.first;
  }

  /// Placemark ko readable single-line address me convert karta hai.
  static String formatPlacemark(Placemark p) {
    final parts = <String>[
      p.name.toString(),
      p.street.toString(),
      p.subLocality.toString(),
      p.locality.toString(),              // city
      p.administrativeArea.toString(),    // state
      p.postalCode.toString(),            // pincode
      p.country.toString(),
    ].where((e) => (e != null && e.trim().isNotEmpty)).toList();

    return parts.join(', ');
  }

  /// Direct helper: lat/lng -> address (String)
  static Future<String?> addressFromLatLng({
    required double lat,
    required double lng,
  }) async {
    final pm = await placemarkFromLatLng(lat: lat, lng: lng);
    if (pm == null) return null;
    return formatPlacemark(pm);
  }

  static Future<AddressParts?> addressPartsFromLatLng({
    required double lat,
    required double lng,
  }) async {
    final pm = await placemarkFromLatLng(lat: lat, lng: lng);
    if (pm == null) return null;
    return AddressParts(
      name: pm.name,
      street: pm.street,
      subLocality: pm.subLocality,
      locality: pm.locality,                      // city
      administrativeArea: pm.administrativeArea,  // state
      postalCode: pm.postalCode,
      country: pm.country,
      formatted: formatPlacemark(pm),
    );
  }
}

class AddressParts {
  final String? name;
  final String? street;
  final String? subLocality;
  final String? locality;            // city
  final String? administrativeArea;  // state
  final String? postalCode;
  final String? country;
  final String formatted;            // single-line

  AddressParts({
    this.name,
    this.street,
    this.subLocality,
    this.locality,
    this.administrativeArea,
    this.postalCode,
    this.country,
    required this.formatted,
  });
}