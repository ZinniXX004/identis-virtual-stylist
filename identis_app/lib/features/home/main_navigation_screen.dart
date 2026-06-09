import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import '../catalog/catalog_screen.dart';
import '../wardrobe/wardrobe_screen.dart';
import '../profile/profile_screen.dart';
import '../camera/ai_camera_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(), // 0: Beranda (Mixer)
    const WardrobeScreen(), // 1: Lemari
    const CatalogScreen(), // 2: Katalog
    const ProfileScreen(), // 3: Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_currentIndex],
      
      // --- TOMBOL KAMERA MELAYANG ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiCameraScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // --- BOTTOM NAVIGATION BAR DENGAN LUBANG TENGAH ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sisi Kiri
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => setState(() => _currentIndex = 0),
                    child: Icon(Icons.home_filled, color: _currentIndex == 0 ? AppColors.primary : AppColors.secondary),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: Icon(Icons.checkroom, color: _currentIndex == 1 ? AppColors.primary : AppColors.secondary),
                  ),
                ],
              ),
              // Sisi Kanan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => setState(() => _currentIndex = 2),
                    child: Icon(Icons.storefront, color: _currentIndex == 2 ? AppColors.primary : AppColors.secondary),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => setState(() => _currentIndex = 3),
                    child: Icon(Icons.person, color: _currentIndex == 3 ? AppColors.primary : AppColors.secondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}