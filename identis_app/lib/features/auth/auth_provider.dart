import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isSetupComplete = false;
  bool get isSetupComplete => _isSetupComplete;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // --- FUNGSI BARU (SOLUSI UTAMA) ---
  // Fungsi ini bertugas menyedot data terbaru dari Firebase dan menaruhnya di memori aplikasi
  Future<void> refreshUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          _userData = data;
          _isSetupComplete = data?['isSetupComplete'] ?? false;
          notifyListeners(); // Paksa seluruh layar (Profil, Home, dll) untuk update
        }
      } catch (e) {
        print("Error refreshing user data: $e");
      }
    }
  }

  // Fungsi Login Firebase
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      
      // Ambil data utuh setelah login berhasil
      await refreshUserData();

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    // WAJIB: Reset semua state ke default
    _isSetupComplete = false;
    _userData = null;
    notifyListeners();
  }

  // Fungsi Register Firebase + Simpan Data ke Firestore
  Future<String?> register(String email, String password, String name) async {
    try {
      setLoading(true);
      // 1. Buat akun di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // 2. Simpan nama pengguna ke Firestore (Database)
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Tarik datanya ke memori lokal agar nama tidak hilang!
      await refreshUserData();

      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Terjadi kesalahan saat mendaftar";
    } finally {
      setLoading(false);
    }
  }

  // Fungsi untuk menyimpan data profil lengkap ke Firestore (Saat Setup Akhir)
  Future<void> saveUserProfile({
    required String mbti,
    required Map<String, double> bigFive,
    required String bodyShape,
    required String undertone,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'mbti': mbti,
        'bigFive': bigFive, 
        'bodyShape': bodyShape,
        'undertone': undertone,
        'isSetupComplete': true, 
      });

      // 4. Pastikan memori lokal tahu MBTI dan status setup sudah terisi
      await refreshUserData();
    }
  }

  // --- FUNGSI UPDATE PROFIL (Saat di Layar Edit) ---
  Future<String?> updateProfile(String newName, String newBio) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Tidak ada user yang login.");

      // 1. Update data di Firebase Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': newName,
        'bio': newBio,
      });

      // 2. Tarik paksa data baru dari Firebase agar UI tergambar ulang seketika
      await refreshUserData();

      _isLoading = false;
      notifyListeners();
      return null; 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString(); 
    }
  }

  // Fungsi mengecek status saat pertama aplikasi dibuka
  Future<bool> checkSetupStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          
          // LUBANGNYA DI SINI KEMARIN: Sekarang kita simpan juga ke memori lokal!
          _userData = doc.data();
          _isSetupComplete = _userData?['isSetupComplete'] ?? false;
          notifyListeners();
          
          return _isSetupComplete;
        }
      } catch (e) {
        print("Error checking setup status: $e");
      }
    }
    return false;
  }
}