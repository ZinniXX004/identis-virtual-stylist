import 'package:flutter/material.dart';
import '../../core/ai_service.dart';

class HomeProvider with ChangeNotifier {
  final AiService _aiService = AiService();
  
  bool _isLoading = false;
  Map<String, dynamic> _currentOutfit = {}; // Menyimpan hasil JSON dari AI

  bool get isLoading => _isLoading;
  Map<String, dynamic> get currentOutfit => _currentOutfit;

  Future<void> generateOutfit(String prompt, List<Map<String, dynamic>> wardrobe, List<Map<String, dynamic>> catalog) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentOutfit = await _aiService.getOutfitRecommendation(
        promptUser: prompt,
        wardrobe: wardrobe,
        catalog: catalog,
      );
    } catch (e) {
      _currentOutfit = {"analisis": "Terjadi kesalahan: Gagal memuat rekomendasi."};
    }

    _isLoading = false;
    notifyListeners();
  }
}