import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/core/utils/custom_bottom_navigation.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/booking/presentation/screens/active_booking_screen.dart';
import 'package:vendor_app/features/home/presentation/screens/new_leads_screen.dart';

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
    print("User ID==>>>: $userId");
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
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.43, 0.05),
              end: Alignment(0.44, 0.26),
              colors: [const Color(0xFFFFE5E8), Colors.white],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Welcome Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 380,
                          child: Text(
                            'Welcome Back, ${authProvider.vendorDetails?.name ?? 'Vendor'}',
                            style: TextStyle(
                              color: const Color(0xFF171719),
                              fontSize: 32,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w500,
                              height: 1.13,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          width: 380,
                          child: authProvider.loading
                              ? Text(
                                  'Loading dashboard data...',
                                  style: TextStyle(
                                    color: const Color(0xFF5C5C5C),
                                    fontSize: 16,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              : Text(
                                  '${authProvider.dashboardData?.totalLeads ?? 0} new leads are waiting for you! 🔥',
                                  style: TextStyle(
                                    color: const Color(0xFF5C5C5C),
                                    fontSize: 16,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Dashboard Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 380,
                          child: Text(
                            'Your Dashboard',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        // Dashboard Cards
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNewDashboardCard(
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
                            _buildNewDashboardCard(
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
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNewDashboardCard(
                              count: '₹${authProvider.dashboardData?.totalEarning ?? '0.00'}',
                              label: 'Earnings Overview',
                              color: const Color(0xFFDCFFF9),
                              iconPath: AppIcons.earningIcon,
                              isEarning: true,
                              onTap: () {},
                            ),
                            _buildNewDashboardCard(
                              count: '85%',
                              label: 'Visibility Ratio',
                              color: const Color(0xFFFFF5E9),
                              iconPath: AppIcons.visibilityIcon,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Latest Leads Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest Leads',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                        SizedBox(height: 12),
                        authProvider.dashboardData?.latestLeads.isNotEmpty ?? false
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: authProvider.dashboardData?.latestLeads.length,
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
                            : Text(
                                'No leads available.',
                                style: TextStyle(
                                  fontFamily: 'Onest',
                                  color: Colors.grey,
                                ),
                              ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 182,
        height: 141,
        padding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(iconPath, width: 24, height: 24),
                  ),
                ),
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
            SizedBox(height: 24),
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
                            fontSize: 24,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),
                        TextSpan(
                          text: count.substring(1),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
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
                      fontSize: 24,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                    ),
                  ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.52),
                    fontSize: 14,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 146,
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w500,
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
                          fontSize: 12,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                          height: 1.17,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w400,
                        height: 1.80,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      budget,
                      style: TextStyle(
                        color: const Color(0xFF171719),
                        fontSize: 16,
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
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: const Color(0xFF171719)),
                  SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: const Color(0xFF171719),
                      fontSize: 12,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: const Color(0xFF171719)),
                  SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      color: const Color(0xFF171719),
                      fontSize: 12,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildNewActionButton(
                bookingId: bookingId,
                label: 'Decline Order',
                color: const Color(0xFFFF7171),
                iconPath: 'assets/icons/decline_icon.png',
                action: "reject",
                filled: false,
              ),
              SizedBox(width: 16),
              _buildNewActionButton(
                bookingId: bookingId,
                label: 'Accept Order',
                color: const Color(0xFF14A38B),
                iconPath: 'assets/icons/accept_icon.png',
                action: "approve",
                filled: true,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.message ?? 'Updated')),
          );

          // Refresh dashboard after update
          final user = await TokenStorage.getUserData();
          final userId = user?.id ?? 0;
          provider.fetchVendorDashboard(userId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.message ?? 'Failed')),
          );
        }
      },
      child: Container(
        width: 170,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
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
            Image.asset(iconPath, width: 24, height: 24),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : color,
                fontSize: 16,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w500,
                height: 1.50,
                letterSpacing: 0.09,
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
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                      Text(
                        email,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
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
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.message ?? 'Updated')),
          );

          // 🔄 Refresh dashboard after update
          final user = await TokenStorage.getUserData();
          final userId = user?.id ?? 0;
          provider.fetchVendorDashboard(userId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.message ?? 'Failed')),
          );
        }
      },
      icon: Image.asset(iconPath, width: 20, height: 20),
      label: Text(label, style: TextStyle(color: color)),
    );
  }

}


