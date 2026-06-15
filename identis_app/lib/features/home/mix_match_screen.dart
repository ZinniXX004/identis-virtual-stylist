import 'package:flutter/material.dart';
import '../../core/theme.dart';

class MixMatchScreen extends StatefulWidget {
  const MixMatchScreen({super.key});

  @override
  State<MixMatchScreen> createState() => _MixMatchScreenState();
}

class _MixMatchScreenState extends State<MixMatchScreen> {
  // State untuk menyimpan pilihan item
  String? selectedTopi;
  String? selectedOuter;
  String? selectedInner;
  String? selectedCelana;
  String? selectedSepatu;

  String activeTab = 'Inner';
  final List<String> tabs = ['Topi', 'Outer', 'Inner', 'Bawahan', 'Sepatu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mix & Match AI", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- THE CANVAS (Bagian Atas - Tema Minimalis) ---
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: AppColors.background, // Sesuai tema off-white
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 1. OUTER (Paling Belakang, Paling Lebar)
                  Positioned(
                    top: 80,
                    child: _buildClothingItem(
                      width: 240, 
                      height: 260, 
                      label: "Outer", 
                      imagePath: selectedOuter,
                    ),
                  ),

                  // 2. INNER (Tengah, Menimpa Outer)
                  Positioned(
                    top: 100,
                    child: _buildClothingItem(
                      width: 130, 
                      height: 220, 
                      label: "Inner", 
                      imagePath: selectedInner,
                    ),
                  ),

                  // 3. CELANA (Di Bawah Inner)
                  Positioned(
                    top: 320,
                    child: _buildClothingItem(
                      width: 130, 
                      height: 200, 
                      label: "Celana", 
                      imagePath: selectedCelana,
                    ),
                  ),

                  // 4. TOPI (Di Atas Inner)
                  Positioned(
                    top: 0,
                    child: _buildClothingItem(
                      width: 90, 
                      height: 90, 
                      label: "Topi", 
                      imagePath: selectedTopi,
                    ),
                  ),

                  // 5. SEPATU (Di Bawah Celana)
                  Positioned(
                    top: 520,
                    child: _buildClothingItem(
                      width: 100, 
                      height: 80, 
                      label: "Sepatu", 
                      imagePath: selectedSepatu,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- COMMAND CENTER (Panel Bawah) ---
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Handle Bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tab Kategori
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tabs.length,
                      itemBuilder: (context, index) {
                        final tab = tabs[index];
                        final isSelected = activeTab == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(tab, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.background,
                            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.secondary.withOpacity(0.2)),
                            onSelected: (selected) {
                              setState(() => activeTab = tab);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: AppColors.secondary.withOpacity(0.1)),
                  
                  // Daftar Item (Kosong untuk saat ini)
                  Expanded(
                    child: Center(
                      child: Text(
                        "Daftar item untuk $activeTab akan muncul di sini",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  
                  // Tombol Mix & Match AI
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56, // Tombol sedikit lebih tebal agar nyaman diklik
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.auto_awesome, color: Colors.white),
                        label: const Text("Generate Rekomendasi AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget bantuan untuk menggambar kotak pakaian (Kini dengan gaya clean/minimalis)
  Widget _buildClothingItem({required double width, required double height, required String label, String? imagePath}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface, // Selalu putih
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: imagePath == null
          ? Center(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1.2)))
          : ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(imagePath, fit: BoxFit.cover),
            ),
    );
  }
}