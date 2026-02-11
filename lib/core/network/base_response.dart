// lib/core/network/base_response.dart
class BaseResponse<T> {
  final int? code;
  final String? status;
  final String? message;
  final T? data;

  BaseResponse({this.code, this.status, this.message, this.data});

  /// fromJson with a parser for T
  factory BaseResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic raw) parseT,
      ) {
    return BaseResponse<T>(
      code: json['code'] as int?,
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] == null ? null : parseT(json['data']),
    );
  }

  /// toJson with a serializer for T
  Map<String, dynamic> toJson(Object? Function(T value) toRawT) {
    return {
      'code': code,
      'status': status,
      'message': message,
      'data': data == null ? null : toRawT(data as T),
    };
  }
}
