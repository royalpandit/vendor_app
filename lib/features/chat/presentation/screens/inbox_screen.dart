import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/api_result.dart';
import 'package:vendor_app/core/network/base_response.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/core/utils/custom_bottom_navigation.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/chat/data/model/resposen/inbox_response.dart';
import 'package:vendor_app/features/chat/presentation/screens/chat_screen.dart';
class InboxScreen extends StatefulWidget {
  final int currentIndex;
  InboxScreen({required this.currentIndex});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}
class _InboxScreenState extends State<InboxScreen> {
  bool isLoading = false; // To manage the loading state
  late int userId; // To store user ID

  List<InboxResponse> messages = [];
  String currentTab = 'All';

  @override
  void initState() {
    super.initState();
    _getUserIdFromStorage(); // Get the user ID when the screen is initialized
  }

  // Fetch user ID from TokenStorage
  Future<void> _getUserIdFromStorage() async {
    final userData = await TokenStorage.getUserData();
    userId = userData?.id ?? 0;
    final authProvider = context.read<AuthProvider>();

    // Fetch the vendor details, dashboard data and messages after getting the userId
    await authProvider.fetchVendorDetails(userId);
    await authProvider.fetchVendorDashboard(userId);
    await _fetchInboxMessages(authProvider);
  }

  // Fetch Inbox Messages from API
  Future<void> _fetchInboxMessages(AuthProvider authProvider) async {
    setState(() {
      isLoading = true; // Show the loading indicator
    });

    try {
      await authProvider.fetchInboxMessages(userId); // Fetch the messages

      // Update the UI once the data is fetched
      setState(() {
        isLoading = false;
        messages = authProvider.inboxMessages; // Assign messages from provider
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMsg('Failed to fetch inbox messages');
    }
  }

  // Helper function to show messages
  void _showMsg(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    // Welcome Text
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
                    // Subtitle
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
                    // Search Field
                    Container(
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
                          Image.asset(
                            'assets/icons/Icon.png',
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search for Chats',
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    // Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              currentTab = 'All';
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 48,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    'All',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: currentTab == 'All'
                                          ? const Color(0xFFFF4678)
                                          : const Color(0x4737383C),
                                      fontSize: 17,
                                      fontFamily: 'Onest',
                                      fontWeight: currentTab == 'All'
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      height: 1.41,
                                    ),
                                  ),
                                ),
                                if (currentTab == 'All')
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF4678),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              currentTab = 'Unread';
                            });
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    'Unread',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: currentTab == 'Unread'
                                          ? const Color(0xFFFF4678)
                                          : const Color(0x4737383C),
                                      fontSize: 17,
                                      fontFamily: 'Onest',
                                      fontWeight: currentTab == 'Unread'
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      height: 1.41,
                                    ),
                                  ),
                                ),
                                if (currentTab == 'Unread')
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF4678),
                                      ),
                                    ),
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
              // Messages List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final data = messages[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        name: data.sender!.name,
                                        image: data.sender!.image,
                                        conversationId: data.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF9F9F9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Profile Image
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: ShapeDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(data.receiver!.image),
                                            fit: BoxFit.cover,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(35),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // Message Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Name and Time Row
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    data.receiver!.name,
                                                    style: TextStyle(
                                                      color: const Color(0xFF0C141C),
                                                      fontSize: 16,
                                                      fontFamily: 'Onest',
                                                      fontWeight: FontWeight.w500,
                                                      height: 1.50,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  // Format time or use static value
                                                  '9:15 AM',
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    color: const Color(0xFF4C7299),
                                                    fontSize: 14,
                                                    fontFamily: 'Onest',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.71,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            // Message Text
                                            Text(
                                              data.lastMessage!.message,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black.withOpacity(0.50),
                                                fontSize: 14,
                                                fontFamily: 'Onest',
                                                fontWeight: FontWeight.w300,
                                                height: 1.43,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
    );
  }
}
