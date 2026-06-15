import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'home_provider.dart';
import '../wardrobe/wardrobe_provider.dart';
import '../catalog/catalog_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();

  // State untuk Mesin Slot & Tampilan Gambar
  bool _isAnimating = false;
  Timer? _shuffleTimer;
  
  String? displayedTopi;
  String? displayedOuter;
  String? displayedInner;
  String? displayedCelana;
  String? displayedSepatu;

  // Fungsi untuk mengekstrak path gambar berdasarkan kategori untuk keperluan animasi
  List<String> _getAvailablePaths(List<Map<String, dynamic>> wardrobe, List<Map<String, dynamic>> catalog, List<String> targetCategories) {
    List<String> paths = [];
    for (var item in wardrobe) {
      if (targetCategories.any((cat) => (item['type'] ?? '').toString().toLowerCase().contains(cat.toLowerCase()))) {
        if (item['localImagePath'] != null) paths.add(item['localImagePath']);
      }
    }
    for (var item in catalog) {
      if (targetCategories.any((cat) => (item['category'] ?? '').toString().toLowerCase().contains(cat.toLowerCase()))) {
        if (item['imageUrl'] != null) paths.add(item['imageUrl']);
      }
    }
    return paths;
  }

  Future<void> _triggerAI() async {
    FocusScope.of(context).unfocus();
    if (_promptController.text.isEmpty) return;

    final wardrobeData = context.read<WardrobeProvider>().clothes;
    final catalogData = context.read<CatalogProvider>().partnerProducts;

    // Kumpulkan semua path gambar untuk diacak di mesin slot
    final allTopi = _getAvailablePaths(wardrobeData, catalogData, ['Topi', 'Aksesoris', 'Kupluk', 'Beanie']);
    final allOuter = _getAvailablePaths(wardrobeData, catalogData, ['Outer', 'Jaket', 'Blazer']);
    final allInner = _getAvailablePaths(wardrobeData, catalogData, ['Inner', 'Atasan', 'Kaos', 'Kemeja']);
    final allCelana = _getAvailablePaths(wardrobeData, catalogData, ['Bawahan', 'Celana', 'Rok']);
    final allSepatu = _getAvailablePaths(wardrobeData, catalogData, ['Sepatu', 'Sneakers']);

    setState(() {
      _isAnimating = true;
    });

    // 1. Mulai Animasi Mesin Slot
    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (allTopi.isNotEmpty) displayedTopi = allTopi[Random().nextInt(allTopi.length)];
        if (allOuter.isNotEmpty) displayedOuter = allOuter[Random().nextInt(allOuter.length)];
        if (allInner.isNotEmpty) displayedInner = allInner[Random().nextInt(allInner.length)];
        if (allCelana.isNotEmpty) displayedCelana = allCelana[Random().nextInt(allCelana.length)];
        if (allSepatu.isNotEmpty) displayedSepatu = allSepatu[Random().nextInt(allSepatu.length)];
      });
    });

    try {
      // 2. Panggil AI & Paksa minimal 2 detik animasi berjalan
      await Future.wait([
        context.read<HomeProvider>().generateOutfit(_promptController.text, wardrobeData, catalogData),
        Future.delayed(const Duration(seconds: 2)),
      ]);

      // 3. Ambil Hasil
      final outfit = context.read<HomeProvider>().currentOutfit;

      setState(() {
        displayedTopi = (outfit['topi'] == "null" || outfit['topi'] == null) ? null : outfit['topi'];
        displayedOuter = (outfit['outer'] == "null" || outfit['outer'] == null) ? null : outfit['outer'];
        displayedInner = (outfit['inner'] == "null" || outfit['inner'] == null) ? null : outfit['inner'];
        displayedCelana = (outfit['celana'] == "null" || outfit['celana'] == null) ? null : outfit['celana'];
        displayedSepatu = (outfit['sepatu'] == "null" || outfit['sepatu'] == null) ? null : outfit['sepatu'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      _shuffleTimer?.cancel();
      setState(() {
        _isAnimating = false;
      });
    }
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final outfit = homeProvider.currentOutfit;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER IDENTIS ---
                const Text(
                  "IDENTIS",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 2.0, color: AppColors.primary),
                ),
                const SizedBox(height: 24),

                // --- INPUT PROMPT & TOMBOL (Dikembalikan ke atas) ---
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _promptController,
                        decoration: InputDecoration(
                          hintText: "Contoh: Baju kasual buat ngampus...",
                          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          prefixIcon: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (_) => _triggerAI(),
                      ),
                      const Divider(height: 1),
                      InkWell(
                        onTap: _isAnimating ? null : _triggerAI,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                          ),
                          child: Center(
                            child: _isAnimating
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Generate Mix & Match", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- CANVAS MIX & MATCH ---
                Center(
                  child: Container(
                    height: 440,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.1)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 65,
                          child: _buildClothingItem(width: 250, height: 190, label: "Outer", imagePath: displayedOuter),
                        ),
                        Positioned(
                          top: 65,
                          child: _buildClothingItem(width: 120, height: 160, label: "Inner", imagePath: displayedInner),
                        ),
                        Positioned(
                          top: 225,
                          child: _buildClothingItem(width: 100, height: 140, label: "Celana", imagePath: displayedCelana),
                        ),
                        Positioned(
                          top: 10,
                          child: _buildClothingItem(width: 70, height: 70, label: "Topi", imagePath: displayedTopi, isCircle: true),
                        ),
                        Positioned(
                          top: 360,
                          child: _buildClothingItem(width: 80, height: 60, label: "Sepatu", imagePath: displayedSepatu),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- KARTU ANALISIS AI ---
                if (!_isAnimating && outfit.containsKey('analisis') && outfit['analisis'] != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology, color: AppColors.primary, size: 18),
                            SizedBox(width: 8),
                            Text("Analisis Stylist AI", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          outfit['analisis'],
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET BANTUAN YANG CERDAS (Bisa baca File Local HP & Local Asset laptop)
  Widget _buildClothingItem({required double width, required double height, required String label, String? imagePath, bool isCircle = false}) {
    final bool hasImage = imagePath != null && imagePath.isNotEmpty && imagePath != "null";
    
    // Deteksi apakah path-nya dari folder assets di kode Flutter
    final bool isAsset = hasImage && imagePath.startsWith('assets/');

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.15), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: !hasImage
          ? Center(
              child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 1.0)),
            )
          : ClipRRect(
              borderRadius: isCircle ? BorderRadius.circular(width / 2) : BorderRadius.circular(10),
              child: isAsset 
                  ? Image.asset(imagePath, fit: BoxFit.cover) // Render gambar dummy dari laptop
                  : Image.file(File(imagePath), fit: BoxFit.cover), // Render gambar lemari dari memori HP
            ),
    );
  }
}