import 'package:flutter/material.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';

class ActiveBookingsScreen extends StatefulWidget {
  @override
  _ActiveBookingsScreenState createState() => _ActiveBookingsScreenState();
}

class _ActiveBookingsScreenState extends State<ActiveBookingsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch active bookings when the screen is loaded
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Active Booking'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: 'Search for Bookings',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // "Today" section heading
            Text(
              'Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            // Lead List
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.loading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (authProvider.activeBookingsModels == null ||
                      authProvider.activeBookingsModels!.isEmpty) {
                    return Center(child: Text('No active bookings available.'));
                  }

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
                        buttonText: 'Mark as Complete',
                        buttonColor: Color(0xFF14A38B), // Green
                        buttonIcon: 'assets/icons/complete_icon.png',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lead Card Widget
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
          color: AppColors.lightGrey,
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
                  'Budget',
                  style: TextStyle(
                    fontSize: 14,
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
                  '$budget',
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle action on button click
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10), // Padding for button
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        buttonIcon,
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        buttonText,
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
class ActiveBookingsScreen extends StatefulWidget {

  @override
  _ActiveBookingsScreenState createState() => _ActiveBookingsScreenState();
}

class _ActiveBookingsScreenState extends State<ActiveBookingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Active Booking'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: 'Search for Bookings',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // "Today" section heading
            Text(
              'Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            // Lead List
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
    );
  }
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
          color: AppColors.lightGrey, // White color for the container
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
                */
/*Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),*//*

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
  Widget _buildBookingCards({
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
      child: Padding(
        padding: EdgeInsets.all(16),
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
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: status == 'In Progress'
                        ? Colors.orange
                        : status == 'Pending'
                        ? Colors.red
                        : Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(clientName, style: TextStyle(fontSize: 18)),
            SizedBox(height: 4),
            Text(service, style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Budget: $budget', style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                SizedBox(width: 4),
                Text(date, style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey, size: 16),
                SizedBox(width: 4),
                Text(location, style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            SizedBox(height: 16),

            // Action Button (Mark as Complete)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle action on button click
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10), // Padding for button
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        buttonIcon,
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        buttonText,
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
*/
