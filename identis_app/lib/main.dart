import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/auth_provider.dart';
import 'features/wardrobe/wardrobe_provider.dart';
import 'core/theme.dart';
import 'features/onboarding/onboarding_screen.dart';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'features/setup/personality_setup_screen.dart';
import 'features/home/main_navigation_screen.dart';
import 'features/catalog/catalog_provider.dart';
import 'features/home/home_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Wajib untuk Firebase
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()), // Tambahkan CatalogProvider di sini
        ChangeNotifierProvider(create: (_) => HomeProvider()), // Tambahkan HomeProvider di sini
        // Nanti provider lain (seperti WardrobeProvider) ditambahkan di sini
      ],
      child: const IdentisApp(),
    ),
  );
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
      home: const AuthWrapper(), // Widget ini akan menentukan apakah user harus ke Onboarding, Setup, atau langsung ke Home
    );
  }
}

// --- WIDGET PENENTU ALUR SCREEN (GATEKEEPER) ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    // StreamBuilder mendeteksi secara real-time apakah user ada session login atau tidak
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        // Jika Firebase sedang loading mengecek sesi
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        // KONDISI 1: User belum login sama sekali
        if (!snapshot.hasData || snapshot.data == null) {
          return const OnboardingScreen();
        }

        // KONDISI 2: User sudah login, sekarang cek status setup di Firestore
        return FutureBuilder<bool>(
          future: Provider.of<AuthProvider>(context, listen: false).checkSetupStatus(),
          builder: (context, futureSnapshot) {
            // Sembari menunggu data status setup ditarik dari Firestore
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            // Jika isSetupComplete bernilai true, langsung bypass ke Beranda Utama
            if (futureSnapshot.data == true) {
              return const MainNavigationScreen();
            }

            // Jika isSetupComplete bernilai false, paksa isi setup kepribadian dulu
            return const PersonalitySetupScreen();
          },
        );
      },
    );
  }
}