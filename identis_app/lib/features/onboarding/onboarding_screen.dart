import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // List untuk menyimpan 3 controller video
  late List<VideoPlayerController> _videoControllers;

  // Data onboarding ditambahkan path video-nya
  final List<Map<String, dynamic>> onboardingData = [
    {
      "video": "assets/videos/slide1.mp4",
      "title": "Kenali Gayamu!",
      "text": "Temukan rekomendasi fashion terbaik yang disesuaikan dengan kepribadian MBTI kamu."
    },
    {
      "video": "assets/videos/slide2.mp4",
      "title": "Lemari Digital Cerdas",
      "text": "Simpan, atur, dan lihat semua koleksi pakaianmu dalam satu genggaman."
    },
    {
      "video": "assets/videos/slide3.mp4",
      "title": "Tampil Percaya Diri",
      "text": "Biar AI kami yang bantu kamu mix & match outfit setiap hari. Siap untuk mulai?"
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi ketiga video sekaligus agar transisinya mulus tanpa loading
    _videoControllers = onboardingData.map((data) {
      return VideoPlayerController.asset(data["video"])
        ..initialize().then((_) {
          setState(() {}); // Refresh UI setelah video siap
        })
        ..setVolume(0.0) // Mute video
        ..setLooping(true);
    }).toList();

    // Jalankan (play) hanya video pertama saat aplikasi baru dibuka
    _videoControllers[0].play();
  }

  @override
  void dispose() {
    // Bersihkan memory: hentikan semua controller video saat pindah halaman
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // LAYER 1 & 2: PAGEVIEW UNTUK VIDEO + TEKS
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              // Logika Pintar: Pause video sebelumnya, Play video yang baru
              _videoControllers[_currentPage].pause();
              _videoControllers[value].play();
              
              setState(() {
                _currentPage = value;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // --- Video Background Tiap Slide ---
                  if (_videoControllers[index].value.isInitialized)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoControllers[index].value.size.width,
                        height: _videoControllers[index].value.size.height,
                        child: VideoPlayer(_videoControllers[index]),
                      ),
                    )
                  else
                    const Center(child: CircularProgressIndicator(color: Colors.white)),

                  // --- Gradient Overlay Hitam ---
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // --- Teks Onboarding ---
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            onboardingData[index]["title"],
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            onboardingData[index]["text"],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 180), // Memberi ruang untuk tombol di bawah
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // LAYER 3: INDIKATOR TITIK & TOMBOL (Tetap (fixed) di layar, tidak ikut tergeser)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                        (index) => buildDot(index: index),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_currentPage == onboardingData.length - 1) {
                            // Navigasi menimpa halaman agar tidak bisa di-back
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == onboardingData.length - 1 
                              ? "Mulai Sekarang" 
                              : "Selanjutnya",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}