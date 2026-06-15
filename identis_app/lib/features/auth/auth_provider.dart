import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // Fungsi Login Firebase
  Future<String?> login(String email, String password) async {
    try {
      setLoading(true);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Mengembalikan null berarti SUKSES (tidak ada error)
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Terjadi kesalahan saat login"; // Mengembalikan pesan error
    } finally {
      setLoading(false);
    }
  }

  // Fungsi Register Firebase + Simpan Data ke Firestore
  Future<String?> register(String email, String password, String name) async {
    try {
      setLoading(true);
      // 1. Buat akun di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Simpan nama pengguna ke Firestore (Database)
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Terjadi kesalahan saat mendaftar";
    } finally {
      setLoading(false);
    }
  }

  // Fungsi untuk menyimpan data profil lengkap ke Firestore
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
        'bigFive': bigFive, // Firestore otomatis bisa menyimpan format Map
        'bodyShape': bodyShape,
        'undertone': undertone,
        'isSetupComplete': true, // Tanda bahwa user sudah selesai setup
      });
    }
  }

  // Fungsi untuk mengecek apakah user sudah menyelesaikan setup profil
  Future<bool> checkSetupStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          // Mengembalikan nilai boolean isSetupComplete dari Firestore (default false jika tidak ada)
          return doc.data()?['isSetupComplete'] ?? false;
        }
      } catch (e) {
        print("Error checking setup status: $e");
      }
    }
    return false;
  }
}