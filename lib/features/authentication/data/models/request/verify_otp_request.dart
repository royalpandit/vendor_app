// lib/features/auth/data/models/verify_otp_request.dart
class VerifyOtpRequest {
  final String phone;
  final String token; // OTP
  final String role;  // e.g. "vendor"

  VerifyOtpRequest({required this.phone, required this.token, required this.role});

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) {
    return VerifyOtpRequest(
      phone: json['phone']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'token': token,
    'role': role,
  };
}
