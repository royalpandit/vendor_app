import 'package:flutter/material.dart';
import 'package:vendor_app/core/utils/app_icons.dart';

class HelpAndSupportScreen extends StatelessWidget {
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
                  'Help and Support',
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

          // Support Options
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 0.50,
                    color: Colors.black.withOpacity(0.04),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSupportOption(
                    context: context,
                    iconPath: AppIcons.callIcon,
                    title: 'Contact Customer Support',
                    onTap: () {
                      // Handle tap for Customer Support
                    },
                    hasBorder: true,
                  ),
                  _buildSupportOption(
                    context: context,
                    iconPath: AppIcons.whatsuppIcon,
                    title: 'WhatsApp Support',
                    onTap: () {
                      // Handle tap for WhatsApp Support
                    },
                    hasBorder: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption({
    required BuildContext context,
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    required bool hasBorder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: hasBorder
              ? const Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              child: Image.asset(
                AppIcons.forwardIcon,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
