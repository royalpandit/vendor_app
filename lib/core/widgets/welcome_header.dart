import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';

/// A reusable header showing "Welcome Back" and the leads count subtitle.
///
/// It reads values from [AuthProvider] so it updates automatically when the
/// dashboard or vendor details change.  Use this at the top of screens that
/// share the same wording (home, bookings, inbox, etc.).
class WelcomeHeader extends StatelessWidget {
  /// Optional padding around the header; defaults to horizontal 16.
  final EdgeInsetsGeometry padding;

  const WelcomeHeader({Key? key, this.padding = const EdgeInsets.symmetric(horizontal: 16)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          Text(
            'Welcome Back, ${auth.vendorDetails?.name ?? 'Vendor'}',
            style: TextStyle(
              color: const Color(0xFF171719),
              fontSize: 26,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w500,
              height: 1.13,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${auth.dashboardData?.totalLeads ?? 0} new leads are waiting for you! 🔥',
            style: TextStyle(
              color: const Color(0xFF5C5C5C),
              fontSize: 14,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
