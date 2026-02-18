import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/router/route_paths.dart';
import 'package:vendor_app/core/session/session.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/core/utils/app_theme.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runStartupFlow();
    });
  }

  // ------------------ STARTUP FLOW ------------------
  Future<void> _runStartupFlow() async {
    final granted = await _ensureLocationPermission();
    if (!mounted) return;

    if (!granted) {
      await _showBlockingDialog(
        title: 'Location Required',
        message: 'Nearby services दिखाने के लिए लोकेशन जरूरी है। कृपया परमिशन Allow करें।',
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

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // vendor position captured
    } catch (e) {
      // ignore location errors
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    await _checkUserLoginStatus();
  }

  // ------------------ LOGIN CHECK ------------------
  Future<void> _checkUserLoginStatus() async {
    final token = await TokenStorage.getToken();
    final userData = await TokenStorage.getUserData();

    if (token != null && token.isNotEmpty) {
      Session.token = token;
    }

    if (!mounted) return;

    if (token != null && token.isNotEmpty && userData != null) {
      // User is logged in - preload all data
      await _preloadUserData(userData.id ?? 0);
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        RoutePaths.home,
        arguments: 0,
      );
    } else {
      Navigator.pushReplacementNamed(context, RoutePaths.phoneVerify);
    }
  }

  // ------------------ PRELOAD DATA ------------------
  Future<void> _preloadUserData(int userId) async {
    try {
      final authProvider = context.read<AuthProvider>();
      
      // Preload all essential data in parallel
      await Future.wait([
        authProvider.fetchVendorDashboard(userId),
        authProvider.fetchVendorDetails(userId),
        authProvider.fetchActiveBookings(userId),
        authProvider.fetchBookingLeads(userId),
        authProvider.fetchInboxMessages(userId),
        authProvider.fetchNotificationSettings(userId),
      ]);
      
      // user data preloaded successfully
    } catch (e) {
      // error preloading user data
      // Continue anyway - screens will load data if needed
    }
  }

  // ------------------ PERMISSION HELPERS ------------------
  Future<bool> _ensureLocationPermission() async {
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

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
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
    return true;
  }

  Future<void> _showInfoDialog(String title, String message, {String actionText = 'OK', Future<void> Function()? onAction}) async {
    if (!mounted) return;
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

  Future<void> _showBlockingDialog({required String title, required String message, required String positive, required VoidCallback onPositive, required String negative, required VoidCallback onNegative}) async {
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            AppIcons.splashBg,
            fit: BoxFit.cover,
          ),
          // Centered Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SevenOath',
                    textAlign: TextAlign.center,
                    style: AppTheme.heading1.copyWith(
                      fontSize: (screenWidth * 0.1).clamp(32, 48),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vendor',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyLarge.copyWith(
                      fontSize: (screenWidth * 0.045).clamp(16, 20),
                      color: const Color(0xFF444242),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Loading indicator
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
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