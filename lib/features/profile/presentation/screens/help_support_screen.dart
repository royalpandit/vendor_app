import 'package:flutter/material.dart';
import 'package:vendor_app/core/utils/app_icons.dart';

class HelpAndSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Help and Support',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1a1a1a),
                    fontSize: 17,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w600,
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
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    color: const Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1a1a1a),
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w500,
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
                color: const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
