import 'package:flutter/material.dart';

class ResponsiveUtil {
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Screen size categories
  static bool isMobile(BuildContext context) {
    return width(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return width(context) >= 600 && width(context) < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return width(context) >= 1200;
  }

  // Responsive font sizes
  static double sp(BuildContext context, double size) {
    double baseWidth = 375.0; // iPhone design width
    return size * (width(context) / baseWidth);
  }

  // Responsive width
  static double wp(BuildContext context, double percentage) {
    return width(context) * (percentage / 100);
  }

  // Responsive height
  static double hp(BuildContext context, double percentage) {
    return height(context) * (percentage / 100);
  }

  // Responsive padding
  static EdgeInsets padding(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(wp(context, all));
    }
    return EdgeInsets.only(
      left: left != null ? wp(context, left) : (horizontal != null ? wp(context, horizontal) : 0),
      right: right != null ? wp(context, right) : (horizontal != null ? wp(context, horizontal) : 0),
      top: top != null ? hp(context, top) : (vertical != null ? hp(context, vertical) : 0),
      bottom: bottom != null ? hp(context, bottom) : (vertical != null ? hp(context, vertical) : 0),
    );
  }

  // Safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Responsive sized box
  static SizedBox verticalSpace(BuildContext context, double percentage) {
    return SizedBox(height: hp(context, percentage));
  }

  static SizedBox horizontalSpace(BuildContext context, double percentage) {
    return SizedBox(width: wp(context, percentage));
  }

  // Responsive container width (constrained to max width on larger screens)
  static double constrainedWidth(BuildContext context, {double maxWidth = 600}) {
    final screenWidth = width(context);
    return screenWidth > maxWidth ? maxWidth : screenWidth;
  }

  // Responsive grid columns
  static int gridColumns(BuildContext context) {
    if (width(context) < 600) return 2;
    if (width(context) < 900) return 3;
    return 4;
  }
}
