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

    // Fetch the messages after getting the userId
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.lightPinkColor,
                  Colors.white,
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
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 10),
                  // Search bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for Chats',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Tabs for "All" and "Unread"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentTab = 'All';
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'All',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentTab == 'All' ? AppColors.pinkColor : Colors.grey,
                              ),
                            ),
                            if (currentTab == 'All')
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                height: 2,
                                width: 40,
                                color: AppColors.pinkColor,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentTab = 'Unread';
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'Unread',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentTab == 'Unread' ? AppColors.pinkColor : Colors.grey,
                              ),
                            ),
                            if (currentTab == 'Unread')
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                height: 2,
                                width: 60,
                                color: AppColors.pinkColor,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Show progress while loading
            : ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data = messages[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  // Navigate to ChatScreen when tapping on a message
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
                child: Card(
                  elevation: 0.7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: AppColors.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile image
                        CircleAvatar(
                          backgroundImage: NetworkImage(data.receiver!.image),
                          radius: 30,
                        ),
                        SizedBox(width: 15),
                        // Message content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row for name and time
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data.receiver!.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    //data.time,
                                    data.receiver!.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              // Message
                              Text(
                                data.lastMessage!.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: 2),
    );
  }
}

/*
class InboxScreen extends StatefulWidget {
  final int currentIndex;
  InboxScreen({required this.currentIndex});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // List of sample messages for the inbox
  final List<Map<String, String>> messages = [
    {
      'name': 'Culinary Delights Co.',
      'message': 'Absolutely! Talk soon.',
      'time': '9:15 AM',
      'image': AppIcons.profileWhiteIcon, // Add path to your assets
    },
    {
      'name': 'JW Marriott Juhu',
      'message': 'Alright book the venue then an...',
      'time': '10:30 AM',
      'image': AppIcons.profileWhiteIcon, // Add path to your assets
    },
    {
      'name': 'Luxe Beauty Bar',
      'message': 'Provide me the pricing for both...',
      'time': '11:45 AM',
      'image':AppIcons.profileWhiteIcon, // Add path to your assets
    },
  ];

  // Current tab for All/Unread
  String currentTab = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160.0),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 10),
                  // Search bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for Chats',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Tabs for "All" and "Unread"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentTab = 'All';
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'All',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentTab == 'All' ? AppColors.pinkColor : Colors.grey,
                              ),
                            ),
                            if (currentTab == 'All')
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                height: 2,
                                width: 40,
                                color: AppColors.pinkColor,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentTab = 'Unread';
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'Unread',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentTab == 'Unread' ? AppColors.pinkColor : Colors.grey,
                              ),
                            ),
                            if (currentTab == 'Unread')
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                height: 2,
                                width: 60,
                                color: AppColors.pinkColor,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  // Navigate to ChatScreen when tapping on a message
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        name: message['name']!,
                        image: message['image']!,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 0.7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: AppColors.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile image
                        CircleAvatar(
                          backgroundImage: AssetImage(message['image']!),
                          radius: 30,
                        ),
                        SizedBox(width: 15),
                        // Message content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row for name and time
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    message['name']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    message['time']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              // Message
                              Text(
                                message['message']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      */
/*body: Container(
        color: Colors.white, // Ensuring the body is white and separated from the app bar
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 0.7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: AppColors.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile image
                      CircleAvatar(
                        backgroundImage: AssetImage(message['image']!),
                        radius: 30,
                      ),
                      SizedBox(width: 15),
                      // Message content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row for name and time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  message['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  message['time']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            // Message
                            Text(
                              message['message']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
      ),*//*

      bottomNavigationBar: CustomBottomNavigation(currentIndex: 2),
    );
  }
}
*/
