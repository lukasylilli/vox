// FILE: lib/core/constants/app_colors.dart
// PURPOSE: Global color palette for VOX
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF7C4DFF);
  static const primaryDark = Color(0xFF5E35B1);
  static const secondary = Color(0xFF00BCD4);

  // Dark backgrounds
  static const bgDark = Color(0xFF0A0A0F);
  static const surfaceDark = Color(0xFF13131A);
  static const surfaceVariantDark = Color(0xFF1E1E2A);
  static const cardDark = Color(0xFF1A1A24);

  // Light backgrounds
  static const bgLight = Color(0xFFF5F5FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFF0F0F8);

  // Text
  static const textPrimary = Color(0xFFEEEEFF);
  static const textSecondary = Color(0xFF9999BB);
  static const textMuted = Color(0xFF666688);

  // Status
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFFF5252);
  static const warning = Color(0xFFFFB300);

  // Home grid section colors
  static const wortschatz    = Color(0xFF1565C0); // blue
  static const grammatik     = Color(0xFF6A1B9A); // purple
  static const lesen         = Color(0xFF00695C); // teal
  static const hoeren        = Color(0xFFBF360C); // deep orange
  static const sprechen      = Color(0xFF2E7D32); // green
  static const schreiben     = Color(0xFFC62828); // red
  static const auswendig     = Color(0xFF283593); // indigo
  static const pruefungen    = Color(0xFF4E342E); // brown
  static const selbstlernen  = Color(0xFF37474F); // blue-grey
  static const fragen        = Color(0xFFE65100); // orange
  static const sozialmedien  = Color(0xFFAD1457); // pink
  static const more          = Color(0xFF424242); // grey
}
