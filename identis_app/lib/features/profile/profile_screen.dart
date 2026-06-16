import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart'; // Pastikan path ini sesuai dengan letak file login Anda

// ==========================================
// 1. HALAMAN PROFIL UTAMA
// ==========================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // Fungsi navigasi ke halaman Edit Profil
  // Kita passing data asli dari Firebase yang sedang aktif ke halaman Edit
  void _navigateToEditProfile(String currentName, String currentBio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialName: currentName, 
          initialBio: currentBio,
        ),
      ),
    );
  }

  // Fungsi Logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Keluar Akun?"),
        content: const Text("Apakah kamu yakin ingin keluar dari aplikasi IDENTIS?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); // Tutup dialog
              try {
                // Eksekusi logout di backend
                await context.read<AuthProvider>().logout();
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil keluar dari akun")),
                );

                // Hapus semua history layar dan lempar ke LoginScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal logout: $e")),
                );
              }
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. BACA DATA DARI DATABASE (PROVIDER)
    // context.watch akan membuat UI otomatis update kalau data di Provider berubah (misal habis diedit)
    final authProvider = context.watch<AuthProvider>();
    final userData = authProvider.userData ?? {};

    // 2. AMBIL VALUE-NYA (Beri default jika kosong)
    final userName = userData['name'] ?? 'User IDENTIS';
    // Karena saat register belum ada form bio, kita beri default teks ini jika kosong:
    final bio = (userData['bio'] != null && userData['bio'].toString().isNotEmpty) 
        ? userData['bio'] 
        : 'Belum ada bio. Tambahkan sekarang!'; 
        
    final mbti = userData['mbti'] ?? '-';
    final undertone = userData['undertone'] ?? '-';
    final bodyShape = userData['bodyShape'] ?? '-';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("IDENTIS | Profil", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER PROFIL ---
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Render Nama Asli
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  // Render Bio Asli
                  Text(
                    bio,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: OutlinedButton(
                      // Panggil Edit dan bawa data asli saat ini
                      onPressed: () => _navigateToEditProfile(userName, bio),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- KARTU IDENTITAS AI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.shade900.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text("Identitas Fashion AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAIProfileStat("MBTI", mbti),
                        Container(width: 1, height: 40, color: Colors.white30),
                        _buildAIProfileStat("Undertone", undertone),
                        Container(width: 1, height: 40, color: Colors.white30),
                        _buildAIProfileStat("Body", bodyShape),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- MENU PENGATURAN BAWAH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Lainnya", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.help_outline, title: "Pusat Bantuan & FAQ",
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Membuka Pusat Bantuan..."))),
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildMenuTile(
                          icon: Icons.info_outline, title: "Tentang IDENTIS",
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("IDENTIS v1.0.0"))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.logout, color: Colors.red, size: 20),
                    ),
                    title: const Text("Keluar Akun", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: _showLogoutDialog,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIProfileStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.secondary),
      onTap: onTap,
    );
  }
}

// ==========================================
// 2. HALAMAN EDIT PROFIL
// ==========================================
class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialBio;

  const EditProfileScreen({super.key, required this.initialName, required this.initialBio});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    // Set text controller dengan data asli dari parameter
    _nameController = TextEditingController(text: widget.initialName);
    // Jika bio isinya teks default dari kita, kosongkan saja formnya agar enak diedit
    String startingBio = widget.initialBio == 'Belum ada bio. Tambahkan sekarang!' ? '' : widget.initialBio;
    _bioController = TextEditingController(text: startingBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Fungsi simpan yang akan menembak ke backend
  Future<void> _saveProfile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Menyimpan profil..."), duration: Duration(seconds: 1)),
    );

    // Panggil updateProfile di auth_provider.dart
    final errorMessage = await context.read<AuthProvider>().updateProfile(
      _nameController.text.trim(),
      _bioController.text.trim(),
    );

    if (!mounted) return;

    if (errorMessage == null) {
      Navigator.pop(context); // Kembali ke profil utama jika sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $errorMessage"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text("Edit Profil", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text("Simpan", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Ubah foto profil", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInputField("Nama", _nameController),
            const SizedBox(height: 20),
            _buildInputField("Bio", _bioController, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          decoration: const InputDecoration(
            border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEEEEEE))),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEEEEEE))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}