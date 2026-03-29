import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Normal Material 3 Theme
  static ThemeData get normalTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    );
  }

  /// High-Contrast Panic Theme (WCAG AAA)
  static ThemeData get panicTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      
      // High-Contrast Primary Colors (Yellow / Black / White)
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFFFEB3B), // Bright Yellow
        onPrimary: Colors.black,
        secondary: Colors.white,
        onSecondary: Colors.black,
        error: Color(0xFFFF5252),
        onError: Colors.white,
        surface: Colors.black,
        onSurface: Colors.white,
      ),

      // Large, Bold Typography for visibility
      textTheme: GoogleFonts.oswaldTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFFFEB3B)),
          headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      // Massive Tap Targets for Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEB3B),
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 96), // 96px minimum target
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),

      // High-Contrast Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Color(0xFFFFEB3B),
        unselectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
