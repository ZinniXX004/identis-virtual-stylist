import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AiCameraScreen extends StatefulWidget {
  const AiCameraScreen({super.key});

  @override
  State<AiCameraScreen> createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen> {
  bool _hasTakenPhoto = false; // State untuk mengunci hasil foto
  bool _isScanning = false;
  String _detectedItem = "Arahkan kamera...";
  String _detectedColor = "-";
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    // Simulasi otomatis dihapus agar aplikasi menunggu user menjepret foto
  }

  void _takePhoto() {
    setState(() {
      _hasTakenPhoto = true;
      _isScanning = true;
      _detectedItem = "Memproses gambar...";
    });

    // Detik ke-1.5 setelah jepret: AI mengekstraksi jenis pakaian
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _detectedItem = "Kemeja Flanel";
          _confidence = 0.94;
        });
      }
    });

    // Detik ke-3: AI mendeteksi warna dan verifikasi objek selesai
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _detectedColor = "Merah Kotak-kotak";
          _isScanning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam agar mirip viewfinder kamera asli
      body: Stack(
        children: [
          // 1. SIMULASI VIEWFINDER KAMERA (Menggunakan gambar pakaian asli studio)
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1598033129183-c4f50c736f10?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
              fit: BoxFit.cover,
            ),
          ),

          // 2. GRADASI GELAP DI ATAS & BAWAH KAMERA (Agar UI minimalis terlihat jelas)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // 3. TOMBOL KEMBALI (TOP BAR)
          Positioned(
            top: 44,
            left: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // 4. ANIMASI KOTAK PEMINDAI AI (YOLOv4 Bounding Box Simulation)
          Center(
            child: Container(
              width: 280,
              height: 380,
              decoration: BoxDecoration(
                border: Border.all(
                  color: !_hasTakenPhoto 
                      ? Colors.white.withOpacity(0.5) // Putih tipis saat kamera standby
                      : (_isScanning ? AppColors.primary : Colors.green), 
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: !_hasTakenPhoto 
                            ? Colors.black54 
                            : (_isScanning ? AppColors.primary : Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            !_hasTakenPhoto 
                                ? Icons.camera_alt_outlined 
                                : (_isScanning ? Icons.auto_awesome : Icons.check_circle), 
                            color: Colors.white, 
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            !_hasTakenPhoto 
                                ? "Kamera Siap" 
                                : (_isScanning ? "YOLOv4 Scanning" : "Object Verified"),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. PANEL DIAGNOSTIK AI DI BAGIAN BAWAH
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_hasTakenPhoto) ...[
                    // Panel Diagnostik & Tombol Simpan baru muncul SETELAH foto dijepret
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "REAL-TIME AI DIAGNOSTIC",
                            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 14),
                          _buildDiagnosticRow("Kategori Objek", _detectedItem),
                          const SizedBox(height: 8),
                          _buildDiagnosticRow("Ekstraksi Warna", _detectedColor),
                          const SizedBox(height: 8),
                          _buildDiagnosticRow(
                            "Tingkat Akurasi", 
                            _confidence > 0 ? "${(_confidence * 100).toInt()}%" : "Menghitung...",
                            valueColor: _isScanning ? Colors.amber : Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isScanning ? null : () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Kemeja Flanel Merah berhasil disimpan ke Lemarimu!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.grey.shade800,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _isScanning ? "Menganalisis Pakaian..." : "Tambahkan ke Lemari Digital",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ] else ...[
                    // TOMBOL JEPRET (SHUTTER BUTTON) UTAMA ALA KAMERA ASLI
                    GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        height: 76, width: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Ketuk untuk Mengambil Foto Pakaian",
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticRow(String label, String value, {Color valueColor = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}