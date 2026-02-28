import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
// import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/core/utils/app_theme.dart';
import 'package:vendor_app/core/utils/custom_bottom_navigation.dart';
import 'package:vendor_app/core/utils/responsive_util.dart';
import 'package:vendor_app/core/utils/skeleton_loader.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/booking/presentation/screens/active_booking_screen.dart';
import 'package:vendor_app/features/home/presentation/screens/new_leads_screen.dart';
import 'package:vendor_app/core/utils/app_message.dart';

class HomeScreen extends StatefulWidget {
  final int currentIndex;
  HomeScreen({required this.currentIndex});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _cachedVendorName;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    // Refresh dashboard data every 10 seconds

  }

  @override
  void dispose() {
     super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    // Fetch user data from SharedPreferences

    final userData = await TokenStorage.getUserData();
    final userId = userData?.id ?? 0;
    final authProvider = context.read<AuthProvider>();
    await authProvider.fetchVendorDashboard(userId);    // Only fetch vendor details if not already cached
    if (authProvider.vendorDetails == null) {
      await authProvider.fetchVendorDetails(userId);
    }
    // Use vendor name from API (the actual business name), not the OTP user name
    final vendorName = authProvider.vendorDetails?.name;
    if (vendorName != null && vendorName.isNotEmpty) {
      if (mounted) setState(() => _cachedVendorName = vendorName);
    } else if (_cachedVendorName == null && userData != null && userData.name.isNotEmpty) {
      if (mounted) setState(() => _cachedVendorName = userData.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.white,
        extendBodyBehindAppBar: false,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.43, 0.05),
              end: Alignment(0.44, 0.26),
              colors: [Color(0xFFFFE5E8), Colors.white],
            ),
          ),
          child: SafeArea(
            child: authProvider.loading
                ? SkeletonLoader.fullScreenDashboardSkeleton()
                : SingleChildScrollView(
                    padding: ResponsiveUtil.padding(context, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveUtil.verticalSpace(context, 3),

                        // Welcome Section (match booking screen sizes)
                        Text(
                          'Welcome Back, ${_cachedVendorName ?? authProvider.vendorDetails?.name ?? 'Vendor'}',
                          style: TextStyle(
                            color: const Color(0xFF171719),
                            fontSize: 26,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
                            height: 1.13,
                          ),
                        ),
                        ResponsiveUtil.verticalSpace(context, 1),
                        Text(
                          '${authProvider.dashboardData?.totalLeads ?? 0} new leads are waiting for you! 🔥',
                          style: TextStyle(
                            color: const Color(0xFF5C5C5C),
                            fontSize: 14,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        ResponsiveUtil.verticalSpace(context, 3),
                        const SizedBox(height: 12),

                        // Dashboard Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildNewDashboardCard(
                                count: '${authProvider.dashboardData?.totalLeads ?? 0}',
                                label: 'New Leads',
                                color: const Color(0xFFFAF0FF),
                                iconPath: AppIcons.leadIcon,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewLeadsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNewDashboardCard(
                                count: '${authProvider.dashboardData?.activeBooking ?? 0}',
                                label: 'Active Bookings',
                                color: const Color(0xFFE0E5FF),
                                iconPath: AppIcons.bookingIcon,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ActiveBookingsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNewDashboardCard(
                                count: '₹${authProvider.dashboardData?.totalEarning ?? '0.00'}',
                                label: 'Earnings Overview',
                                color: const Color(0xFFDCFFF9),
                                iconPath: AppIcons.earningIcon,
                                isEarning: true,
                                onTap: () {},
                                showForwardIcon: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNewDashboardCard(
                                  count: authProvider.dashboardData == null
                                      ? '0%'
                                      : '${authProvider.dashboardData!.visibilityRatio.toStringAsFixed(0)}%',
                                  label: 'Visibility Ratio',
                                  color: const Color(0xFFFFF5E9),
                                  iconPath: AppIcons.visibilityIcon,
                                  onTap: () {},
                                  showForwardIcon: false,
                                ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Latest Leads Section
                        Text(
                          'Latest Leads',
                          style: AppTheme.heading5.copyWith(color: AppTheme.black),
                        ),
                        const SizedBox(height: 12),

                        // Leads list
                        if (authProvider.dashboardData?.latestLeads != null && authProvider.dashboardData!.latestLeads.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: authProvider.dashboardData!.latestLeads.length,
                            itemBuilder: (context, index) {
                              final lead = authProvider.dashboardData!.latestLeads[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildNewLeadCard(
                                  bookingId: lead.id,
                                  name: lead.user.name,
                                  email: lead.user.email ?? 'No email',
                                  budget: lead.budget,
                                  date: lead.eventDate,
                                  location: lead.address,
                                ),
                              );
                            },
                          )
                        else
                          Text(
                            'No leads available.',
                            style: AppTheme.bodyRegular.copyWith(color: AppTheme.gray),
                          ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
            ),
        ),
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: widget.currentIndex,
        ),
      ),
    );
  }

  Widget _buildNewDashboardCard({
    required String count,
    required String label,
    required Color color,
    required String iconPath,
    required VoidCallback onTap,
    bool isEarning = false,
    bool showForwardIcon = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // allow parent to control width via Expanded; make height slightly smaller
        constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity, minHeight: 0),
        height: 120,
        padding: const EdgeInsets.all(10),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          // allow column to take available vertical space and distribute children
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(iconPath, width: 28, height: 28),
                  ),
                ),
                if (showForwardIcon)
                  Container(
                    width: 32,
                    height: 32,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Icon(Icons.arrow_forward, size: 24),
                  ),
              ],
            ),
            // reduced fixed spacing to avoid overflow in tight constraints
            SizedBox(height: 12),
            // Count and Label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEarning)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: count.substring(0, 1),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w300,
                            height: 1.33,
                          ),
                        ),
                        TextSpan(
                          text: count.substring(1),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    count,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.52),
                    fontSize: 12,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w400,
                    height: 1.29,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewLeadCard({
    required int bookingId,
    required String name,
    required String email,
    required String budget,
    required String date,
    required String location,
  }) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0xFFF4F4F4),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 146,
                        child: Text(
                          name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      SizedBox(
                        width: 146,
                        child: Text(
                          email,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.30),
                            fontSize: 11,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w400,
                            height: 1.17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w400,
                        height: 1.80,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹$budget',
                      style: TextStyle(
                        color: const Color(0xFF171719),
                        fontSize: 14,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          
          // Date and Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: const Color(0xFF171719)),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        date,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF171719),
                          fontSize: 11,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: const Color(0xFF171719)),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF171719),
                          fontSize: 11,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: _buildNewActionButton(
                  bookingId: bookingId,
                  label: 'Decline Order',
                  color: const Color(0xFFFF7171),
                  iconPath: 'assets/icons/decline_icon.png',
                  action: "reject",
                  filled: false,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildNewActionButton(
                  bookingId: bookingId,
                  label: 'Accept Order',
                  color: const Color(0xFF14A38B),
                  iconPath: 'assets/icons/accept_icon.png',
                  action: "approve",
                  filled: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewActionButton({
    required int bookingId,
    required String label,
    required Color color,
    required String iconPath,
    required String action,
    required bool filled,
  }) {
    return GestureDetector(
      onTap: () async {
        // Show confirmation popup for Decline
        if (action == 'reject') {
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4678).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_rounded, color: Color(0xFFFF4678), size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Decline Order?',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Are you sure you want to decline this order?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5C5C5C),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Color(0xFFDBE2EA)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('No', style: TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4678),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Yes', style: TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          if (confirmed != true) return;
        }

        final provider = context.read<AuthProvider>();

        final success = await provider.updateBookingStatus(
          bookingId: bookingId,
          action: action,
        );

        if (success) {
          // ignore: unawaited_futures
          AppMessage.show(context, provider.message ?? 'Updated');

          // Refresh dashboard after update
          final user = await TokenStorage.getUserData();
          final userId = user?.id ?? 0;
          provider.fetchVendorDashboard(userId);
        } else {
          // ignore: unawaited_futures
          AppMessage.show(context, provider.message ?? 'Failed');
        }
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: filled ? color : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: filled
                ? BorderSide.none
                : BorderSide(
                    width: 1,
                    color: color,
                  ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 20, height: 20),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: filled ? Colors.white : color,
                  fontSize: 13,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


