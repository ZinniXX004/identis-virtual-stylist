import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../setup/personality_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // State untuk mengatur mode (Login atau Register)
  bool isLogin = true;
  // State untuk menyembunyikan/menampilkan password
  bool isPasswordVisible = false;
  // State untuk efek loading bohongan
  bool isLoading = false;

  // Fungsi untuk simulasi login/register (Loading 1.5 detik)
  void _dummyAuthenticate() async {
    setState(() {
      isLoading = true;
    });
  
    // Simulasi loading 1.5 detik seolah-olah menghubungi server
    await Future.delayed(const Duration(milliseconds: 1500));
  
    if (mounted) {
      setState(() {
        isLoading = false;
      });
  
      // Navigasi pindah ke halaman Setup Kepribadian
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PersonalitySetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // --- HEADER ---
              Text(
                "IDENTIS",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                isLogin ? "Selamat Datang\nKembali" : "Mulai Perjalanan\nGayamu",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLogin 
                    ? "Masuk untuk melihat lemari digitalmu." 
                    : "Buat akun untuk mendapatkan rekomendasi AI.",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // --- FORM INPUT ---
              // Kolom Nama (Hanya muncul jika mode Register)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: !isLogin
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildTextField(
                          label: "Nama Lengkap",
                          icon: Icons.person_outline,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Kolom Email
              _buildTextField(
                label: "Alamat Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Kolom Password
              _buildTextField(
                label: "Kata Sandi",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              
              // Lupa Kata Sandi (Hanya di mode Login)
              if (isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Lupa kata sandi?",
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else
                const SizedBox(height: 24),

              const SizedBox(height: 16),

              // --- TOMBOL UTAMA ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _dummyAuthenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isLogin ? "Masuk" : "Daftar",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // --- PEMISAH (DIVIDER) ---
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.secondary.withOpacity(0.3))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "atau",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.secondary.withOpacity(0.3))),
                ],
              ),

              const SizedBox(height: 32),

              // --- TOMBOL SOSIAL (GOOGLE) ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _dummyAuthenticate,
                  icon: const Icon(Icons.g_mobiledata, size: 32, color: AppColors.textPrimary), // Ikon dummy Google
                  label: const Text(
                    "Lanjutkan dengan Google",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- TOGGLE LOGIN / REGISTER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? "Belum punya akun? " : "Sudah punya akun? ",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin ? "Daftar Sekarang" : "Masuk di sini",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget custom untuk Input Field agar seragam dan elegan
  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.secondary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.secondary,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Hilangkan border bawaan
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}