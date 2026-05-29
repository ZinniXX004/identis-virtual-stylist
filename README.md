# 👗 IDENTIS: AI Virtual Personal Stylist

![IDENTIS Banner](docs/system_architecture.png) *masih draft*

**IDENTIS** adalah aplikasi *Virtual Personal Stylist* berbasis kecerdasan buatan (AI) yang dirancang khusus untuk Generasi Z. Aplikasi ini menggabungkan **Ilmu Psikologi Kepribadian (MBTI/Big Five)** dengan **Deep Learning** untuk memecahkan masalah *disonansi identitas*, *decision fatigue*, dan limbah *fast fashion*.

Proyek ini adalah bagian dari Project Mata Kuliah Kewirausahaan Berbasis Teknologi (KBT) 2026.

## 🚀 Status Saat Ini & Panduan Kolaborasi
*   **Backend dan AI:** Pipeline inferensi AI dan API FastAPI sudah berhasil dibangun dan dapat berjalan di memori GPU secara lokal.
*   **Frontend Team:** Sudah bisa mulai membangun UI Flutter! Silakan gunakan desain *Mock AI* dan integrasikan HTTP Request mengacu pada dokumen **[api_contract.md](docs/api_contract.md)**. Tidak perlu menunggu model AI asli dilatih secara penuh.

## 💡 Fitur Utama (Core Value Proposition)
1. **Wardrobe Scanner (YOLOv11):** Digitalisasi lemari otomatis menggunakan Computer Vision.
2. **Deep Personality Learning (P-Net):** Rekomendasi *Mix and Match* pakaian berdasarkan MBTI pengguna dan kecocokan fisik.
3. **Fashion Therapy:** Mengurangi kecemasan gaya dan mempromosikan *sustainable fashion* dengan mengoptimalkan pakaian yang sudah dimiliki.

## 📂 Struktur Repositori (Monorepo)

Repositori ini menggunakan pendekatan Monorepo yang memisahkan ranah Frontend (Mobile App) dan Backend (AI dan API Server).

```text
IDENTIS-Project/
│
├── .github/                         # Konfigurasi CI/CD (GitHub Actions untuk otomatisasi)
│   └── workflows/
│
├── docs/                            # [DOKUMENTASI dan ADMINISTRASI]
│   ├── PKM_Proposal_Clofyx.pdf      # File proposal asli
│   ├── PitchDeck_Identis.pdf        # Presentasi utama (termasuk slide Solusi & Bisnis)
│   ├── BMC_Identis.pdf              # Business Model Canvas
│   ├── api_contract.md              # Kesepakatan format JSON antara Frontend & Backend
│   └── system_architecture.png      # Diagram alur sistem (Flutter <-> FastAPI <-> AI)
│
├── frontend_app/                    # [FLUTTER APP, perlu penyesuaian]
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── core/                    # Tema, konstanta, dan utilitas aplikasi
│   │   ├── features/                # Arsitektur Feature-First (Sesuai Blueprint)
│   │   │   ├── auth/                # UI Login/Register (Firebase Auth)
│   │   │   ├── onboarding/          # UI Animasi "Show, Don't Tell"
│   │   │   ├── personality/         # UI Input MBTI (Dropdown/Grid)
│   │   │   ├── wardrobe/            # UI Lemari Digital (Gantungan baju virtual dan Tab bar)
│   │   │   └── recommendation/      # UI Flat-lay Outfit Grid
│   │   ├── services/
│   │   │   ├── ai_service.dart      # MOCK AI Service (menunggu Backend siap)
│   │   │   ├── local_storage.dart   # Mengatur penyimpanan foto di memori HP (path_provider)
│   │   │   └── api_client.dart      # Konfigurasi HTTP request ke server nantinya
│   │   └── main.dart                # Entry point aplikasi
│   └── pubspec.yaml                 # Dependensi Flutter (Provider, dll)
│
├── backend_ai/                      # [BACKEND dan AI SYSTEM]
│   ├── api/                         # FastAPI Application (Penghubung App dan AI)
│   │   ├── main.py                  # Entry point server (Endpoint: /scan dan /recommend)
│   │   ├── schemas.py               # Pydantic models (Definisi format JSON Contract)
│   │   └── routers/                 # Routing untuk merapikan endpoint
│   │
│   ├── ai_models/                   # Inti pemrosesan kecerdasan buatan
│   │   │
│   │   ├── yolov11_scanner/         # Modul Computer Vision (Inventory Scanner)
│   │   │   ├── weights/             # Bobot model YOLOv11 (.pt / .onnx)
│   │   │   ├── train.py             # Script untuk melatih YOLOv11 mendeteksi baju
│   │   │   ├── inference.py         # Fungsi deteksi bounding box & crop gambar
│   │   │   └── utils_color.py       # Ekstraksi palet warna baju
│   │   │
│   │   └── pnet_recommender/        # Modul Deep Personality Learning (Sesuai Paper)
│   │       ├── modules/             # Blok arsitektur P-Net
│   │       │   ├── feature_encoder.py  # ResNet18 untuk ekstraksi fitur baju
│   │       │   ├── message_passing.py  # GNN untuk relasi antar-baju
│   │       │   └── transformer.py      # Matching MBTI dengan Style Pakaian
│   │       ├── weights/             # Bobot model P-Net
│   │       ├── train.py             # Script melatih P-Net (dengan data SOP)
│   │       ├── recommend.py         # Fungsi logika Mix-and-Match
│   │       ├── evaluate_metrics.py   
│   │       ├── plot_1_loss_curve.png          
│   │       ├── plot_2_roc_curve.png             
│   │       └── plot_3_confusion_matrix.png         
│   │
│   ├── data/                        # [Masuk .gitignore]
│   │   ├── raw_images/              # Dataset gambar untuk training YOLO
│   │   │   ├── images/             
│   │   │   ├── labels/      
│   │   │   ├── fashion_dataset_dummy.yaml
│   │   │   └── fashion_datasets.yaml
│   │   ├── mbti_style_mapping.json  # Mapping pakar: MBTI ke Style (cth: INFP -> Fairy)
│   │   └── generate_dummy_yolo.py
│   │
│   ├── notebooks/                   # Jupyter Notebook (Untuk Riset, Uji Coba dan Analisa)
│   │   ├── 01_yolov11_experiments.ipynb
│   │   └── 02_pnet_architecture_test.ipynb
│   │
│   ├── requirements.txt             # Dependensi Python (FastAPI, PyTorch, Ultralytics, dll)
│   └── Dockerfile                   # Konfigurasi deploy backend ke Cloud Server
│
├── .gitignore                       # Mengabaikan file bobot model besar, dataset, dan env
└── README.md                        # Dokumentasi Utama Repository (Overview IDENTIS)
```
*(Catatan: Baca README.md di dalam masing-masing folder frontend_app/ dan backend_ai/ untuk panduan instalasi teknis spesifik).*

## 🛠️ Tech Stack

- Frontend Mobile: Flutter, Provider (State Management), Firebase Auth.
- Backend API: Python, FastAPI.
- Artificial Intelligence:
    - PyTorch (P-Net Architecture: ResNet18 + Message Passing + Transformer).
    - Ultralytics YOLOv11 (Inventory Object Detection).

## 👥 Tim IDENTIS (Kelompok 4)

1. Hayya Hilwa Fastawa (Project Manager)
2. Ignatius Devon Andri Putra
3. Abiel Ifan Imanuel Hukom
4. Jeremia Christ Immanuel Manalu
5. Rainhard Sintong Valentino Silitonga

---