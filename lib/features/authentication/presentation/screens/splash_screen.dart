import 'package:flutter/material.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/router/route_paths.dart';
import 'package:vendor_app/core/session/session.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/features/authentication/presentation/screens/basic_info_screen.dart';
import 'package:vendor_app/features/authentication/presentation/screens/phone_number_verified_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // NEW


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // UPDATED: पहले सीधे _checkUserLoginStatus() था
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runStartupFlow(); // NEW
    });
  }

  // ------------------ STARTUP FLOW (NEW) ------------------
  Future<void> _runStartupFlow() async {
    // 1) Ensure location permission
    final granted = await _ensureLocationPermission();
    if (!mounted) return;

    if (!granted) {
      // परमिशन नहीं मिली—blocking dialog के साथ दो विकल्प
      await _showBlockingDialog(
        title: 'Location Required',
        message:
        'Nearby services दिखाने के लिए लोकेशन जरूरी है। कृपया परमिशन Allow करें।',
        positive: 'Try Again',
        onPositive: () async {
          Navigator.of(context).pop();
          await _runStartupFlow();
        },
        negative: 'App Settings',
        onNegative: () async {
          await Geolocator.openAppSettings();
          if (!mounted) return;
          Navigator.of(context).pop();
          await _runStartupFlow();
        },
      );
      return;
    }

    // 2) Try to fetch current position (optional)
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // आप चाहें तो यहाँ pos को किसी shared singleton/Service में स्टोर कर लें
      // e.g., LocationCache.lastPosition = pos;
      debugPrint('📍 Vendor pos: ${pos.latitude}, ${pos.longitude}');
    } catch (e) {
      // ignore/log
      debugPrint('⚠️ getCurrentPosition error: $e');
    }

    // 3) Small delay for smoothness
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // 4) Decide next route based on login status
    await _checkUserLoginStatus(); // वही मेथड, बस Session.token sync जोड़ दिया है
  }

  // ------------------ LOGIN CHECK (slightly UPDATED) ------------------

  Future<void> _checkUserLoginStatus() async {
    // Fetch token and user data
    final token = await TokenStorage.getToken();
    final userData = await TokenStorage.getUserData();

    // Keep memory Session.token in sync (useful for interceptors)
    if (token != null && token.isNotEmpty) {
      Session.token = token; // NEW
    }

    if (token != null && token.isNotEmpty && userData != null) {
      // Navigate to home screen if token and user data are available
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        RoutePaths.home,
        arguments: 0,
      );
    } else {
      // Navigate to phone verification screen if no token or user data is found
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RoutePaths.phoneVerify);
    }
  }

  // ------------------ PERMISSION HELPERS (NEW) ------------------
  Future<bool> _ensureLocationPermission() async {
    // Ensure services ON
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showInfoDialog(
        'Turn On Location',
        'Location services are disabled. कृपया enable करें।',
        actionText: 'Open Settings',
        onAction: Geolocator.openLocationSettings,
      );
      if (!await Geolocator.isLocationServiceEnabled()) return false;
    }

    // Check permission state
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showInfoDialog(
        'Permission Permanently Denied',
        'Settings में जाकर इस ऐप के लिए location access Allow करें।',
        actionText: 'Open App Settings',
        onAction: Geolocator.openAppSettings,
      );
      return false;
    }

    // whileInUse / always
    return true;
  }

  Future<void> _showInfoDialog(
      String title,
      String message, {
        String actionText = 'OK',
        Future<void> Function()? onAction,
      }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              if (onAction != null) await onAction();
              if (mounted) Navigator.of(context).pop();
            },
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  Future<void> _showBlockingDialog({
    required String title,
    required String message,
    required String positive,
    required VoidCallback onPositive,
    required String negative,
    required VoidCallback onNegative,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: onNegative, child: Text(negative)),
          FilledButton(onPressed: onPositive, child: Text(positive)),
        ],
      ),
    );
  }
  // ------------------ /PERMISSION HELPERS ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Makes the image fill the screen
        children: [
          // Background image
          Image.asset(
            AppIcons.splashBg, // Add your background image path here
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
          // Positioned text
          Center(
            child: Container(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 4,
                children: [
                  SizedBox(
                    width: 300,
                    child: Text(
                      'SevenOath',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: Text(
                      'Vendor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF444242),
                        fontSize: 18,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


