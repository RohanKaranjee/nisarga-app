import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors (Lavender / Pink theme from React prototype)
  static const Color primary = Color(0xFF9B6FB7);
  static const Color primaryLight = Color(0xFFCE93D8);
  static const Color primaryDark =
      Color(0xFF6A1B2E); // Deep maroon from auth screens

  // Backgrounds
  static const Color background = Color(0xFFFDEFF4);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Specific UI elements
  static const Color accentPink = Colors.pink; // e.g. floating action buttons
  static const Color error = Color(0xFFEF4444); // Red for errors/destructive
  static const Color warning = Color(0xFFF59E0B); // Amber for warnings
  static const Color success = Color(0xFF10B981); // Green for success

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark gray
  static const Color textSecondary = Color(0xFF6B7280); // Muted gray
  static const Color textLight = Colors.white;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD81B60), Color(0xFF880E4F)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFF3E5F9), Color(0xFFE1BEE7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
