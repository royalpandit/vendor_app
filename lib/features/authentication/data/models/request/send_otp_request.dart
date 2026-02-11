// lib/features/auth/data/models/send_otp_request.dart
class SendOtpRequest {
  final String phone;
  SendOtpRequest({required this.phone});

  factory SendOtpRequest.fromJson(Map<String, dynamic> json) {
    return SendOtpRequest(phone: json['phone']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() => {'phone': phone};
}
