import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  static Future<Position?> requestAndGetLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // check if location is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showDialog(context, 'Please enable location services.');
      Geolocator.openLocationSettings();
      return null;
    }

    // check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await _showDialog(context, 'Location permission is required to use this app.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showDialog(context, 'Location permission permanently denied. Please enable it from settings.');
      Geolocator.openAppSettings();
      return null;
    }

    // all good → get current location
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  static Future<void> _showDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
