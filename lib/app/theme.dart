/// File: theme.dart
/// Fungsi: Mendefinisikan tema visual aplikasi termasuk warna, font, dan styling.
/// Menyediakan theme light dan dark mode dengan konsistensi desain di seluruh aplikasi.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: const Color(0xFF4FABF5),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4FABF5),
      secondary: Color(0xFF6C63FF),
      tertiary: Color(0xFFFF9F1C),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF4FABF5),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: const Color(0xFF4FABF5),
    scaffoldBackgroundColor: const Color(0xFF0A0E21),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4FABF5),
      secondary: Color(0xFF6C63FF),
      tertiary: Color(0xFFFF9F1C),
      surface: Color(0xFF1E1E2D),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E2D),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  );
}