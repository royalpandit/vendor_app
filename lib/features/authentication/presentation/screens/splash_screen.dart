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
    // Check location permission but don't block on high-accuracy location
    // Location will be captured in background
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

    // Capture location in background - don't wait for high accuracy
    _captureLocationInBackground();

    // Minimal delay for splash screen visibility
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    await _checkUserLoginStatus();
  }

  // Capture location in background without blocking
  void _captureLocationInBackground() {
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium, // Faster than high
      timeLimit: const Duration(seconds: 5), // Don't wait forever
    ).catchError((e) {
      // Ignore location errors - not critical for app flow
    });
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
      
      // Load essential dashboard data first (most critical for home screen)
      await authProvider.fetchVendorDashboard(userId);
      
      // Load other data in background without blocking
      // This allows the home screen to show immediately while data loads
      _preloadSecondaryDataInBackground(authProvider, userId);
    } catch (e) {
      // Error preloading dashboard data - continue anyway
      // Screens will load data if needed
    }
  }

  // Preload secondary data without blocking navigation
  void _preloadSecondaryDataInBackground(AuthProvider authProvider, int userId) {
    // Run in background - don't await
    Future.microtask(() async {
      try {
        // Load less critical data after a small delay
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        
        // Load in sequence with small delays to avoid network congestion
        await authProvider.fetchVendorDetails(userId);
        await Future.delayed(const Duration(milliseconds: 100));
        
        await authProvider.fetchActiveBookings(userId);
        await Future.delayed(const Duration(milliseconds: 100));
        
        await authProvider.fetchBookingLeads(userId);
        await Future.delayed(const Duration(milliseconds: 100));
        
        await authProvider.fetchInboxMessages(userId);
        await authProvider.fetchNotificationSettings(userId);
      } catch (e) {
        // Silently fail - not critical for app operation
      }
    });
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
                  // Logo image (bigger size)
                  Image.asset(
                    'assets/images/logo.png',
                    width: (screenWidth * 0.4).clamp(120, 200),
                    height: (screenWidth * 0.4).clamp(120, 200),
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 48),
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