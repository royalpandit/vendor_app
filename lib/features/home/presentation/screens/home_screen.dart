import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
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
  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    // Fetch user data from SharedPreferences

    final userData = await TokenStorage.getUserData();
    final userId = userData?.id ?? 0;
    final authProvider = context.read<AuthProvider>();
    authProvider.fetchVendorDashboard(userId);
    authProvider.fetchVendorDetails(userId);
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
                          'Welcome Back, ${authProvider.vendorDetails?.name ?? 'Vendor'}',
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
                                count: '${authProvider.dashboardData?.totalBooking ?? 0}',
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
                                count: '85%',
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

  // Old widgets - keeping for backward compatibility if needed
  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required Color color,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: (MediaQuery.of(context).size.width - 48) / 2,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(iconPath, width: 36, height: 36),
                  Icon(Icons.arrow_forward, color: Colors.black),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadCard({
    required int bookingId,
    required String name,
    required String email,
    required String budget,
    required String date,
    required String location,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.lightGrey,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Budget',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(budget, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          date,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              _buildActionButton(
              bookingId: bookingId,
              label: 'Decline Order',
              color: Colors.red,
              iconPath: 'assets/icons/decline_icon.png',
              action: "reject",
            ),

                SizedBox(width: 8),
                _buildActionButton(
                  bookingId: bookingId,
                  label: 'Accept Order',
                  color: Colors.green,
                  iconPath: 'assets/icons/accept_icon.png',
                  action: "approve",
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildActionButton({
    required int bookingId,
    required String label,
    required Color color,
    required String iconPath,
    required String action, // approve | reject
  }) {
    return TextButton.icon(
      onPressed: () async {
        final provider = context.read<AuthProvider>();

        final success = await provider.updateBookingStatus(
          bookingId: bookingId,
          action: action,
        );

        if (success) {
          // ignore: unawaited_futures
          AppMessage.show(context, provider.message ?? 'Updated');

          // 🔄 Refresh dashboard after update
          final user = await TokenStorage.getUserData();
          final userId = user?.id ?? 0;
          provider.fetchVendorDashboard(userId);
        } else {
          // ignore: unawaited_futures
          AppMessage.show(context, provider.message ?? 'Failed');
        }
      },
      icon: Image.asset(iconPath, width: 20, height: 20),
      label: Text(label, style: TextStyle(color: color)),
    );
  }

}


