// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:vendor_app/features/authentication/presentation/screens/basic_info_screen.dart';
import 'package:vendor_app/features/authentication/presentation/screens/phone_number_verified_screen.dart';
import 'package:vendor_app/features/authentication/presentation/screens/splash_screen.dart';
import 'package:vendor_app/features/home/presentation/screens/home_screen.dart';
import 'route_paths.dart';


class AppRouter {
  AppRouter._();
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> pushNamed<T>(String route, {Object? args}) =>
      navigatorKey.currentState!.pushNamed<T>(route, arguments: args);

  static Future<T?> replaceNamed<T>(String route, {Object? args}) =>
      navigatorKey.currentState!.pushReplacementNamed<T, T>(route, arguments: args);

  static Future<T?> offAllNamed<T>(String route, {Object? args}) =>
      navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(route, (r) => false, arguments: args);

  static Route _material(Widget page, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => page, settings: settings);

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.splash:
        return _material(SplashScreen(), settings);
        case RoutePaths.phoneVerify:
        return _material(PhoneNumberVerifiedScreen(), settings);
      case RoutePaths.basicInfo:
      // 👇 yaha argument (phone) nikaalo
        final phone = settings.arguments as String? ?? '';
        return _material(BasicInfoScreen(phone: phone), settings); // 👈 pass to ctor
/*
      case RoutePaths.basicInfo:
        return _material(const BasicInfoScreen(), settings);*/
      case RoutePaths.home:
        final idx = (settings.arguments as int?) ?? 0;
        return _material(HomeScreen(currentIndex: idx), settings);
      default:
        return _material(
          Scaffold(
            appBar: AppBar(title: const Text('Not found')),
            body: Center(child: Text('No route: ${settings.name}')),
          ),
          settings,
        );
    }
  }
}

