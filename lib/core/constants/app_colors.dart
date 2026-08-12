import 'package:flutter/material.dart';

/// Centralized color palette for the app.
/// Replace these values once the Stitch design is available —
/// this is the ONLY file that should need editing for a color change.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color secondary = Color(0xFF10B981);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Task status specific
  static const Color pending = Color(0xFFF59E0B);
  static const Color completed = Color(0xFF22C55E);

  // Neutrals - Light theme
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // Neutrals - Dark theme (bonus, prepared in advance)
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color dividerDark = Color(0xFF374151);
}