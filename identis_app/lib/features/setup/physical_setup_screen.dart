import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../home/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart'; // Sesuaikan path jika berbeda

class PhysicalSetupScreen extends StatefulWidget {
  final String mbti;
  final Map<String, double> bigFive;

  const PhysicalSetupScreen({
    super.key, 
    required this.mbti, 
    required this.bigFive,
  });

  @override
  State<PhysicalSetupScreen> createState() => _PhysicalSetupScreenState();
}

class _PhysicalSetupScreenState extends State<PhysicalSetupScreen> {
  // Data Bentuk Tubuh
  final List<Map<String, dynamic>> bodyShapes = [
    {"name": "Jam Pasir", "icon": Icons.hourglass_empty},
    {"name": "Pir", "icon": Icons.change_history}, // Pengganti icon segitiga
    {"name": "Apel", "icon": Icons.apple},
    {"name": "Persegi", "icon": Icons.crop_portrait},
    {"name": "Segitiga Terbalik", "icon": Icons.details},
  ];

  // Data Undertone Kulit beserta warnanya
  final List<Map<String, dynamic>> undertones = [
    {"name": "Warm", "desc": "Nadi kehijauan", "color": Colors.orange.shade200},
    {"name": "Cool", "desc": "Nadi kebiruan", "color": Colors.blue.shade100},
    {"name": "Neutral", "desc": "Campuran keduanya", "color": Colors.brown.shade200},
  ];

  String? selectedBodyShape;
  String? selectedUndertone;
  bool isLoading = false;

  void _finishSetup() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Ambil AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Simpan semua data (Personality + Physical) ke Firestore
      await authProvider.saveUserProfile(
        mbti: widget.mbti,
        bigFive: widget.bigFive,
        bodyShape: selectedBodyShape!,
        undertone: selectedUndertone!,
      );

      // Jika berhasil, pindah ke Home
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Fisik"),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: BENTUK TUBUH ---
            const Text(
              "3. Apa bentuk tubuhmu?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "AI akan merekomendasikan potongan baju (cutting) yang paling pas untukmu.",
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolom agar lebih lebar
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5, // Ukuran memanjang
              ),
              itemCount: bodyShapes.length,
              itemBuilder: (context, index) {
                final shape = bodyShapes[index];
                final isSelected = selectedBodyShape == shape["name"];
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedBodyShape = shape["name"];
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.secondary.withOpacity(0.3),
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : [],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(shape["icon"], color: isSelected ? Colors.white : AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            shape["name"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // --- SECTION 2: UNDERTONE KULIT ---
            const Text(
              "4. Apa undertone kulitmu?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "Membantu AI memilihkan palet warna baju yang membuat kulitmu bersinar.",
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // List Undertone (Bentuk Card horizontal)
            ...undertones.map((tone) {
              final isSelected = selectedUndertone == tone["name"];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedUndertone = tone["name"];
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.secondary.withOpacity(0.3),
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        // Lingkaran Warna
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: tone["color"],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Teks Penjelasan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tone["name"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                tone["desc"],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Ikon Checkmark jika dipilih
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.white)
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 40),

            // --- TOMBOL SELESAI ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (selectedBodyShape == null || selectedUndertone == null || isLoading)
                    ? null
                    : _finishSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.secondary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        "Mulai Gunakan IDENTIS",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}