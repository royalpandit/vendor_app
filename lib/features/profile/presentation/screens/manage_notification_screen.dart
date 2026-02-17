import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
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
  bool isLoading = false;
  late int userId;

  @override
  void initState() {
    super.initState();
    _getUserIdFromStorage();
  }

  Future<void> _getUserIdFromStorage() async {
    final userData = await TokenStorage.getUserData();
    userId = userData?.id ?? 0;

    if (userId != 0) {
      setState(() {
        isLoading = true;
      });
      await context.read<AuthProvider>().fetchNotificationSettings(userId);

      final notificationSettings =
          context.read<AuthProvider>().notificationSettings;
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
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // Custom App Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 52,
              bottom: 16,
            ),
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 24,
                      height: 24,
                      child: Image.asset(
                        AppIcons.arrowLeft,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Manage Notifications',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w500,
                    height: 1.41,
                  ),
                ),
              ],
            ),
          ),

          // Notification Cards
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(17),
              child: Column(
                spacing: 8,
                children: [
                  _buildNotificationCard(
                    title: 'Push Notifications',
                    subtitle: 'Allow instant updates to be sent to your device.',
                    value: pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        pushNotifications = value;
                      });
                    },
                  ),
                  _buildNotificationCard(
                    title: 'New Leads / Requests',
                    subtitle:
                        'Get notified instantly when a new customer inquiry or request arrives.',
                    value: newLeads,
                    onChanged: (value) {
                      setState(() {
                        newLeads = value;
                      });
                    },
                  ),
                  _buildNotificationCard(
                    title: 'Booking Status Updates',
                    subtitle:
                        'Alerts when bookings are confirmed, modified, or canceled.',
                    value: bookingStatus,
                    onChanged: (value) {
                      setState(() {
                        bookingStatus = value;
                      });
                    },
                  ),
                  _buildNotificationCard(
                    title: 'Messages',
                    subtitle: 'Alerts for new chats and replies.',
                    value: messages,
                    onChanged: (value) {
                      setState(() {
                        messages = value;
                      });
                    },
                  ),
                  _buildNotificationCard(
                    title: 'Payment Updates',
                    subtitle:
                        'Alerts when you receive a payment for a booking or a refund is issued or a booking is canceled.',
                    value: paymentUpdates,
                    onChanged: (value) {
                      setState(() {
                        paymentUpdates = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Save Changes Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Colors.white),
            child: GestureDetector(
              onTap: isLoading ? null : _saveChanges,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: ShapeDecoration(
                  color: const Color(0xFFFF4678),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                          letterSpacing: 0.09,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2B2D42),
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFA7A7A7),
                    fontSize: 12,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w400,
                    height: 1.17,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildCustomToggle(value, onChanged),
        ],
      ),
    );
  }

  Widget _buildCustomToggle(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: ShapeDecoration(
          color: value ? const Color(0xFFFF4678) : const Color(0xFFE0E0E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: CircleBorder(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (userId == 0) {
      _showMsg('User not found!');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final request = NotificationSettingsRequest(
      userId: userId,
      bookingStatusUpdate: bookingStatus ? 1 : 0,
      pushNotification: pushNotifications ? 1 : 0,
      newLeadsRequest: newLeads ? 1 : 0,
      message: messages ? 1 : 0,
      paymentUpdates: paymentUpdates ? 1 : 0,
    );

    try {
      await context.read<AuthProvider>().updateNotificationSettings(request);
      setState(() {
        isLoading = false;
      });
      _showMsg('Notification settings updated successfully');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMsg('Failed to update notification settings');
    }
  }

  void _showMsg(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2B2D42),
      ),
    );
  }
}
