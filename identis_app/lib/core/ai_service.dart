import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  late final GenerativeModel _model;

  AiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<Map<String, dynamic>> getOutfitRecommendation({
    required String promptUser,
    required Map<String, dynamic> userData, // <-- Menerima data user
    required List<Map<String, dynamic>> wardrobe,
    required List<Map<String, dynamic>> catalog,
  }) async {
    final wardrobeList = wardrobe.map((e) => "{'nama': '${e['name']}', 'kategori': '${e['type']}', 'path': '${e['localImagePath'] ?? ''}'}").toList();
    final catalogList = catalog.map((e) => "{'nama': '${e['name']}', 'kategori': '${e['category']}', 'path': '${e['imageUrl'] ?? ''}'}").toList();

    // Ekstrak profil psikologi & fisik
    final mbti = userData['mbti'] ?? 'Tidak diketahui';
    final bodyShape = userData['bodyShape'] ?? 'Tidak diketahui';
    final skinTone = userData['undertone'] ?? 'Tidak diketahui';

    final prompt = '''
    Anda adalah AI Fashion Stylist IDENTIS. 
    Pengguna meminta: "$promptUser".

    Profil Pengguna:
    - Kepribadian (MBTI): $mbti
    - Bentuk Tubuh: $bodyShape
    - Undertone Kulit: $skinTone

    Pilihkan kombinasi pakaian (Topi, Outer, Inner, Celana, Sepatu) yang SECARA SPESIFIK cocok dengan profil MBTI dan fisik pengguna di atas.
    Jika di kategori tersebut tidak ada item yang cocok, isi dengan "null".
    
    Lemari (Utamakan ini): $wardrobeList
    Katalog (Gunakan untuk melengkapi): $catalogList

    PENTING: Balas HANYA dengan format JSON valid seperti di bawah ini, tanpa teks pengantar/penutup (tanpa ```json):
    {
      "topi": "path_gambar_atau_null",
      "outer": "path_gambar_atau_null",
      "inner": "path_gambar_atau_null",
      "celana": "path_gambar_atau_null",
      "sepatu": "path_gambar_atau_null",
      "analisis": "Jelaskan dalam satu kalimat mengapa kombinasi ini cocok dengan MBTI $mbti dan bentuk tubuh $bodyShape pengguna."
    }
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '{}';
      return jsonDecode(responseText); 
    } catch (e) {
      print("AI Error: $e");
      return {"analisis": "Gagal menghubungi AI. Pastikan format prompt valid."};
    }
  }
}