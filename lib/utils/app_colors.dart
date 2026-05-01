import 'package:flutter/material.dart';

/// App color palette — mirrors the React Design
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color accent  = Color(0xFF06B6D4);
  static const Color cyan    = Color(0xFF0891B2);

  // Light theme surfaces
  static const Color lightBg      = Color(0xFFF8FAFC);
  static const Color lightCard    = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFEFF6FF);

  // Dark theme surfaces
  static const Color darkBg    = Color(0xFF0F172A);
  static const Color darkCard  = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  // Status colors
  static const Color statusLow    = Color(0xFFF59E0B);  // amber
  static const Color statusNormal = Color(0xFF10B981);  // green
  static const Color statusHigh   = Color(0xFFEF4444);  // red

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
    stops: [0.0, 1.0],
  );
}
