import 'package:flutter/material.dart';

// 1. Definisikan Palet Warna
class AppColors {
  static const Color primary = Color(0xFF2B2D42); // Navy gelap yang elegan
  static const Color secondary = Color(0xFF8D99AE); // Abu-abu kebiruan
  static const Color background = Color(0xFFF8F9FA); // Putih tulang / Off-white
  static const Color surface = Colors.white; // Putih murni untuk Card/Container
  static const Color textPrimary = Color(0xFF212529); // Hitam pekat untuk teks
  static const Color textSecondary = Color(0xFF6C757D); // Abu-abu untuk sub-teks
  static const Color accent = Color(0xFFD90429); // Aksen merah untuk notif/highlight
}

// 2. Definisikan Tema Aplikasi Utama
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      fontFamily: 'Inter', // Pastikan tambahkan font Inter di pubspec.yaml nanti, atau hapus baris ini untuk font default
      
      // Tema App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0, // Flat design
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Tema Tombol Utama (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Ujung tombol agak membulat
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}