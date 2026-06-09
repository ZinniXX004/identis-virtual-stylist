import 'package:flutter/material.dart';
import '../../core/theme.dart';

// ==========================================
// 1. HALAMAN PROFIL UTAMA
// ==========================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State Profil User
  String userName = "Devon";
  String bio = "Mahasiswa ITS | Pecinta gaya kasual & techwear";
  
  // Fungsi navigasi ke halaman Edit Profil (Flow ala IG)
  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialName: userName,
          initialBio: bio,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        userName = result['name'];
        bio = result['bio'];
      });
    }
  }

  // Fungsi Logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Keluar Akun?"),
        content: const Text("Apakah kamu yakin ingin keluar dari aplikasi IDENTIS?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil Keluar (Simulasi)")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Latar belakang abu sangat muda agar card menonjol
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
            // --- 1. HEADER PROFIL (FOTO DI TENGAH) ---
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 100, height: 100,
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
                  Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(bio, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
                  
                  const SizedBox(height: 20),
                  
                  // Tombol Edit Profil Ala IG
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: _navigateToEditProfile,
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

            // --- 2. KARTU IDENTITAS AI (KEMBALI KE CARD, ELEGAN DEEP BLUE) ---
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
                    BoxShadow(color: Colors.blue.shade900.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8))
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
                        _buildAIProfileStat("MBTI", "ENFP"),
                        Container(width: 1, height: 40, color: Colors.white30),
                        _buildAIProfileStat("Undertone", "Warm"),
                        Container(width: 1, height: 40, color: Colors.white30),
                        _buildAIProfileStat("Body", "Hourglass"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- 3. MENU PENGATURAN BAWAH (DIKEMBALIKAN KE VERSI AWAL YANG MASUK AKAL) ---
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
                          icon: Icons.help_outline, 
                          title: "Pusat Bantuan & FAQ", 
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Membuka Pusat Bantuan...")))
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildMenuTile(
                          icon: Icons.info_outline, 
                          title: "Tentang IDENTIS", 
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("IDENTIS v1.0.0")))
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tombol Logout Merah
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

  // Widget Pembantu untuk Kartu AI
  Widget _buildAIProfileStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  // Widget Pembantu untuk Menu
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
// 2. HALAMAN EDIT PROFIL (ALA INSTAGRAM)
// ==========================================
class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialBio;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialBio,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    Navigator.pop(context, {
      'name': _nameController.text,
      'bio': _bioController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
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
            // Ganti Foto
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Ubah foto profil", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Input
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