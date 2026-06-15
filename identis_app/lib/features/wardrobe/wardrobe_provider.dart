import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WardrobeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _clothes = [];
  List<Map<String, dynamic>> get clothes => _clothes;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fungsi untuk mengambil data lemari dari Firestore
  Future<void> fetchWardrobe() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wardrobe')
          .orderBy('createdAt', descending: true)
          .get();

      _clothes = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching wardrobe: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi untuk menyimpan gambar ke HP dan data ke Firestore
  Future<void> addCloth({
    required File imageFile,
    required String itemName, // Tambahan baru: Nama spesifik (cth: Kupluk Rajut)
    required String category, // Kategori (cth: Aksesoris / Bawahan)
    required String colorName,
    required String material,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy(p.join(appDir.path, fileName));

      final clothData = {
        'name': itemName, // Sekarang pakai nama asli dari AI
        'type': category, // Sekarang pakai kategori asli dari AI
        'colorName': colorName,
        'usage': 'Lumayan', 
        'localImagePath': savedImage.path, 
        'material': material, 
        'brand': '-',
        'wearCount': 0,
        'lastWorn': 'Belum pernah',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wardrobe')
          .add(clothData);

      await fetchWardrobe();
    } catch (e) {
      print("Error saving cloth: $e");
      rethrow;
    }
  }
}