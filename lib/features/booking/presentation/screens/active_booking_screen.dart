import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vendor_app/core/network/token_storage.dart';
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
    final int userId =
        userData?.id ?? 0; // Use a default value if userId is null

    if (userId != 0) {
      final authProvider = context.read<AuthProvider>();
      authProvider.fetchActiveBookings(userId); // Fetch active bookings
    } else {
      // Handle case where userId is not found or user is not logged in
      print("User ID not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 24,
                          height: 24,
                          child: Image.asset(
                            'assets/icons/arrow-left.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Title
                      Text(
                        'Active Bookings',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w500,
                          height: 1.33,
                          letterSpacing: -0.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF7F7F7),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(0x4CDBE2EA),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Image.asset(
                                'assets/icons/Icon.png',
                                width: 18,
                                height: 18,
                              ),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search for bookings',
                                  hintStyle: TextStyle(
                                    color: const Color(0x4737383C),
                                    fontSize: 16,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    letterSpacing: 0.09,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Booking List
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
                                  bookingId: booking.id,
                                  clientName: booking.user.name,
                                  service: booking.serviceName,
                                  budget: booking.budget,
                                  date: booking.eventDate,
                                  location: booking.address,
                                  status: booking.status,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Booking Card Widget
  Widget _buildBookingCard({
    required int bookingId,
    required String clientName,
    required String service,
    required String budget,
    required String date,
    required String location,
    required String status,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
          // Booking ID
          Text(
            '#BK-$bookingId',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.09,
            ),
          ),
          SizedBox(height: 12),
          // Client Info and Budget Card
          Container(
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
                      Text(
                        clientName,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        service,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.70),
                          fontSize: 12,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w500,
                          height: 1.17,
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
                        color: Colors.black.withOpacity(0.60),
                        fontSize: 10,
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
                        fontSize: 16,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w700,
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
                  Image.asset(
                    'assets/icons/calendar.png',
                    width: 18,
                    height: 18,
                  ),
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
                  Image.asset(
                    'assets/icons/location.png',
                    width: 18,
                    height: 18,
                  ),
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
          SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              // Message Button
              GestureDetector(
                onTap: () {
                  // Handle message action
                },
                child: Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(10),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/message-text.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Mark as Complete Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showCompleteBottomSheet(
                      context,
                      bookingId,
                      clientName,
                      service,
                      budget,
                      date,
                      location,
                      status,
                    );
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF14A38B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/icons/tick-circle.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Mark as Complete',
                          style: TextStyle(
                            color: Colors.white,
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
                ),
              ),
            ],
          ),
        ],
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
      ) {
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

              /// Booking Card Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#BK-$bookingId',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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

                    Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      service,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/calendar.png',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(date, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/location.png',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(location, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Budget",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "₹$budget",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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

              /// Confirm Complete
              ElevatedButton(
                onPressed: () async {
                  final provider = context.read<AuthProvider>();

                  Navigator.pop(context);

                  final result = await provider.updateBookingStatus(
                    bookingId: bookingId,
                    action: "confirmed",
                  );

                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Booking marked as completed")),
                    );

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/icons/tick-circle.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Mark as Complete",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
