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
      authProvider.fetchVendorDetails(userId);  // Fetch vendor details
      authProvider.fetchVendorDashboard(userId);  // Fetch dashboard data
      authProvider.fetchActiveBookings(userId);  // Fetch active bookings
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.43, 0.05),
              end: Alignment(0.44, 0.26),
              colors: [const Color(0xFFFFE5E8), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Text(
                            'Welcome Back, ${authProvider.vendorDetails?.name ?? 'Vendor'}',
                            style: TextStyle(
                              color: const Color(0xFF171719),
                              fontSize: 32,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w600,
                              height: 1.13,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Text(
                            '${authProvider.dashboardData?.totalLeads ?? 0} new leads are waiting for you! 🔥',
                            style: TextStyle(
                              color: const Color(0xFF5C5C5C),
                              fontSize: 16,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24),
                      // Search Bar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFCFCFC),
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
                                    width: 16,
                                    height: 16,
                                    child: Image.asset(
                                      'assets/icons/Icon.png',
                                      width: 14,
                                      height: 14,
                                    ),
                                  ),
                                  SizedBox(width: 6),
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
                          ),
                          SizedBox(width: 8),
                          // Filter Button
                          GestureDetector(
                            onTap: () => _showFilterBottomSheet(context),
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
                                  'assets/icons/setting-4.png',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
                // Bookings List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildBookingCard(
                                context: context,
                                bookingId: booking.id,
                                clientName: booking.user.name,
                                service: booking.serviceName,
                                budget: booking.budget,
                                date: booking.eventDate,
                                location: booking.address,
                                status: booking.status,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavigation(currentIndex: widget.currentIndex),
      ),
    );
  }

  // Method to determine button text based on status
  String _getButtonText(String status) {
    switch (status) {
      case 'In Progress':
      case 'confirmed':
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
        return const Color(0xFFF2AC57);
      case 'confirmed':
        return const Color(0xFF14A38B);
      case 'Pending':
        return const Color(0xFFFF7171);
      case 'Completed':
        return const Color(0xFF7188FF);
      default:
        return Colors.grey;
    }
  }

  // Booking Card Widget
  Widget _buildBookingCard({
    required BuildContext context,
    required int bookingId,
    required String clientName,
    required String service,
    required String budget,
    required String date,
    required String location,
    required String status,
  }) {
    return GestureDetector(
      onTap: () {
        _showBookingDetailsBottomSheet(
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
          // Booking ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: ShapeDecoration(
                  color: _getButtonColor(status),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w400,
                    height: 1.20,
                  ),
                ),
              ),
            ],
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
              // Action Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (status == "In Progress" || status == "confirmed") {
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
                    }
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
                        if (status == "In Progress" || status == "confirmed") ...[  
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
                        ],
                        Text(
                          _getButtonText(status),
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
    ),
    );
  }

  void _showBookingDetailsBottomSheet(
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
          decoration: ShapeDecoration(
            color: const Color(0xFFF9F9F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x4C000000),
                blurRadius: 3,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 8,
                offset: Offset(0, 4),
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF79747E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Steps
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFFEF1F2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.pink,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Start',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF1D2129),
                                  fontSize: 14,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                ),
                              ),
                              Text(
                                'Date',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF4E5969),
                                  fontSize: 12,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFFF4678),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '2',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w500,
                                      height: 1.50,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'In progress',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFFFF4678),
                                  fontSize: 14,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w500,
                                  height: 1.40,
                                ),
                              ),
                              Text(
                                'Date',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF4E5969),
                                  fontSize: 12,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFF2F3F5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '3',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF86909C),
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w500,
                                      height: 1.50,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Step 3',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF86909C),
                                  fontSize: 14,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                ),
                              ),
                              Text(
                                'Date',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF4E5969),
                                  fontSize: 12,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Booking Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: ShapeDecoration(
                                  color: _getButtonColor(status),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Text(
                                  status,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w400,
                                    height: 1.20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
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
                                    '\u20b9$budget',
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
                          SizedBox(height: 12),
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
                        ],
                      ),
                    ),
                    SizedBox(height: 80),
                    // Action Buttons
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(0xFFFF7171),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Close',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFFF7171),
                            fontSize: 16,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                            letterSpacing: 0.09,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Handle message action
                          },
                          child: Container(
                            width: 48,
                            height: 48,
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
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
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
                            child: Container(
                              height: 48,
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
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    String? selectedStatus;
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: ShapeDecoration(
                color: const Color(0xFFF9F9F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF79747E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Bookings',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 24),
                        // Status Filter
                        Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFilterChip('All', selectedStatus == null, () {
                              setState(() => selectedStatus = null);
                            }),
                            _buildFilterChip('In Progress', selectedStatus == 'In Progress', () {
                              setState(() => selectedStatus = 'In Progress');
                            }),
                            _buildFilterChip('Pending', selectedStatus == 'Pending', () {
                              setState(() => selectedStatus = 'Pending');
                            }),
                            _buildFilterChip('Completed', selectedStatus == 'Completed', () {
                              setState(() => selectedStatus = 'Completed');
                            }),
                          ],
                        ),
                        SizedBox(height: 24),
                        // Date Filter
                        Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() => selectedDate = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: const Color(0x4CDBE2EA),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/calendar.png',
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  selectedDate == null
                                      ? 'Select Date'
                                      : '\${selectedDate!.day}/\${selectedDate!.month}/\${selectedDate!.year}',
                                  style: TextStyle(
                                    color: selectedDate == null
                                        ? const Color(0x4737383C)
                                        : Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // Apply Button
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Clear filters
                                  setState(() {
                                    selectedStatus = null;
                                    selectedDate = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: const Color(0xFFFF4678),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Clear',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFFFF4678),
                                      fontSize: 16,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Apply filters (implement filter logic here)
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF14A38B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Apply',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFFF4678) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? const Color(0xFFFF4678) : const Color(0x4CDBE2EA),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 13,
            fontFamily: 'Onest',
            fontWeight: FontWeight.w400,
          ),
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

                    /// Booking ID + Status
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

                    /// Name
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
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

                    /// Budget
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


Widget _stepItem(String title, bool isActive) {
  return Column(
    children: [
      CircleAvatar(
        radius: 10,
        backgroundColor:
        isActive ? Colors.pink : Colors.grey.shade300,
        child: isActive
            ? const Icon(Icons.check,
            size: 10, color: Colors.white)
            : null,
      ),
      const SizedBox(height: 6),
      Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.pink : Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    ],
  );
}

