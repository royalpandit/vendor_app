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
import 'package:vendor_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:vendor_app/core/utils/app_message.dart';

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
      // silently ignore
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
                              fontSize: 26,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w500,
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
                              fontSize: 14,
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
                                          fontSize: 14,
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
                                        fontSize: 14,
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
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1000),
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/setting-4.png',
                                  width: 18,
                                  height: 18,
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
                          return SkeletonLoader.fullScreenBookingSkeleton();
                        }

                        if (authProvider.activeBookingsModels == null ||
                            authProvider.activeBookingsModels!.isEmpty) {
                          return Center(
                            child: Text(
                              'No active bookings available.',
                              style: AppTheme.bodyRegular.copyWith(
                                color: AppTheme.gray,
                              ),
                            ),
                          );
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
                                userId: booking.user.id,
                                userImage: booking.user.image,
                                vendorId: booking.vendorId,
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
      case 'completed':
        return const Color(0xFFFFAC57); // Yellow color
      case 'cancelled':
      case 'reject':
        return const Color(0xFFFF7171); // Red color
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
    required int userId,
    required String userImage,
    required int vendorId,
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
          userId,
          userImage,
          vendorId,
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
                  fontSize: 13,
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
                    fontSize: 9,
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
                          fontSize: 15,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        service,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.70),
                          fontSize: 11,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
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
                    Image.asset(
                      'assets/icons/calendar.png',
                      width: 16,
                      height: 16,
                    ),
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
                    Image.asset(
                      'assets/icons/location.png',
                      width: 16,
                      height: 16,
                    ),
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
          SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              // Message Button
              GestureDetector(
                onTap: () async {
                  // Navigate to chat with this user. Ensure we don't use a deactivated context.
                  final userData = await TokenStorage.getUserData();
                  final vendorId = userData?.id ?? 0;

                  if (vendorId == 0) return;

                  final authProvider = context.read<AuthProvider>();

                  // Fetch current inbox to check for an existing conversation
                  await authProvider.fetchInboxMessages(vendorId);

                  int conversationId = 0;
                  final inboxMessages = authProvider.inboxMessages;
                  for (var conversation in inboxMessages) {
                    final isSender = conversation.sender.id == vendorId;
                    final otherPersonId = isSender ? conversation.receiver.id : conversation.sender.id;
                    if (otherPersonId == userId) {
                      conversationId = conversation.id;
                      break;
                    }
                  }

                  // If no conversation exists, create one by sending a short initial message.
                  // This lets the server create the conversation entry and assign an id.
                  if (conversationId == 0) {
                    final created = await authProvider.sendMessage(
                      senderId: vendorId,
                      receiverId: userId,
                      messageText: 'Hi',
                    );

                    if (!created) {
                      if (mounted) AppMessage.show(context, authProvider.message ?? 'Could not create conversation');
                      return;
                    }

                    // Re-fetch inbox and look for the new conversation id
                    await authProvider.fetchInboxMessages(vendorId);
                    for (var conversation in authProvider.inboxMessages) {
                      final isSender = conversation.sender.id == vendorId;
                      final otherPersonId = isSender ? conversation.receiver.id : conversation.sender.id;
                      if (otherPersonId == userId) {
                        conversationId = conversation.id;
                        break;
                      }
                    }
                  }

                  // Navigate only if widget still mounted
                  if (!mounted) return;

                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        name: clientName,
                        image: userImage,
                        conversationId: conversationId,
                        receiverId: userId,
                        senderId: vendorId,
                      ),
                    ),
                  );
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
              // Action Button - Only show if not completed or cancelled
              if (status.toLowerCase() != 'completed' && status.toLowerCase() != 'cancelled' && status.toLowerCase() != 'reject')
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              width: 20,
                              height: 20,
                            ),
                          ),
                          SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            _getButtonText(status),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
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
    int userId,
    String userImage,
    int vendorId,
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
                    // Progress Steps (dynamic based on status)
                    Row(
                      children: [
                        (() {
                          final s = status.toLowerCase();
                          final startDone = s != 'pending';
                          return Expanded(child: _stepItem('Start', startDone));
                        })(),
                        (() {
                          final s = status.toLowerCase();
                          final step3Done = s == 'completed' || s == 'cancelled' || s == 'reject' || s == 'rejected';
                          final inProgressActive = s == 'in progress' || s == 'confirmed' || s == 'in_progress' || s == 'accepted' || step3Done;
                          return Expanded(child: _stepItem('In progress', inProgressActive));
                        })(),
                        (() {
                          final s = status.toLowerCase();
                          final step3Done = s == 'completed' || s == 'cancelled' || s == 'reject' || s == 'rejected';
                          return Expanded(child: _stepItem('Step 3', step3Done));
                        })(),
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
                              Flexible(
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/calendar.png',
                                      width: 18,
                                      height: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        date,
                                        style: TextStyle(
                                          color: const Color(0xFF171719),
                                          fontSize: 12,
                                          fontFamily: 'Onest',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/location.png',
                                      width: 18,
                                      height: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        location,
                                        style: TextStyle(
                                          color: const Color(0xFF171719),
                                          fontSize: 12,
                                          fontFamily: 'Onest',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                    SizedBox(height: 80),
                    // Action Buttons - only show top Cancel button when booking is not finished
                    if (status.toLowerCase() != 'completed' && status.toLowerCase() != 'cancelled' && status.toLowerCase() != 'reject') ...[
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
                            'Cancel',
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
                    ],
                    // Only show buttons if status is not completed or cancelled
                    if (status.toLowerCase() != 'completed' && status.toLowerCase() != 'cancelled' && status.toLowerCase() != 'reject') ...[
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // Navigate to chat screen; create conversation if missing
                              final userData = await TokenStorage.getUserData();
                              final currentVendorId = userData?.id ?? 0;
                              if (currentVendorId == 0) return;

                              final authProvider = context.read<AuthProvider>();
                              await authProvider.fetchInboxMessages(currentVendorId);

                              int conversationId = 0;
                              for (var conversation in authProvider.inboxMessages) {
                                final isSender = conversation.sender.id == currentVendorId;
                                final otherPersonId = isSender ? conversation.receiver.id : conversation.sender.id;
                                if (otherPersonId == userId) {
                                  conversationId = conversation.id;
                                  break;
                                }
                              }

                              if (conversationId == 0) {
                                final created = await authProvider.sendMessage(
                                  senderId: currentVendorId,
                                  receiverId: userId,
                                  messageText: 'Hi',
                                );

                                if (!created) {
                                  if (mounted) AppMessage.show(context, authProvider.message ?? 'Could not create conversation');
                                  return;
                                }

                                await authProvider.fetchInboxMessages(currentVendorId);
                                for (var conversation in authProvider.inboxMessages) {
                                  final isSender = conversation.sender.id == currentVendorId;
                                  final otherPersonId = isSender ? conversation.receiver.id : conversation.sender.id;
                                  if (otherPersonId == userId) {
                                    conversationId = conversation.id;
                                    break;
                                  }
                                }
                              }

                              if (!mounted) return;

                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    name: clientName,
                                    image: userImage,
                                    conversationId: conversationId,
                                    receiverId: userId,
                                    senderId: currentVendorId,
                                  ),
                                ),
                              );
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
                                action: "completed",
                              );

                              if (result) {
                                // ignore: unawaited_futures
                                AppMessage.show(context, "Booking marked as completed");

                                // Refresh bookings
                                final user = await TokenStorage.getUserData();
                                if (user?.id != null) {
                                  provider.fetchActiveBookings(user!.id!);
                                }
                              } else {
                                // ignore: unawaited_futures
                                AppMessage.show(context, provider.message ?? "Failed");
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
                  ] else ...[
                    // Show message when booking is already completed
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "This booking is already completed",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

              /// Step Progress (dynamic)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  (() {
                    final s = status.toLowerCase();
                    final startDone = s != 'pending';
                    return _stepItem('Start', startDone);
                  })(),
                  (() {
                    final s = status.toLowerCase();
                    final step3Done = s == 'completed' || s == 'cancelled' || s == 'reject' || s == 'rejected';
                    final inProgressActive = s == 'in progress' || s == 'confirmed' || s == 'in_progress' || s == 'accepted' || step3Done;
                    return _stepItem('In progress', inProgressActive);
                  })(),
                  (() {
                    final s = status.toLowerCase();
                    final step3Done = s == 'completed' || s == 'cancelled' || s == 'reject' || s == 'rejected';
                    return _stepItem('Step 3', step3Done);
                  })(),
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
                        Flexible(
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/calendar.png',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  date,
                                  style: const TextStyle(color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/location.png',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  location,
                                  style: const TextStyle(color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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

              // Only show action buttons if status is not completed or cancelled
              if (status.toLowerCase() != 'completed' && status.toLowerCase() != 'cancelled' && status.toLowerCase() != 'reject') ...[ 
                /// Cancel Button
                OutlinedButton(
                  onPressed: () async {
                    final provider = context.read<AuthProvider>();

                    Navigator.pop(context);

                    final result = await provider.updateBookingStatus(
                      bookingId: bookingId,
                      action: "reject",
                    );

                    if (result) {
                      // ignore: unawaited_futures
                      AppMessage.show(context, "Booking cancelled");

                      // Refresh bookings
                      final user = await TokenStorage.getUserData();
                      if (user?.id != null) {
                        provider.fetchActiveBookings(user!.id!);
                      }
                    } else {
                      // ignore: unawaited_futures
                      AppMessage.show(context, provider.message ?? "Failed");
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Cancel"),
                ),

                const SizedBox(height: 15),

                /// Final Complete Button
                ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<AuthProvider>();

                    Navigator.pop(context);

                    final result = await provider.updateBookingStatus(
                      bookingId: bookingId,
                      action: "completed",
                    );

                    if (result) {
                      // ignore: unawaited_futures
                      AppMessage.show(context, "Booking marked as completed");

                      // Refresh bookings
                      final user = await TokenStorage.getUserData();
                      if (user?.id != null) {
                        provider.fetchActiveBookings(user!.id!);
                      }
                    } else {
                      // ignore: unawaited_futures
                      AppMessage.show(context, provider.message ?? "Failed");
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
              ] else ...[
                // Show message when booking is already completed
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "This booking is already completed",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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

