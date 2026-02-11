// lib/features/auth/data/models/send_otp_response.dart
class SendOtpResponse {
  final int? code;
  final String? status;
  final String? message;
  final String? otp;

  SendOtpResponse({this.code, this.status, this.message, this.otp});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      code: json['code'] as int?,
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      otp: json['otp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'status': status,
    'message': message,
    'otp': otp,
  };
}
