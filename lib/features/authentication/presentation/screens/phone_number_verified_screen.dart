import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/router/route_paths.dart';
import 'package:vendor_app/core/session/session.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/authentication/presentation/screens/basic_info_screen.dart';
import 'package:vendor_app/features/authentication/presentation/widgets/custom_text_field.dart';
import 'package:vendor_app/features/authentication/presentation/widgets/custom_text_field_enable.dart';
import 'package:vendor_app/features/home/presentation/screens/home_screen.dart';



class PhoneNumberVerifiedScreen extends StatefulWidget {
  @override
  _PhoneNumberVerifiedScreenState createState() =>
      _PhoneNumberVerifiedScreenState();
}

class _PhoneNumberVerifiedScreenState extends State<PhoneNumberVerifiedScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpPhase = false; // false => sendOtp phase, true => verifyOtp phase

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showMsg(BuildContext ctx, String msg) {
    if (msg.isEmpty) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10;
  }

  Future<void> _onConfirmPressed(BuildContext ctx) async {
    final auth = ctx.read<AuthProvider>();
    final phone = _phoneController.text.trim();

    // Phase 1: Send OTP
    if (!_otpPhase) {
      if (phone.isEmpty) {
        _showMsg(ctx, 'Please enter phone number');
        return;
      }
      if (!_isValidPhone(phone)) {
        _showMsg(ctx, 'Please enter a valid 10-digit phone number');
        return;
      }

      await auth.sendOtp(phone);

      // Success heuristic: message success / devOtp present
      final msg = auth.message?.toLowerCase() ?? '';
      final success = (auth.devOtp != null && auth.devOtp!.isNotEmpty) ||
          msg.contains('success') ||
          msg.contains('sent') ||
          msg.contains('generated');

      if (success) {
        setState(() => _otpPhase = true); // lock phone field, show OTP field
      }

      if (auth.message != null && auth.message!.isNotEmpty) {
        _showMsg(ctx, auth.message!);
      }
      if (auth.devOtp != null && auth.devOtp!.isNotEmpty) {
        _showMsg(ctx, 'Dev OTP: ${auth.devOtp}');
      }
      return;
    }

    // Phase 2: Verify OTP
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showMsg(ctx, 'Please enter OTP');
      return;
    }

    final ok = await auth.verifyOtp(phone: phone, token: otp, role: 'vendor');
    debugPrint('verify ok? $ok, msg: ${auth.message}');

    if (!mounted) return;

    if (ok) {
      _showMsg(ctx, auth.message ?? 'Login success');

      final phone = _phoneController.text.trim();

      if (auth.verifyType == "vendor_login") {
        //  Existing user → Home
        Navigator.pushReplacementNamed(
          context,
          RoutePaths.home,
          arguments: 0,
        );
      } else {
        //  New user → Basic Info
        Navigator.pushReplacementNamed(
          context,
          RoutePaths.basicInfo,
          arguments: phone,
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 3,
      ),
      body: Column(
        children: [
          if (auth.loading) const LinearProgressIndicator(minHeight: 3),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Phone Number',
                    style: TextStyle(
                      fontFamily: 'OnestSemiBold',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your phone number so that we could send you a verification code and get yourself verified.",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'OnestRegular',
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Phone (visible always; gets disabled after OTP sent)
                  CustomTextFieldEnable(
                    controller: _phoneController,
                    label: "Phone Number",
                    keyboardType: TextInputType.phone,

                     enabled: !auth.loading && !_otpPhase,
                  ),
                  const SizedBox(height: 16),

                  // OTP section — only after sendOtp success
                  if (_otpPhase) ...[
                    CustomTextFieldEnable(
                      controller: _otpController,
                      label: "One Time Password",
                      keyboardType: TextInputType.number,
                       enabled: !auth.loading,

                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We’ve sent a code to your number. Enter it to continue.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'OnestRegular',
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Single button: Confirm (Phase 1 → sendOtp, Phase 2 → verifyOtp)
                  ElevatedButton(
                    onPressed: auth.loading ? null : () => _onConfirmPressed(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pinkColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: auth.loading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _otpPhase ? "Verify & Continue" : "Confirm & Continue",
                      style: TextStyle(color: AppColors.whiteColor),
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



