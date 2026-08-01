import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Premium logistics brand colors
  static const Color primary = Color(0xFF09A234); // Green
  static const Color primaryLight = Color(0xFF4ADE80); // Lighter Green
  static const Color primaryDark = Color(0xFF166534); // Darker Green

  static const Color secondary = Color(0xFFFDCB0A); // Yellow
  static const Color secondaryLight = Color(0xFFFDE047); // Lighter Yellow

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC); // Very light grey/blue
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF4444); // Red for error / cancel
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // Shimmer/Loading
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);

  // Gradient definitions for premium look
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [primaryLight, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
