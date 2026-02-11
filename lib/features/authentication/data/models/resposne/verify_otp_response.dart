
import 'package:vendor_app/features/authentication/data/models/user_model.dart';

/// यह क्लास **data** object को represent करती है (यानी response.data)
class VerifyOtpResponse {
  final UserModel user;
  final String token;
  final String tokenType;
  final String verifyType;   // 👈 NEW

  VerifyOtpResponse({
    required this.user,
    required this.token,
    required this.tokenType,
    required this.verifyType,   // 👈 NEW
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
      verifyType: json['verify_type']?.toString() ?? '', // 👈 NEW
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'token': token,
    'token_type': tokenType,
    'verify_type': verifyType,  // 👈 NEW
  };
}

