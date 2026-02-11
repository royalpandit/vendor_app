import 'package:flutter/material.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_icons.dart';

class HelpAndSupportScreen extends StatelessWidget {
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
              Navigator.pop(context); // Handle back action
            },
          ),
          title: Text(
            'Help and Support',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ListView(
          children: [
            _buildSupportOption(
              iconPath: AppIcons.callIcon, // Custom WhatsApp icon path
              title: 'Contact Customer Support',
              onTap: () {
                // Handle tap for Customer Support
              },
            ),
            _buildSupportOption(
              iconPath: AppIcons.whatsuppIcon, // Custom WhatsApp icon path
              title: 'WhatsApp Support',
              onTap: () {
                // Handle tap for WhatsApp Support
              },
            ),
          ],
        ),
      ),
    );
  }

  // Method to build each support option
  Widget _buildSupportOption({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.7,
        margin: EdgeInsets.symmetric(vertical: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: AppColors.whiteColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.asset(
                iconPath, // Custom icon path
                width: 30,
                height: 30,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
