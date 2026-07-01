import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display
  static const TextStyle displayLarge  = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2);
  static const TextStyle displayMedium = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3);

  // Headings (on white bg)
  static const TextStyle h1 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3);
  static const TextStyle h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4);
  static const TextStyle h3 = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4);

  // Body
  static const TextStyle bodyLarge  = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6);
  static const TextStyle bodyMedium = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);
  static const TextStyle bodySmall  = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textHint, height: 1.5);

  // Labels
  static const TextStyle label    = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static const TextStyle labelCap = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: .5);
  static const TextStyle hint     = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textHint);

  // Buttons
  static const TextStyle btnPrimary = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white);
  static const TextStyle btnText    = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary);

  // Special
  static const TextStyle caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textHint);
  static const TextStyle link    = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary, decoration: TextDecoration.underline);
}
