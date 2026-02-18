import 'package:flutter/material.dart';
import 'package:vendor_app/core/utils/app_theme.dart';

class AppMessage {
  static Future<void> show(BuildContext context, String message, {Duration duration = const Duration(seconds: 1)}) async {
    if (!context.mounted) return;

    // Capture the dialog's own build context so we pop the dialog route specifically
    BuildContext? dialogContext;

    // Use dialog so it appears above everything and looks consistent
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Message',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, a1, a2) {
        dialogContext = ctx;
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryPink.withOpacity(0.9), width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        try {
                          if (dialogContext != null) Navigator.of(dialogContext!).pop();
                        } catch (_) {}
                      },
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // auto dismiss after the requested duration - ensure we pop the dialog route only
    await Future.delayed(duration);
    try {
      if (dialogContext != null) Navigator.of(dialogContext!).pop();
    } catch (_) {
      // ignore errors - dialog may have been dismissed or navigator changed
    }
  }
}
