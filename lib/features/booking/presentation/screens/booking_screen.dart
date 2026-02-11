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
                  bookingId:    booking.id,
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
    required int bookingId,
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
                  '#BK-$bookingId',
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
                      if (status == "In Progress" || status == "confirmed") {
                        _showCompleteBottomSheet(context, bookingId, clientName, service, budget, date, location, status);
                      }

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
  void _showCompleteBottomSheet(
      BuildContext context,
      int bookingId,
      String clientName,
      String service,
      String budget,
      String date,
      String location,
      String status,
      )
  {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// Drag line
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// Step Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stepItem("Start", true),
                  _stepItem("In progress", true),
                  _stepItem("Step 3", false),
                ],
              ),

              const SizedBox(height: 20),

              /// Booking Card Design (Screenshot 1 style)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Booking ID + Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#BK-$bookingId',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFAC57),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// Name
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    /// Service
                    Text(
                      service,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// Date & Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(date, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(location, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// Budget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Budget",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "₹$budget",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Close Button
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Close"),
              ),

              const SizedBox(height: 15),

              /// Final Complete Button
              ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<AuthProvider>();

                    Navigator.pop(context);

                    final result = await provider.updateBookingStatus(
                      bookingId: bookingId,
                      action: "confirmed",   // confirm karna hai
                    );

                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking marked as completed")),
                      );

                      // Refresh bookings
                      final user = await TokenStorage.getUserData();
                      if (user?.id != null) {
                        provider.fetchActiveBookings(user!.id!);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.message ?? "Failed")),
                      );
                    }
                  },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14A38B),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Mark as Complete",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


}


Widget _stepItem(String title, bool isActive) {
  return Column(
    children: [
      CircleAvatar(
        radius: 14,
        backgroundColor:
        isActive ? Colors.pink : Colors.grey.shade300,
        child: isActive
            ? const Icon(Icons.check,
            size: 14, color: Colors.white)
            : null,
      ),
      const SizedBox(height: 6),
      Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.pink : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

