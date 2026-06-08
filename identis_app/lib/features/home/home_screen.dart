import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "IDENTIS",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2.0),
        ),
        centerTitle: false, // Judul rata kiri agar lebih modern
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GREETING ---
            const Text(
              "Halo, Fashionista!",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              "Siap tampil memukau hari ini?",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // --- KARTU REKOMENDASI AI (HERO SECTION) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Colors.blueGrey.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.yellow.shade300, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "AI Pick for You",
                        style: TextStyle(
                          color: Colors.yellow.shade300,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Smart Casual Vibe",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Outfit yang disesuaikan dengan profil kepribadian MBTI dan undertone kulitmu.",
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Lihat Detail Outfit"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- SECTION: COCOK UNTUK BENTUK TUBUHMU ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tambahkan Expanded di sini agar teks judul otomatis menyempit 
                // jika kepanjangan, sehingga tombol "Lihat Semua" tetap aman di kanan
                const Expanded(
                  child: Text(
                    "Cocok Untuk Bentuk Tubuhmu",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis, // Menambahkan "..." jika teks benar-benar tidak muat
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Memberi sedikit jarak antar teks dan tombol
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Lihat Semua", 
                    style: TextStyle(color: AppColors.primary),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal List untuk Baju Dummy
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dummy Icon Baju (Nanti bisa diganti gambar lokal)
                        Icon(Icons.checkroom, size: 64, color: AppColors.secondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          "Atasan ${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Akurasi: 98%",
                          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}