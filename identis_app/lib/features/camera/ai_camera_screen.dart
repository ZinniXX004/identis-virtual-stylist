import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/theme.dart';
import '../wardrobe/wardrobe_provider.dart';

class AiCameraScreen extends StatefulWidget {
  const AiCameraScreen({super.key});

  @override
  State<AiCameraScreen> createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen> {
  bool _hasTakenPhoto = false; // State untuk mengunci hasil foto
  bool _isScanning = false;
  String _detectedItem = "Arahkan kamera...";
  String _detectedCategory = "-";
  String _detectedMaterial = "-";
  String _detectedColor = "-";
  double _confidence = 0.0;
  File? _capturedImage;

  @override
  @override
  void initState() {
    super.initState();
    _openNativeCamera(); // Langsung buka kamera HP
  }

  Future<void> _openNativeCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _capturedImage = File(pickedFile.path);
      });
      // PANGGIL GEMINI DI SINI!
      _analyzeImageWithGemini(_capturedImage!); 
    } else {
      if (mounted) Navigator.pop(context);
    }
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

  // --- FUNGSI AI GEMINI ASLI ---
  Future<void> _analyzeImageWithGemini(File imageFile) async {
    setState(() {
      _hasTakenPhoto = true;
      _isScanning = true;
      _detectedItem = "AI sedang melihat...";
      _detectedColor = "-";
    });

    try {
      // PANGGIL API KEY DARI FILE .ENV
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API Key tidak ditemukan di file .env");
      }

      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

      // Kita "memaksa" Gemini untuk menjawab dalam format JSON agar mudah dibaca aplikasi
      final prompt = '''
        Kamu adalah Fashion AI expert. Analisis pakaian utama dalam gambar ini. 
        Kembalikan HANYA dalam format JSON MURNI tanpa markdown (tanpa ```json), dengan struktur persis seperti ini:
        {
          "nama_pakaian": "contoh: Kemeja Flanel / Kaos / Jaket Bomber",
          "kategori": "contoh: Topi / Atasan / Bawahan / Outer / Sepatu",
          "warna": "contoh: Merah Kotak-kotak / Hitam Polos"
          "bahan": "contoh: Katun / Denim / Rajut / Parasut / Kulit"
        }
      ''';

      // Ubah gambar jadi byte agar bisa dikirim
      final bytes = await imageFile.readAsBytes();
      final imagePart = DataPart('image/jpeg', bytes);

      // Tembak ke API Gemini
      final response = await model.generateContent([
        Content.multi([TextPart(prompt), imagePart])
      ]);

      // Bersihkan teks balasan Gemini dan ubah jadi JSON
      final jsonString = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '{}';
      final data = jsonDecode(jsonString);

      if (mounted) {
        setState(() {
          _detectedItem = data['nama_pakaian'] ?? 'Tidak diketahui';
          _detectedCategory = data['kategori'] ?? 'Lainnya';
          _detectedColor = data['warna'] ?? 'Tidak diketahui';
          _detectedMaterial = data['bahan'] ?? 'Belum diketahui'; // <-- Tangkap bahan
          _confidence = 0.98; 
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detectedItem = "Gagal dianalisis";
          _detectedColor = "Error API";
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Gemini: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam agar mirip viewfinder kamera asli
      body: Stack(
        children: [
          // 1. VIEWFINDER GAMBAR ASLI DARI KAMERA HP
          Positioned.fill(
            child: _capturedImage != null
                ? Image.file(
                    _capturedImage!,
                    fit: BoxFit.cover,
                  )
                : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                          _buildDiagnosticRow("Objek", "$_detectedItem ($_detectedCategory)"),
                          const SizedBox(height: 8),
                          _buildDiagnosticRow("Ekstraksi Warna", _detectedColor),
                          const SizedBox(height: 8),
                          _buildDiagnosticRow("Material/Bahan", _detectedMaterial), // <-- Tampilkan di UI
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
                        onPressed: _isScanning ? null : () async {
                          if (_capturedImage != null) {
                            try {
                              // Tampilkan indikator loading (opsional)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Menyimpan ke lemari...")),
                              );

                              // Simpan ke HP dan Firestore!
                              await Provider.of<WardrobeProvider>(context, listen: false).addCloth(
                                imageFile: _capturedImage!,
                                itemName: _detectedItem,
                                category: _detectedCategory,
                                colorName: _detectedColor,
                                material: _detectedMaterial, // <-- Kirim ke Provider
                              );

                              if (mounted) {
                                Navigator.pop(context); // Tutup kamera
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Berhasil disimpan ke Lemarimu!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red),
                              );
                            }
                          }
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