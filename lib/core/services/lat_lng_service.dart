import 'package:flutter/material.dart';
import 'location_service.dart';

class LatLngService {
  static Future<Map<String, double>?> getLatLng(BuildContext context) async {
    final pos = await LocationService.requestAndGetLocation(context);
    if (pos == null) return null;

    return {
      'lat': pos.latitude,
      'lng': pos.longitude,
    };
  }
}
