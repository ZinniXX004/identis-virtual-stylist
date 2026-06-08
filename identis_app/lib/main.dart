import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  runApp(const IdentisApp());
}

class IdentisApp extends StatelessWidget {
  const IdentisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDENTIS',
      debugShowCheckedModeBanner: false, // Menghilangkan tulisan "DEBUG"
      theme: AppTheme.lightTheme, // Memanggil tema warna navy yang sudah kita buat
      
      // Ini adalah pintu masuk utama aplikasi Anda
      home: const OnboardingScreen(), 
    );
  }
}