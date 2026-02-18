import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryPink = Color(0xFFFF4678);
  static const Color lightPink = Color(0xFFFFE5E8);
  static const Color darkPink = Color(0xFFE63E68);
  
  // Secondary Colors
  static const Color teal = Color(0xFF14A38B);
  static const Color yellow = Color(0xFFFFAC57);
  static const Color lightYellow = Color(0xFFFFF5E9);
  
  // Status Colors
  static const Color success = Color(0xFF14A38B);
  static const Color warning = Color(0xFFFFAC57);
  static const Color error = Color(0xFFFF7171);
  static const Color info = Color(0xFF7188FF);
  
  // Neutral Colors
  static const Color black = Color(0xFF171719);
  static const Color darkGray = Color(0xFF1D2129);
  static const Color gray = Color(0xFF4E5969);
  static const Color lightGray = Color(0xFF86909C);
  static const Color lighterGray = Color(0xFFC9CDD4);
  static const Color backgroundGray = Color(0xFFF2F3F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF9F9F9);
  
  // TextField Colors
  static const Color inputBorder = Color(0x4CDBE2EA);
  static const Color inputBackground = Color(0xFFFCFCFC);
  static const Color inputTextColor = Color(0xFF171719);
  static const Color hintTextColor = Color(0x4737383C);
  static const Color focusedBorderColor = primaryPink;

  // Font Family
  static const String fontFamily = 'Onest';

  // Text Styles
  static TextStyle heading1 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600, // SemiBold
    color: black,
    height: 1.13,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w500, // Medium
    color: black,
    height: 1.13,
  );

  static TextStyle heading3 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    color: black,
    height: 1.33,
  );

  static TextStyle heading4 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: black,
    height: 1.33,
  );

  static TextStyle heading5 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    color: black,
    height: 1.50,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: black,
    height: 1.50,
  );

  static TextStyle bodyRegular = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: black,
    height: 1.50,
  );

  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: black,
    height: 1.50,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400, // Regular
    color: gray,
    height: 1.50,
  );

  static TextStyle button = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: white,
    height: 1.50,
    letterSpacing: 0.09,
  );

  static TextStyle inputText = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: inputTextColor,
    height: 1.50,
  );

  static TextStyle hintText = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: hintTextColor,
    height: 1.50,
  );

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    primaryColor: primaryPink,
    scaffoldBackgroundColor: white,
    colorScheme: const ColorScheme.light(
      primary: primaryPink,
      secondary: teal,
      error: error,
      surface: white,
      onPrimary: white,
      onSecondary: white,
      onError: white,
      onSurface: black,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: black),
      titleTextStyle: heading3,
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      headlineLarge: heading3,
      headlineMedium: heading4,
      headlineSmall: heading5,
      bodyLarge: bodyLarge,
      bodyMedium: bodyRegular,
      bodySmall: bodySmall,
      labelLarge: button,
      labelMedium: bodyRegular,
      labelSmall: caption,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: inputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: inputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: focusedBorderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      hintStyle: hintText,
      labelStyle: bodyRegular,
      errorStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: error,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPink,
        foregroundColor: white,
        textStyle: button,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPink,
        textStyle: button.copyWith(color: primaryPink),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
