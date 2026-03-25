import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF518C52);
  static const Color primaryLight = Color(0xFF76B377);
  static const Color primaryDark = Color(0xFF386339);

  // Accent colors
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF60A5FA);
  static const Color accentDark = Color(0xFF2563EB);

  // Background colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color backgroundDark = Color(0xFF313338);
  static const Color surfaceDark = Color(0xFF1E1F22);

  // Feedback colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Colors.white;

  // UI elements
  static const Color border = Color(0xFFE2E8F0);
  static const Color inputFill = Colors.white;
  static const Color borderDark = Color(0xFF2B2D31);
  static const Color inputFillDark = Color(0xFF1E1F22);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFFF1F5F9)],
  );

  // Glow effects
  static List<BoxShadow> glow = [
    BoxShadow(
      color: accent.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
}
