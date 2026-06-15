import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CatalogProvider with ChangeNotifier {
  // Pindahkan dummy data ke sini
  // --- DUMMY DATA LOKAL ---
  final List<Map<String, dynamic>> _partnerProducts = [
    {
      "name": "Oversized T-Shirt",
      "brand": "Generic",
      "priceStr": "Rp 129.000",
      "price": 129000,
      "match": "95% Match (Streetwear Minimalis)",
      "category": "Inner",
      "colorName": "Hitam",
      "imageUrl": "assets/images/black_tshirt.jpeg",
      "affiliateUrl": "https://shopee.co.id/",
    },
    {
      "name": "Techwear Cargo Jogger Pants",
      "brand": "MOKEWEN",
      "priceStr": "Rp 299.000",
      "price": 299000,
      "match": "93% Match (Urban Streetwear)",
      "category": "Celana",
      "colorName": "Hijau Army",
      "imageUrl": "assets/images/cargo.jpeg",
      "affiliateUrl": "https://shopee.co.id/",
    },
    {
      "name": "Legend Court Sneaker",
      "brand": "Good Man Brand",
      "priceStr": "Rp 899.000",
      "price": 899000,
      "match": "91% Match (Clean Casual)",
      "category": "Sepatu",
      "colorName": "Cream",
      "imageUrl": "assets/images/sneakers.jpeg",
      "affiliateUrl": "https://shopee.co.id/",
    },
    {
      "name": "Graphic Windbreaker Jacket",
      "brand": "Young Man",
      "priceStr": "Rp 249.000",
      "price": 249000,
      "match": "97% Match (Beanie Streetwear)",
      "category": "Outer",
      "colorName": "Cream",
      "imageUrl": "assets/images/windbreaker_jacket.jpeg",
      "affiliateUrl": "https://shopee.co.id/",
    },
  ];

  List<Map<String, dynamic>> get partnerProducts => _partnerProducts;

  // Pindahkan fungsi URL Launcher ke sini
  Future<void> launchAffiliateURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
}
