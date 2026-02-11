import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/profile/data/models/request/notification_settings_request.dart';


class ManageNotificationScreen extends StatefulWidget {
  @override
  _ManageNotificationScreenState createState() =>
      _ManageNotificationScreenState();
}
class _ManageNotificationScreenState extends State<ManageNotificationScreen> {
  bool pushNotifications = true;
  bool newLeads = true;
  bool bookingStatus = true;
  bool messages = true;
  bool paymentUpdates = true;
  bool isLoading = false; // To manage the loading state
  late int userId;

  @override
  void initState() {
    super.initState();
    _getUserIdFromStorage();
  }

  // Fetch user ID from TokenStorage
  Future<void> _getUserIdFromStorage() async {
    final userData = await TokenStorage.getUserData();
    userId = userData?.id ?? 0;

    // Fetch notification settings from the API
    if (userId != 0) {
      setState(() {
        isLoading = true;
      });
      await context.read<AuthProvider>().fetchNotificationSettings(userId);

      // Update the UI with the fetched notification settings
      final notificationSettings = context.read<AuthProvider>().notificationSettings;
      if (notificationSettings != null) {
        setState(() {
          pushNotifications = notificationSettings.pushNotification == 1;
          newLeads = notificationSettings.newLeadsRequest == 1;
          bookingStatus = notificationSettings.bookingStatusUpdate == 1;
          messages = notificationSettings.message == 1;
          paymentUpdates = notificationSettings.paymentUpdates == 1;
        });
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: AppColors.whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black), // Back arrow icon
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 60, left: 50),
            child: Row(
              children: [
                Text(
                  'Manage Notifications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // Push Notifications
            _buildSwitchTile(
              title: 'Push Notifications',
              subtitle: 'Allow instant updates to be sent to your device.',
              value: pushNotifications,
              onChanged: (value) {
                setState(() {
                  pushNotifications = value;
                });
              },
            ),

            // New Leads / Requests
            _buildSwitchTile(
              title: 'New Leads / Requests',
              subtitle: 'Get notified instantly when a new customer inquiry or request arrives.',
              value: newLeads,
              onChanged: (value) {
                setState(() {
                  newLeads = value;
                });
              },
            ),

            // Booking Status Updates
            _buildSwitchTile(
              title: 'Booking Status Updates',
              subtitle: 'Alerts when bookings are confirmed, modified, or canceled.',
              value: bookingStatus,
              onChanged: (value) {
                setState(() {
                  bookingStatus = value;
                });
              },
            ),

            // Messages
            _buildSwitchTile(
              title: 'Messages',
              subtitle: 'Alerts for new chats and replies.',
              value: messages,
              onChanged: (value) {
                setState(() {
                  messages = value;
                });
              },
            ),

            // Payment Updates
            _buildSwitchTile(
              title: 'Payment Updates',
              subtitle: 'Alerts when you receive a payment for a booking or a refund is issued or a booking is canceled.',
              value: paymentUpdates,
              onChanged: (value) {
                setState(() {
                  paymentUpdates = value;
                });
              },
            ),

            // Progress Indicator
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(),
              ),

            // Save Changes Button (Full width at the bottom)
            Spacer(),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: AppColors.whiteColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Switch Tile for each notification setting
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.pink,
      ),
    );
  }

  // Save changes by calling API
  Future<void> _saveChanges() async {
    if (userId == null) {
      _showMsg('User not found!');
      return;
    }

    setState(() {
      isLoading = true; // Show the progress bar
    });

    final request = NotificationSettingsRequest(
      userId: userId, // Convert the userId to int
      bookingStatusUpdate: bookingStatus ? 1 : 0,
      pushNotification: pushNotifications ? 1 : 0,
      newLeadsRequest: newLeads ? 1 : 0,
      message: messages ? 1 : 0,
      paymentUpdates: paymentUpdates ? 1 : 0,
    );

    try {
      await context.read<AuthProvider>().updateNotificationSettings(request);
      setState(() {
        isLoading = false; // Hide the progress bar
      });
      _showMsg('Notification settings updated successfully');
    } catch (e) {
      setState(() {
        isLoading = false; // Hide the progress bar
      });
      _showMsg('Failed to update notification settings');
    }
  }

  // Helper function to show messages
  void _showMsg(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
