import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'physical_setup_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalitySetupScreen extends StatefulWidget {
  const PersonalitySetupScreen({super.key});

  @override
  State<PersonalitySetupScreen> createState() => _PersonalitySetupScreenState();
}

class _PersonalitySetupScreenState extends State<PersonalitySetupScreen> {
  // Data MBTI
  final List<String> mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP'
  ];
  
  String? selectedMbti;

  // Data Slider Big Five (Default di tengah: 50)
  Map<String, double> bigFiveScores = {
    'Openness (Keterbukaan)': 50.0,
    'Conscientiousness (Kehati-hatian)': 50.0,
    'Extraversion (Ekstraversi)': 50.0,
    'Agreeableness (Keramahan)': 50.0,
    'Neuroticism (Emosionalitas)': 50.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Kepribadian"),
        elevation: 1, // Sedikit bayangan
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: MBTI GRID ---
              const Text(
                "1. Apa tipe MBTI kamu?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pilih satu tipe yang paling menggambarkan dirimu.",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              
              // --- TAMBAHAN: INFO BELUM TAHU MBTI ---
              
              
              GridView.builder(
                shrinkWrap: true, // Penting agar GridView bisa di dalam SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 kolom
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5, // Rasio lebar:tinggi kotak
                ),
                itemCount: mbtiTypes.length,
                itemBuilder: (context, index) {
                  final type = mbtiTypes[index];
                  final isSelected = selectedMbti == type;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedMbti = type;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.secondary.withOpacity(0.3),
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        type,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Belum tahu tipe MBTI kamu?",
                        style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // Link menuju tes 16personalities
                        final Uri url = Uri.parse('https://www.16personalities.com/id/tipe-kepribadian');
                        if (!await launchUrl(url)) {
                          if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal membuka browser')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text("Tes di Sini"),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              const SizedBox(height: 24),

              // --- SECTION 2: BIG FIVE SLIDERS ---
              const Text(
                "2. Skor Big Five (Opsional tapi disarankan)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Geser slider untuk akurasi rekomendasi AI yang lebih baik.",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Looping untuk membuat 5 Slider
              ...bigFiveScores.keys.map((trait) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trait,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        Text(
                          "${bigFiveScores[trait]!.toInt()}%",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Slider(
                      value: bigFiveScores[trait]!,
                      min: 0,
                      max: 100,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.secondary.withOpacity(0.3),
                      onChanged: (value) {
                        setState(() {
                          bigFiveScores[trait] = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),

              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Belum tahu skor Big Five kamu?",
                        style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // Link menuju tes 16personalities
                        final Uri url = Uri.parse('https://bigfive.catalyte.io/id');
                        if (!await launchUrl(url)) {
                          if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal membuka browser')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text("Tes di Sini"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- TOMBOL LANJUT ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedMbti == null
                      ? null // Tombol mati kalau MBTI belum dipilih
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhysicalSetupScreen(
                                mbti: selectedMbti!,
                                bigFive: bigFiveScores,
                              ),
                            ),
                          );
                          print("MBTI: $selectedMbti");
                          print("Big Five: $bigFiveScores");
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.secondary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Lanjutkan",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}