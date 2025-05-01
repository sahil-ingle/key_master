import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightSecondary,
    surface: AppColors.lightSurface,
    onPrimary: AppColors.lightOnPrimary,
    onSecondary: AppColors.lightOnSecondary,
    onSurface: AppColors.lightOnSurface,
    error: AppColors.lightError,
    onError: AppColors.lightOnError,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    surface: AppColors.darkSurface,
    onPrimary: AppColors.darkOnPrimary,
    onSecondary: AppColors.darkOnSecondary,
    onSurface: AppColors.darkOnSurface,
    error: AppColors.darkError,
    onError: AppColors.darkOnError,
  ),
);
class AppColors {
  // 🌞 Light Theme Colors
  static const lightPrimary       = Color(0xFF64B5F6); // Light Blue 300
  static const lightSecondary     = Color(0xFFAED581); // Light Green 300
  static const lightBackground    = Color(0xFFF9FAFB); // Gray 50
  static const lightSurface       = Color(0xFFFFFFFF); // White
  static const lightOnPrimary     = Color(0xFFFFFFFF); // White text on blue
  static const lightOnSecondary   = Color(0xFF1B5E20); // Dark green text
  static const lightOnBackground  = Color(0xFF111827); // Gray 900
  static const lightOnSurface     = Color(0xFF111827); // Gray 900
  static const lightError         = Color(0xFFEF4444); // Red 500
  static const lightOnError       = Color(0xFFFFFFFF); // White on error

  // 🌙 Dark Theme Colors
  static const darkPrimary        = Color(0xFF0D47A1); // Blue 900
  static const darkSecondary      = Color(0xFF81C784); // Green 300
  static const darkBackground     = Color(0xFF0F172A); // Slate 900
  static const darkSurface        = Color(0xFF1E293B); // Slate 800
  static const darkOnPrimary      = Color(0xFFFFFFFF); // White text on dark primary
  static const darkOnSecondary    = Color(0xFF1B5E20); // Dark green text
  static const darkOnBackground   = Color(0xFFF1F5F9); // Slate 100
  static const darkOnSurface      = Color(0xFFF1F5F9); // Slate 100
  static const darkError          = Color(0xFFF87171); // Red 400
  static const darkOnError        = Color(0xFF000000); // Black text on error
}
