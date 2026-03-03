import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Yes',
  String cancelText = 'Cancel',
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF1a1a1a), fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Color(0xFF666666), fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCCCCCC)),
                      foregroundColor: const Color(0xFF666666),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4678),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(confirmText),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
