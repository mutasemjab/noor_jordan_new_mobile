import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF233a77);
  static const Color primaryLight = Color(0xFF2d4d99);
  static const Color accent = Color(0xFFf4ae2d);
  static const Color accentDark = Color(0xFFd4941a);
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFd32f2f);
  static const Color textPrimary = Color(0xFF1a2547);
  static const Color textSecondary = Color(0xFF8898B0);
  static const Color divider = Color(0xFFE8EDF5);

  static const Color present = Color(0xFF4CAF50);
  static const Color absent = Color(0xFFd32f2f);
  static const Color late = Color(0xFFFF9800);
  static const Color excused = Color(0xFF2196F3);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, Color(0xFF1a2d5a)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
