import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/di/di.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/router/app_router.dart';
import 'package:vendor_app/core/router/route_paths.dart';
import 'package:vendor_app/core/session/session.dart';

void mains() {
  WidgetsFlutterBinding.ensureInitialized(); // <-- बहुत ज़रूरी

  runApp(
    MultiProvider(
      providers: buildAppProviders(), // Dio → APIs → Repos → Providers
      child: const MyApp(),
    ),
  );
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) prefs से token एक बार पढ़कर memory में रख लो
  Session.token = await TokenStorage.getToken();

  // 2) अब app boot करो (Dio interceptor memory token से header जोड़ेगा)
  runApp(
    MultiProvider(
      providers: buildAppProviders(), // Dio → APIs → Repos → Providers
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Titlyaan',
      debugShowCheckedModeBanner: false,

      // Modern Material 3 theme (better than primarySwatch)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
      ),

      navigatorKey: AppRouter.navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: RoutePaths.splash,

    );
  }
}
