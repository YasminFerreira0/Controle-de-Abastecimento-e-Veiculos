import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.greenPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.greenSecondary,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      background: AppColors.backgroundLight,
      onBackground: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),

    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.greenPrimary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.greenPrimary,
      size: 26,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.greenPrimary,
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: AppColors.greenPrimary,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
