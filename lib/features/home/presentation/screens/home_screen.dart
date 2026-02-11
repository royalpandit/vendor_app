import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/storage/shared_preferences.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.lightPinkColor, Colors.white],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back, Rajeeb',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  authProvider.loading
                      ? Text(
                          'Loading dashboard data...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade600,
                          ),
                        )
                      : Text(
                          '${authProvider.dashboardData?.totalLeads ?? 0} new leads are waiting for you! 🔥',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade600,
                          ),
                        ),
                  SizedBox(height: 10),
                  Text(
                    'Your Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDashboardCard(
                          title:
                              '${authProvider.dashboardData?.totalLeads ?? 0}',
                          subtitle: 'New Leads',
                          color: AppColors.lightPink,
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
                        _buildDashboardCard(
                          title:
                              '${authProvider.dashboardData?.totalBooking ?? 0}',
                          subtitle: 'Active Bookings',
                          color: AppColors.lightBlue,
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
                        _buildDashboardCard(
                          title:
                              '₹${authProvider.dashboardData?.totalEarning ?? '0.00'}',
                          subtitle: 'Earnings Overview',
                          color: AppColors.lightSky,
                          iconPath: AppIcons.earningIcon,
                          onTap: () {
                            // Handle other actions
                          },
                        ),
                        _buildDashboardCard(
                          title: '85%',
                          subtitle: 'Visibility Ratio',
                          color: AppColors.lightYellow,
                          iconPath: AppIcons.visibilityIcon,
                          onTap: () {
                            // Handle other actions
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),

              // Latest Leads Section
                Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Leads',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    authProvider.dashboardData?.latestLeads.isNotEmpty ?? false
                        ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: authProvider.dashboardData?.latestLeads.length,
                      itemBuilder: (context, index) {
                        final lead = authProvider.dashboardData!.latestLeads[index];
                        return _buildLeadCard(
                          name: lead.user.name,
                          email: lead.user.email ?? 'No email',
                          budget: lead.budget,
                          date: lead.eventDate,
                          location: lead.address,
                        );
                      },
                    )
                        : Text('No leads available.'),
                  ],
                ),
              ),


              // Latest Leads Section

            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: widget.currentIndex,
      ),
    );
  }

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
                    fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Budget',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
                  'Decline Order',
                  Colors.red,
                  'assets/icons/decline_icon.png',
                ),
                SizedBox(width: 8),
                _buildActionButton(
                  'Accept Order',
                  Colors.green,
                  'assets/icons/accept_icon.png',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildActionButton(String label, Color color, String iconPath) {
    return TextButton.icon(
      onPressed: () {
        // Action to be performed
      },
      icon: Image.asset(iconPath, width: 20, height: 20),
      label: Text(label, style: TextStyle(color: color)),
    );
  }
}

/*
class HomeScreen extends StatefulWidget {
  final int currentIndex;
  HomeScreen({required this.currentIndex});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent, // Make the app bar transparent
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.lightPinkColor, // Pink color at the top
                  Colors.white, // White color at the bottom
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back, Rajeeb',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '8 new leads are waiting for you! 🔥',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Wrap the entire body with a scroll view
        child: Container(
            // Start below status bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Section: Apply gradient only to this part (Welcome text, Leads, and Dashboard title)


              // Non-gradient Section for Dashboard Cards
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Section (No gradient, plain background)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDashboardCard(
                          title: '8',
                          subtitle: 'New Leads',
                          color: AppColors.lightPink,
                          iconPath: AppIcons.leadIcon,
                          onTap: () {
                            // Navigate to the New Leads Screen when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewLeadsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          title: '12',
                          subtitle: 'Active Bookings',
                          color: AppColors.lightBlue,
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
                        _buildDashboardCard(
                          title: '₹48,500',
                          subtitle: 'Earnings Overview',
                          color: AppColors.lightSky,
                          iconPath: AppIcons.earningIcon,
                          onTap: () {
                            // Handle other actions
                          },
                        ),
                        _buildDashboardCard(
                          title: '85%',
                          subtitle: 'Visibility Ratio',
                          color: AppColors.lightYellow,
                          iconPath: AppIcons.visibilityIcon,
                          onTap: () {
                            // Handle other actions
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),

              // Latest Leads Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Leads',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildLeadCard(
                      name: 'Priya S.',
                      email: 'priyaswami99@gmail.com',
                      budget: '₹75,000',
                      date: '15/09/2025',
                      location: 'Gurgaon, Gurgaon',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required Color color,
    required String iconPath, // Custom icon path
    required VoidCallback onTap, // Callback for tapping the card
  }) {
    return GestureDetector(
      onTap: onTap, // This will trigger the onTap function passed in
      child: Card(
        elevation: 5, // Add elevation to the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ), // Rounded corners for the card
        ),
        child: Container(
          width: (MediaQuery.of(context).size.width - 48) / 2,
          // Adjust width
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              10,
            ), // Rounded corners for the content inside the card
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // Aligns the title and the arrow icon
                children: [
                  Row(
                    children: [
                      Image.asset(
                        iconPath, // Custom icon for each card
                        width: 36,
                        height: 36,
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward, // Arrow icon to be added
                    color: Colors.black, // Same color as the card
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                // Explicitly align title to the left
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Add space between title and subtitle

              // Subtitle aligned to the left
              Align(
                alignment: Alignment.centerLeft,
                // Explicitly align subtitle to the left
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
    required String name,
    required String email,
    required String budget,
    required String date,
    required String location,
  }) {
    return Card(
      elevation: 5,
      // Card elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners for the card
      ),
      color: AppColors.lightGrey,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // White Section for Name, Email, and Budget
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, // White background
                borderRadius: BorderRadius.circular(10), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightGrey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Budget',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Email and Amount in another Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        email,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text('$budget', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Date and Location in Row
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
                // Decline Order button with circular icon
                _buildActionButton(
                  'Decline Order',
                  Colors.red,
                  'assets/icons/decline_icon.png',
                ),
                SizedBox(width: 8),

                // Accept Order button with circular icon
                _buildActionButton(
                  'Accept Order',
                  Colors.green,
                  'assets/icons/accept_icon.png',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, String iconPath) {
    return TextButton.icon(
      onPressed: () {
        // Action to be performed
      },
      icon: Image.asset(
        iconPath, // Custom icon for each button
        width: 20, // Adjust width for the icon
        height: 20, // Adjust height for the icon
      ),
      label: Text(
        label,
        style: TextStyle(
          color: color,
        ), // Set the label color based on the button color
      ),
    );
  }
}
*/
