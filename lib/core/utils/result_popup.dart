import 'package:flutter/material.dart';
import 'package:vendor_app/core/utils/app_theme.dart';

/// Reusable success / error popup matching the login-screen style.
/// Auto-dismisses after [duration] and returns immediately.
class ResultPopup {
  static Future<void> show(
    BuildContext context, {
    required bool success,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) async {
    if (!context.mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ResultPopup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, a1, a2) {
        Future.delayed(duration, () {
          try {
            if (ctx.mounted) Navigator.of(ctx).pop();
          } catch (_) {}
        });
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: success
                          ? AppTheme.primaryPink.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      success ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: success ? AppTheme.primaryPink : Colors.red,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    success ? 'Success!' : 'Error',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF5C5C5C),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
