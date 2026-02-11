// lib/core/di/di.dart
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_api.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_repository.dart';

// core
import '../network/dio_client.dart';



List<SingleChildWidget> buildAppProviders() {
  return [
    // 1) Core: Dio (single instance)
    Provider<Dio>(
      create: (_) => buildDio(),
    ),

    // 2) APIs (depend on Dio)
    ProxyProvider<Dio, AuthApi>(
      update: (_, dio, __) => AuthApi(dio),
    ),

    // 3) Repositories (depend on APIs)
    ProxyProvider<AuthApi, AuthRepository>(
      update: (_, api, __) => AuthRepository(api),
    ),

    // 4) UI Providers (depend on Repositories)
    ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
      // NOTE: ctx.read<T>() से dependency pickup करो
      create: (ctx) => AuthProvider(ctx.read<AuthRepository>()),
      update: (ctx, repo, previous) {
        if (previous == null) return AuthProvider(repo);
        previous.updateRepo(repo);   // <- your AuthProvider should have this method
        return previous;             // <- NON-NULL return
      },
    ),
  ];
}
