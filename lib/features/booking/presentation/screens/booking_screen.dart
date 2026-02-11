import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/core/utils/custom_bottom_navigation.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
class BookingScreen extends StatefulWidget {
  final int currentIndex;
  BookingScreen({required this.currentIndex});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}
class _BookingScreenState extends State<BookingScreen> {
 /* @override
  void initState() {
    super.initState();
    // Set the status bar color to match the gradient's top color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.lightPinkColor, // Set status bar icons to dark for better visibility
    ));
  }*/

  @override
  void initState() {
    super.initState();
    // Fetch the user ID from TokenStorage dynamically
    _fetchUserIdAndBookings();
  }

  Future<void> _fetchUserIdAndBookings() async {
    // Get user data from TokenStorage
    final userData = await TokenStorage.getUserData();
    final int userId = userData?.id ?? 0;  // Use a default value if userId is null

    if (userId != 0) {
      final authProvider = context.read<AuthProvider>();
      authProvider.fetchActiveBookings(userId);  // Fetch active bookings
    } else {
      // Handle case where userId is not found or user is not logged in
      print("User ID not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120), // Increased height for extra content
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: null,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightPinkColor, // Pink color at the top
                  AppColors.lightGrey, // White color
                ],
                stops: [0.0, 0.8],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16), // Adjusted padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back, Rajeeb',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '8 new leads are waiting for you! 🔥',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 5),
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search for bookings',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                          child: Image.asset(
                            'assets/icons/search_icon.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: null,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Check if loading
            if (authProvider.loading) {
              return Center(child: CircularProgressIndicator());
            }

            // If there are no bookings
            if (authProvider.activeBookingsModels == null ||
                authProvider.activeBookingsModels!.isEmpty) {
              return Center(child: Text('No active bookings available.'));
            }


            // Display list of bookings
            return ListView.builder(
              itemCount: authProvider.activeBookingsModels?.length ?? 0,
              itemBuilder: (context, index) {
                final booking = authProvider.activeBookingsModels![index];
                return _buildBookingCard(
                  bookingId: '#BK-${booking.id}',
                  clientName: booking.user.name,
                  service: booking.serviceName,
                  budget: booking.budget,
                  date: booking.eventDate,
                  location: booking.address,
                  status: booking.status,
                  buttonText: _getButtonText(booking.status),
                  buttonColor: _getButtonColor(booking.status),
                  buttonIcon: _getButtonIcon(booking.status),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: 1),
    );
  }

  // Method to determine button text based on status
  String _getButtonText(String status) {
    switch (status) {
      case 'In Progress':
        return 'Mark as Complete';
      case 'Pending':
        return 'Start Booking';
      case 'Completed':
        return 'View Details';
      default:
        return 'Action';
    }
  }

  // Method to determine button color based on status
  Color _getButtonColor(String status) {
    switch (status) {
      case 'In Progress':
        return Color(0xFF14A38B); // Green
      case 'confirmed':
        return Color(0xFF14A38B); // Green
      case 'Pending':
        return Color(0xFFFFAC57); // Yellow
      case 'Completed':
        return Color(0xFF6D6E7A); // Grey
      default:
        return Colors.grey;
    }
  }

  // Method to determine button icon based on status
  String _getButtonIcon(String status) {
    switch (status) {
      case 'In Progress':
        return AppIcons.acceptIcon;
        case 'confirmed':
        return 'assets/icons/complete_icon.png';
      case 'Pending':
        return 'assets/icons/start_icon.png';
      case 'Completed':
        return 'assets/icons/details_icon.png';
      default:
        return 'assets/icons/default_icon.png';
    }
  }

  // Method to build the booking card
  Widget _buildBookingCard({
    required String bookingId,
    required String clientName,
    required String service,
    required String budget,
    required String date,
    required String location,
    required String status,
    required String buttonText,
    required Color buttonColor,
    required String buttonIcon,
  }) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // White color for the container
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bookingId,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getButtonColor(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  clientName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Budget',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(service, style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('$budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(date, style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(location, style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                   AppIcons.messageIcon, // Custom icon for message
                    width: 30,
                    height: 30,
                  ),
                ),
               /* Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(buttonIcon, width: 40, height: 40),
                ),*/
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle action on button click
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          buttonText,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
class BookingScreen extends StatefulWidget {
  final int currentIndex;
  BookingScreen({required this.currentIndex});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}
class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    // Set the status bar color to match the gradient's top color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.lightPinkColor, // Set status bar icons to dark for better visibility
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColors.lightGrey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120), // Increased height for extra content
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: null,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightPinkColor,// Pink color at the top
                  AppColors.lightGrey, // White color
                ],
                stops: [0.0, 0.8],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16), // Adjusted padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text
                  Text(
                    'Welcome Back, Rajeeb',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5), // Space between text and new title

                  // New Title (Subtitle or Heading)
                  Text(
                    '8 new leads are waiting for you! 🔥',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 5), // Space between title and container

                  // Container (You can add any content here, such as a description or stats)
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        // Container for TextField with BoxShadow
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search for bookings',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Filter Icon (Separate on the right, without box shadow)
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0,left: 8.0),
                          child: Image.asset(
                            'assets/icons/search_icon.png', // Replace with your custom filter icon path
                            width: 48,  // Adjust width as needed
                            height: 48, // Adjust height as needed
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: null, // Remove the default title, as we've custom-styled it
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Section


            // Bookings List
            Expanded(
              child: ListView(
                children: [
                  _buildBookingCard(
                    bookingId: '#BK-2489',
                    clientName: 'Rahul Mehta',
                    service: 'Catering Service - 200 Guests',
                    budget: '₹75,000',
                    date: '15/09/2025',
                    location: 'Gurgaon, Gurgaon',
                    status: 'In Progress',
                    buttonText: 'Mark as Complete',
                    buttonColor: Color(0xFF14A38B), // Green
                    buttonIcon: 'assets/icons/complete_icon.png', // Custom icon path
                  ),
                  _buildBookingCard(
                    bookingId: '#BK-2490',
                    clientName: 'Aditi Sharma',
                    service: 'Wedding Decor - 150 Guests',
                    budget: '₹120,000',
                    date: '22/10/2025',
                    location: 'Noida, Uttar Pradesh',
                    status: 'Pending',
                    buttonText: 'Start Booking',
                    buttonColor: Color(0xFFFFAC57), // Yellow
                    buttonIcon: 'assets/icons/complete_icon.png', // Custom icon path
                  ),
                  _buildBookingCard(
                    bookingId: '#BK-2491',
                    clientName: 'Sanjay Kumar',
                    service: 'Corporate Event - 100 Guests',
                    budget: '₹50,000',
                    date: '05/11/2025',
                    location: 'Delhi, Delhi',
                    status: 'Completed',
                    buttonText: 'View Details',
                    buttonColor: Color(0xFF6D6E7A), // Light Grey
                    buttonIcon: 'assets/icons/complete_icon.png', // Custom icon path
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: 1), // Update the index for Bookings
    );
  }

  // Method to build the booking card
  Widget _buildBookingCard({
    required String bookingId,
    required String clientName,
    required String service,
    required String budget,
    required String date,
    required String location,
    required String status,
    required String buttonText,
    required Color buttonColor,
    required String buttonIcon,
  }) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // White color for the container
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bookingId,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'In Progress'
                        ? Colors.orange
                        : status == 'Pending'
                        ? Colors.red
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Client Name and Budget in the same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  clientName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Budget',  // Budget value
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Service and Date in the next row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  service,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '$budget',  // Budget value
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Location info
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
            SizedBox(height: 16),
            // Action Button (Mark as Complete, Start Booking, etc.)
            Row(
              children: [
                // Message Icon
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    'assets/icons/search_icon.png', // Custom icon for message
                    width: 40,
                    height: 40,
                  ),
                ),
                // Expanded to make the button take full width
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle action on button click
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF14A38B), // Button color (green)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10), // Padding for button
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max, // Make the Row take full width
                      mainAxisAlignment: MainAxisAlignment.center, // Center the content
                      children: [
                        Icon(Icons.check, size: 20, color: Colors.white), // Checkmark icon
                        SizedBox(width: 8),
                        Text(
                          'Mark as Complete',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
*/

