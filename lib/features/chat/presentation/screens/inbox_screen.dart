import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/custom_bottom_navigation.dart';
import 'package:vendor_app/core/utils/skeleton_loader.dart';
import 'package:vendor_app/core/utils/app_message.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
// import 'package:vendor_app/core/utils/app_message.dart';
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
  int userId = 0; // To store user ID

  List<InboxResponse> messages = [];
  String currentTab = 'All';

  @override
  void initState() {
    super.initState();
    // Load once on init and show skeleton until data arrives
    _getUserIdFromStorage();
  }

  // Fetch user ID from TokenStorage
  Future<void> _getUserIdFromStorage() async {
    final userData = await TokenStorage.getUserData();
    final int uid = userData?.id ?? 0;
    setState(() {
      userId = uid;
    });
    final authProvider = context.read<AuthProvider>();

    // Fetch vendor details and dashboard only if not already loaded
    if (authProvider.vendorDetails == null) {
      await authProvider.fetchVendorDetails(userId);
    }
    if (authProvider.dashboardData == null) {
      await authProvider.fetchVendorDashboard(userId);
    }

    // Use cached inbox data if available to avoid showing empty state repeatedly
    if (authProvider.inboxMessages.isNotEmpty) {
      setState(() {
        messages = authProvider.inboxMessages;
        isLoading = false;
      });
    } else {
      await _fetchInboxMessages(authProvider);
    }
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
      // show error via app message
      AppMessage.show(context, 'Failed to fetch inbox messages');
    }
  }

  // Helper function to show messages
  // void _showMsg(String message) {
  //   // ignore: unawaited_futures
  //   AppMessage.show(context, message);
  // }

  @override
  Widget build(BuildContext context) {
    ImageProvider _avatarProvider(String path) {
      const storageBase = 'https://sevenoath.shofus.com/storage/';
      if (path.isEmpty) return const AssetImage('assets/images/placeholder_user.png');
      if (path.startsWith('http')) return NetworkImage(path);
      if (path.startsWith('assets/')) return AssetImage(path);
      return NetworkImage('$storageBase$path');
    }

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
                            fontSize: 26,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
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
                            fontSize: 14,
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
                child: isLoading
                    ? SkeletonLoader.fullScreenInboxSkeleton()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Builder(
                          builder: (context) {
                            // Filter messages based on current tab
                            final filteredMessages = currentTab == 'Unread'
                                ? messages.where((data) {
                                    final hasUnread = data.lastMessage.senderId != userId && data.lastMessage.readAt == null;
                                    return hasUnread;
                                  }).toList()
                                : messages;

                            if (filteredMessages.isEmpty) {
                              return Center(
                                child: Text(
                                  currentTab == 'Unread' ? 'No unread messages' : 'No messages yet',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 12),
                              itemCount: filteredMessages.length,
                              itemBuilder: (context, index) {
                                final data = filteredMessages[index];
                            // Calculate other person details once
                            final bool isSender = data.sender.id == userId;
                            final String otherPersonName = isSender ? data.receiver.name : data.sender.name;
                            final String otherPersonImage = isSender ? data.receiver.image : data.sender.image;
                            final int otherPersonId = isSender ? data.receiver.id : data.sender.id;
                            
                            // Check if there are unread messages (message from other user and not read yet)
                            final bool hasUnreadMessages = data.lastMessage.senderId != userId && data.lastMessage.readAt == null;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () async {
                                  // Only mark as read if there are actually unread messages
                                  if (hasUnreadMessages) {
                                    final prov = Provider.of<AuthProvider>(context, listen: false);
                                    await prov.markMessagesAsRead(
                                      conversationId: data.id,
                                      receiverId: userId,
                                    );
                                  }
                                  
                                  final deleted = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        name: otherPersonName,
                                        image: otherPersonImage,
                                        conversationId: data.id,
                                        receiverId: otherPersonId,
                                        senderId: userId,
                                      ),
                                    ),
                                  );
                                  // Refresh inbox after returning from chat to update read status
                                  if (mounted) {
                                    final prov = Provider.of<AuthProvider>(context, listen: false);
                                    await prov.fetchInboxMessages(userId);
                                  }
                                  if (deleted == true && mounted) {
                                    AppMessage.show(context, 'Conversation deleted');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: ShapeDecoration(
                                    color: hasUnreadMessages ? const Color(0xFFFFF5F7) : const Color(0xFFF9F9F9),
                                    shape: RoundedRectangleBorder(
                                      side: hasUnreadMessages ? BorderSide(width: 1, color: const Color(0xFFFF4678).withOpacity(0.2)) : BorderSide.none,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Profile Image
                                      Container(
                                        width: 56,
                                        height: 56,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          image: DecorationImage(
                                            image: _avatarProvider(otherPersonImage),
                                            fit: BoxFit.cover,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(28),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // Message Content
                                      Expanded(
                                        child: Container(
                                          height: 70,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Name and Time Row
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      otherPersonName,
                                                      style: TextStyle(
                                                        color: const Color(0xFF171719),
                                                        fontSize: 16,
                                                        fontFamily: 'Onest',
                                                        fontWeight: hasUnreadMessages ? FontWeight.w600 : FontWeight.w500,
                                                        height: 1.25,
                                                      ),
                                                    ),
                                                  ),
                                                  // Unread badge
                                                  if (hasUnreadMessages) ...[
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFFF4678),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ] else ...[
                                                    // Time display
                                                    Text(
                                                      'Now', // Placeholder since API doesn't provide timestamp
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
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              // Message Text
                                              Text(
                                                data.lastMessage.message,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: hasUnreadMessages ? Colors.black.withOpacity(0.70) : Colors.black.withOpacity(0.50),
                                                  fontSize: 14,
                                                  fontFamily: 'Onest',
                                                  fontWeight: hasUnreadMessages ? FontWeight.w400 : FontWeight.w300,
                                                  height: 1.43,
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
    );
  }
}
