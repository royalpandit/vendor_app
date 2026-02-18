import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/router/route_paths.dart';
import 'package:vendor_app/core/session/session.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_theme.dart';
import 'package:vendor_app/core/utils/responsive_util.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/authentication/presentation/screens/basic_info_screen.dart';
import 'package:vendor_app/features/home/presentation/screens/home_screen.dart';
import 'package:vendor_app/core/utils/app_message.dart';



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
    // ignore: unawaited_futures
    AppMessage.show(ctx, msg);
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
    // verification result handled via UI messages

    if (!mounted) return;

    if (ok) {
      _showMsg(ctx, auth.message ?? 'Login success');

      final phone = _phoneController.text.trim();

      // be lenient with verifyType: accept any value containing 'login' as existing user
      final vt = (auth.verifyType ?? '').toLowerCase();
      if (vt.contains('login')) {
        // Existing user → Home
        Navigator.pushReplacementNamed(
          context,
          RoutePaths.home,
          arguments: 0,
        );
      } else {
        // New user → Basic Info
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
    final maxWidth = ResponsiveUtil.constrainedWidth(context, maxWidth: 380);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Column(
        children: [
          if (auth.loading) 
            LinearProgressIndicator(
              minHeight: 3,
              color: AppTheme.primaryPink,
              backgroundColor: AppTheme.lightPink,
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveUtil.padding(context, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveUtil.verticalSpace(context, 10),
                  
                  // Title
                  Text(
                    'Your Phone Number',
                    style: AppTheme.heading2,
                  ),
                  ResponsiveUtil.verticalSpace(context, 1.5),
                  
                  // Description
                  Text(
                    'Enter your phone number so that we could send you a verification code and get yourself verified',
                    style: AppTheme.bodyRegular.copyWith(
                      color: AppTheme.gray,
                    ),
                  ),
                  ResponsiveUtil.verticalSpace(context, 3),

                  // Phone Number Label
                  Text(
                    'Phone Number',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.gray,
                    ),
                  ),
                  ResponsiveUtil.verticalSpace(context, 1),

                  // Phone Number Input
                  Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    decoration: BoxDecoration(
                      color: AppTheme.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.inputBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x0A2C2738),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _phoneController,
                      enabled: !auth.loading && !_otpPhase,
                      keyboardType: TextInputType.phone,
                      style: AppTheme.inputText,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your phone number',
                        hintStyle: AppTheme.hintText,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                  ResponsiveUtil.verticalSpace(context, 2),

                  // OTP section — only after sendOtp success
                  if (_otpPhase) ...[
                    // OTP Label
                    Text(
                      'One Time Password',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.gray,
                      ),
                    ),
                    ResponsiveUtil.verticalSpace(context, 1),
                    
                    // OTP Input
                    Container(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      decoration: BoxDecoration(
                        color: AppTheme.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.inputBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x0A2C2738),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _otpController,
                        enabled: !auth.loading,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: AppTheme.inputText,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter OTP',
                          hintStyle: AppTheme.hintText,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                    ResponsiveUtil.verticalSpace(context, 1),
                    Text(
                      "We've sent a code to your number. Enter it to continue.",
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],

                  ResponsiveUtil.verticalSpace(context, 4),

                  // Single button: Confirm (Phase 1 → sendOtp, Phase 2 → verifyOtp)
                  GestureDetector(
                    onTap: auth.loading ? null : () => _onConfirmPressed(context),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
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
                                style: AppTheme.button,
                              ),
                      ),
                    ),
                  ),
                  ResponsiveUtil.verticalSpace(context, 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



