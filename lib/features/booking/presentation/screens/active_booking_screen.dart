import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/core/utils/result_popup.dart';
import 'package:vendor_app/features/chat/presentation/screens/chat_screen.dart';

class ActiveBookingsScreen extends StatefulWidget {
  @override
  _ActiveBookingsScreenState createState() => _ActiveBookingsScreenState();
}

class _ActiveBookingsScreenState extends State<ActiveBookingsScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch active bookings when the screen is loaded
    _searchController = TextEditingController();
    _fetchUserIdAndBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      // silently ignore
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
                          fontSize: 20,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
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
                                controller: _searchController,
                                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
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
                      SizedBox(height: 16),
                      // Booking List
                      Expanded(
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.loading) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (authProvider.activeBookingsModels.isEmpty) {
                              return Center(child: Text('No active bookings available.'));
                            }

                            // Filter confirmed bookings with search
                            final confirmedBookings = authProvider.activeBookingsModels
                                .where((booking) => booking.status.toLowerCase() == 'confirmed')
                                .toList();

                            if (confirmedBookings.isEmpty) {
                              return Center(child: Text('No confirmed bookings available.'));
                            }

                            final filtered = _searchQuery.isEmpty
                                ? confirmedBookings
                                : confirmedBookings.where((booking) {
                                    final name = booking.user.name.toLowerCase();
                                    final service = booking.serviceName.toLowerCase();
                                    return name.contains(_searchQuery) || service.contains(_searchQuery);
                                  }).toList();

                            if (filtered.isEmpty) {
                              return Center(child: Text('No bookings match your search.'));
                            }

                            return ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final booking = filtered[index];
                                return _buildBookingCard(
                                  bookingId: booking.id,
                                  clientName: booking.user.name,
                                  service: booking.serviceName,
                                  budget: booking.budget,
                                  date: booking.eventDate,
                                  location: booking.address,
                                  status: booking.status,
                                  userId: booking.user.id,
                                  userImage: booking.user.image,
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
    required int userId,
    required String userImage,
  }) {
    return GestureDetector(
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
              fontSize: 13,
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
              // Message Button (only when booking still active)
              if (status.toLowerCase() != 'completed' && status.toLowerCase() != 'cancelled')
                GestureDetector(
                  onTap: () async {
                    // Navigate to chat with this user
                    final userData = await TokenStorage.getUserData();
                    final vendorId = userData?.id ?? 0;
                    
                    if (vendorId != 0) {
                      // Fetch inbox to find existing conversation
                      final authProvider = context.read<AuthProvider>();
                      await authProvider.fetchInboxMessages(vendorId);
                      
                      // Try to find existing conversation with this user
                      int conversationId = 0;
                      final inboxMessages = authProvider.inboxMessages;
                      for (var conversation in inboxMessages) {
                        // Check if this conversation involves the user
                        final isSender = conversation.sender.id == vendorId;
                        final otherPersonId = isSender ? conversation.receiver.id : conversation.sender.id;
                        if (otherPersonId == userId) {
                          conversationId = conversation.id;
                          break;
                        }
                      }
                      
                      Navigator.push(
                        context,
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
                    }
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
              // Mark as Complete Button - Only show if not completed or cancelled
              if (status.toLowerCase() != 'completed' && status.toLowerCase() != 'cancelled' && status.toLowerCase() != 'reject')
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
                        Flexible(
                          child: Text(
                            'Mark as Complete',
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
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4678).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4678), size: 36),
                              ),
                              const SizedBox(height: 18),
                              const Text('Cancel Booking?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Onest', color: Color(0xFF1E1E2D))),
                              const SizedBox(height: 8),
                              const Text('Are you sure you want to cancel this booking?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontFamily: 'Onest', color: Color(0xFF746E85))),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF1E1E2D),
                                        side: const BorderSide(color: Color(0xFFDBE2EA)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('No', style: TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF4678),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: const Text('Yes', style: TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.w600)),
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

                    final provider = context.read<AuthProvider>();

                    Navigator.pop(context);

                    final result = await provider.updateBookingStatus(
                      bookingId: bookingId,
                      action: "reject",
                    );

                    if (result) {
                      // ignore: unawaited_futures
                      ResultPopup.show(context, success: true, message: "Booking cancelled");

                      final user = await TokenStorage.getUserData();
                      if (user?.id != null) {
                        provider.fetchActiveBookings(user!.id!);
                      }
                    } else {
                      // ignore: unawaited_futures
                      ResultPopup.show(context, success: false, message: provider.message ?? "Failed");
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

                /// Confirm Complete
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
                    ResultPopup.show(context, success: true, message: "Booking marked as completed");

                    final user = await TokenStorage.getUserData();
                    if (user?.id != null) {
                      provider.fetchActiveBookings(user!.id!);
                    }
                  } else {
                    // ignore: unawaited_futures
                    ResultPopup.show(context, success: false, message: provider.message ?? "Failed");
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
              const SizedBox(height: 20),
            ],
          ],
        ),
      );
      },
    );
  }

}
