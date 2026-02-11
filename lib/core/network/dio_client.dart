// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:vendor_app/core/config/app_config.dart';
import 'package:vendor_app/core/network/api_exceptions.dart';
import 'package:vendor_app/core/network/token_storage.dart';

// lib/core/network/dio_client.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:vendor_app/core/session/session.dart';


Dio buildDio({bool enableLogs = true}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // 200-299 को OK माने, बाकी पर Dio error throw करेगा पर response भी देगा
      validateStatus: (code) => code != null && code >= 200 && code < 300,
      // non-2xx पर भी body चाहिए
      receiveDataWhenStatusError: true,
    ),
  );

  // ---- Request Interceptor: token + logging ----

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Attach token (safe)
        try {
         // final token = await TokenStorage.getToken();
  final token = Session.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // ignore secure storage errors at request time
        }

        // Tag for logs: requestId + start time
        if (enableLogs && kDebugMode) {
          options.extra['reqId'] = _nextReqId();
          options.extra['ts'] = DateTime.now().millisecondsSinceEpoch;

          final maskedHeaders = _maskedHeaders(options.headers);
          debugPrint('➡️ [REQ #${options.extra['reqId']}] ${options.method} ${options.uri}');
          if (options.queryParameters.isNotEmpty) {
            debugPrint('   └─ query: ${options.queryParameters}');
          }
          debugPrint('   └─ headers: $maskedHeaders');
          if (options.data != null) {
            debugPrint('   └─ body: ${_preview(options.data)}');
          }
        }

        handler.next(options);
      },

      onResponse: (response, handler) {
        if (enableLogs && kDebugMode) {
          final id = response.requestOptions.extra['reqId'] ?? '-';
          final started = response.requestOptions.extra['ts'] as int?;
          final took = started == null
              ? ''
              : ' (${DateTime.now().millisecondsSinceEpoch - started} ms)';

          debugPrint('✅ [RES #$id]${took}');
          debugPrint('   └─ ${response.requestOptions.method} ${response.requestOptions.uri}');
          debugPrint('   └─ status: ${response.statusCode}');
          debugPrint('   └─ data: ${_preview(response.data)}');
        }
        handler.next(response);
      },

      onError: (e, handler) {
        if (enableLogs && kDebugMode) {
          final id = e.requestOptions.extra['reqId'] ?? '-';
          final started = e.requestOptions.extra['ts'] as int?;
          final took = started == null
              ? ''
              : ' (${DateTime.now().millisecondsSinceEpoch - started} ms)';

          debugPrint('❌ [ERR #$id]${took}');
          debugPrint('   └─ ${e.requestOptions.method} ${e.requestOptions.uri}');
          debugPrint('   └─ error: ${e.message}');
          if (e.response != null) {
            debugPrint('   └─ status: ${e.response?.statusCode}');
            debugPrint('   └─ body: ${_preview(e.response?.data)}');
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}

// ---- Robust error mapper you can reuse everywhere ----
// lib/core/network/dio_client.dart (या जहाँ भी है)
Never throwAsApi(Object error) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    final data = error.response?.data;

    // default message
    String? msg = error.message ?? 'Network error';
    Map<String, List<String>>? fieldErrors;

    if (data is Map) {
      // Backend typical: { message: "...", errors: { field: [msg] } }
      if (data['message'] != null) msg = data['message'].toString();

      if (data['errors'] is Map) {
        fieldErrors = {};
        (data['errors'] as Map).forEach((key, value) {
          if (value is List) {
            fieldErrors![key.toString()] =
                value.map((e) => e.toString()).toList();
          } else if (value != null) {
            fieldErrors![key.toString()] = [value.toString()];
          }
        });

        // अगर message generic है तो first field-error उठा लो
        if ((msg == null || msg.trim().isEmpty) && fieldErrors.isNotEmpty) {
          msg = fieldErrors.values.first.first;
        }
      }
    } else if (data is String && data.trim().isNotEmpty) {
      msg = data;
    }

    throw ApiException(msg ?? 'Network error',
        statusCode: code, fieldErrors: fieldErrors);
  }

  throw ApiException(error.toString());
}

// ----------------- small helpers -----------------

// tiny rolling id to correlate request/response in logs
int _rid = Random().nextInt(90000) + 10000;
String _nextReqId() {
  _rid = (_rid + 1) % 99999;
  return _rid.toString().padLeft(5, '0');
}

Map<String, dynamic> _maskedHeaders(Map<String, dynamic> headers) {
  final h = Map<String, dynamic>.from(headers);
  final auth = h['Authorization']?.toString();
  if (auth != null && auth.isNotEmpty) {
    h['Authorization'] = auth.length <= 16 ? '***' : '${auth.substring(0, 8)}***';
  }
  return h;
}

String _preview(dynamic data, {int max = 800}) {
  try {
    final s = data?.toString() ?? '';
    if (s.length <= max) return s;
    return '${s.substring(0, max)} …(${s.length - max} more chars)';
  } catch (_) {
    return '<non-string body>';
  }
}

