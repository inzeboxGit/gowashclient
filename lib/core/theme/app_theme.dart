import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF143C94),
        secondary: Color(0xFF10916D),
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF101113),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF101113),
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101113),
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.55,
          color: Color(0xFF979BA6),
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.45,
          color: Color(0xFFA6AAB4),
        ),
      ),
    );
  }
}
