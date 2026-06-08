import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller untuk input warna/tema
  final TextEditingController _promptController = TextEditingController();
  
  // Status Animasi "Slot Machine"
  bool _isAnimating = false;

  // --- DUMMY DATA ---
  // List Atasan (Gabungan Kaos, Kemeja, dan Dress)
  final List<Map<String, dynamic>> tops = [
    {"name": "Kaos Putih Polos", "icon": Icons.checkroom, "type": "top", "color": Colors.white},
    {"name": "Kemeja Flanel", "icon": Icons.iron, "type": "top", "color": Colors.redAccent},
    {"name": "Hoodie Hitam", "icon": Icons.dry_cleaning, "type": "top", "color": Colors.black87},
    {"name": "Gaun Malam (One-Piece)", "icon": Icons.accessibility_new, "type": "dress", "color": Colors.purple}, // Ini dress
    {"name": "Jaket Denim", "icon": Icons.snowing, "type": "top", "color": Colors.blue},
  ];

  // List Bawahan (Celana, Rok)
  final List<Map<String, dynamic>> bottoms = [
    {"name": "Jeans Biru Klasik", "icon": Icons.airline_seat_legroom_extra, "color": Colors.blue.shade800},
    {"name": "Celana Chino Cream", "icon": Icons.airline_seat_legroom_normal, "color": Colors.brown.shade200},
    {"name": "Rok Hitam Pendek", "icon": Icons.curtains, "color": Colors.black},
    {"name": "Celana Training", "icon": Icons.directions_run, "color": Colors.grey},
  ];

  // Index baju yang sedang tampil
  int currentTopIndex = 0;
  int currentBottomIndex = 0;

  // Logika Cerdas: Cek apakah atasan saat ini adalah dress (terusan)
  bool get isDressSelected => tops[currentTopIndex]["type"] == "dress";

  // Fungsi Animasi Mesin Slot (Acak Cepat)
  void _triggerAIRecommendation() {
    // Tutup keyboard jika terbuka
    FocusScope.of(context).unfocus(); 
    
    setState(() {
      _isAnimating = true;
    });

    int ticks = 0;
    // Mengacak gambar setiap 100 milidetik
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        currentTopIndex = Random().nextInt(tops.length);
        currentBottomIndex = Random().nextInt(bottoms.length);
      });

      ticks++;
      // Berhenti setelah 20 putaran (2 detik)
      if (ticks >= 20) {
        timer.cancel();
        setState(() {
          _isAnimating = false;
          // Di sini Anda bisa men-set ke indeks tertentu jika ingin hasil yang spesifik,
          // Tapi untuk MVP, berhenti di angka acak terakhir sudah terlihat sangat meyakinkan!
        });
      }
    });
  }

  // Fungsi Geser Manual
  void _changeTop(int direction) {
    if (_isAnimating) return;
    setState(() {
      currentTopIndex = (currentTopIndex + direction) % tops.length;
      if (currentTopIndex < 0) currentTopIndex = tops.length - 1;
    });
  }

  void _changeBottom(int direction) {
    if (_isAnimating || isDressSelected) return;
    setState(() {
      currentBottomIndex = (currentBottomIndex + direction) % bottoms.length;
      if (currentBottomIndex < 0) currentBottomIndex = bottoms.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // --- HEADER & INPUT PROMPT ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "IDENTIS",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2.0, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                // Input Prompt Warna/Gaya
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: "Contoh: Baju warna cerah buat nongkrong...",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.auto_awesome, color: AppColors.accent),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: _triggerAIRecommendation,
                      ),
                    ),
                    onSubmitted: (_) => _triggerAIRecommendation(),
                  ),
                ),
              ],
            ),
          ),

          // --- AREA MIXER (KARTU PAKAIAN) ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  // 1. SLIDER ATASAN
                  _buildSliderItem(
                    title: "Atasan",
                    itemData: tops[currentTopIndex],
                    onLeftTap: () => _changeTop(-1),
                    onRightTap: () => _changeTop(1),
                  ),

                  const SizedBox(height: 16),

                  // 2. SLIDER BAWAHAN (Akan memudar jika Dress terpilih)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isDressSelected ? 0.3 : 1.0, // Gelapkan jika dress
                    child: _buildSliderItem(
                      title: "Bawahan",
                      itemData: bottoms[currentBottomIndex],
                      onLeftTap: () => _changeBottom(-1),
                      onRightTap: () => _changeBottom(1),
                      isDisabled: isDressSelected,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- TOMBOL AI GENERATE BESAR ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isAnimating ? null : _triggerAIRecommendation,
                icon: _isAnimating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.shuffle, color: Colors.white),
                label: Text(
                  _isAnimating ? "Mencari Kombinasi..." : "AI Recommend Outfit",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Pembantu untuk membuat Baris Slider Kanan-Kiri
  Widget _buildSliderItem({
    required String title,
    required Map<String, dynamic> itemData,
    required VoidCallback onLeftTap,
    required VoidCallback onRightTap,
    bool isDisabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Panah Kiri
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              color: isDisabled ? Colors.grey : AppColors.primary,
              onPressed: onLeftTap,
            ),

            // Kartu Baju di Tengah (Dengan AnimatedSwitcher agar pergantiannya mulus)
            Expanded(
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: itemData["color"].withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: itemData["color"].withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  // Key penting agar flutter tahu isinya berubah
                  child: Column(
                    key: ValueKey<String>(itemData["name"]), 
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(itemData["icon"], size: 80, color: itemData["color"]),
                      const SizedBox(height: 12),
                      Text(
                        itemData["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      if (isDisabled)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text("(Dinonaktifkan: Pakai Dress)", style: TextStyle(color: Colors.red, fontSize: 12)),
                        )
                    ],
                  ),
                ),
              ),
            ),

            // Panah Kanan
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              color: isDisabled ? Colors.grey : AppColors.primary,
              onPressed: onRightTap,
            ),
          ],
        ),
      ],
    );
  }
}