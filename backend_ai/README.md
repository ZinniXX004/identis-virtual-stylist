# 🧠 IDENTIS - Backend and AI Engine

Folder ini berisi seluruh *source code* untuk *server API* dan Arsitektur Kecerdasan Buatan (AI) aplikasi IDENTIS. Sistem ini dibangun menggunakan **FastAPI** sebagai jembatan komunikasi, **Ultralytics YOLOv11** untuk *Computer Vision*, dan arsitektur *custom* **P-Net (PyTorch)** untuk *Personality-Style Matching*.

## ⚠️ Status Development Saat Ini (Wajib Baca)

Bagi kontributor yang baru bergabung, harap perhatikan hal berikut:

1. **Dataset Masih Dummy:** Skrip training (`train.py`) untuk YOLOv11 dan P-Net saat ini dikonfigurasi menggunakan *dummy dataset* (gambar random) hanya untuk memvalidasi *pipeline* arsitektur (Forward/Backward pass).
2. **API Endpoint Bersifat Dinamis:** Routing dan respon di `api/main.py` saat ini mengacu pada `docs/api_contract.md`. Struktur JSON dapat berubah sewaktu-waktu menyesuaikan kebutuhan tim Frontend.
3. **Bobot Model (Weights):** Saat ini server meload `yolo11n.pt` (standar COCO) dan bobot P-Net hasil *training dummy*.

## ⚙️ Persyaratan Sistem (Prerequisites)

- **Python:** Versi `3.14.4` (Sangat disarankan untuk menghindari *dependency clash*).
- **GPU (Opsional tapi disarankan):** NVIDIA GPU dengan dukungan CUDA (Misal: RTX 4050, CUDA 13.2).

## 🚀 Cara Setup dan Menjalankan Server Lokal

### 1. Inisialisasi Virtual Environment

Pastikan Anda berada di dalam folder `backend_ai/` sebelum menjalankan perintah berikut:

```bash
# Windows
python -m venv .venv
.venv\Scripts\activate

# Mac/Linux
python3 -m venv .venv
source .venv/bin/activate
```

### 2. Install Dependencies

Karena kita menggunakan Python 3.14.4 dan membutuhkan performa GPU, instalasi PyTorch harus dilakukan secara eksplisit menggunakan CUDA 13.2 (cu132):

```bash
# Install PyTorch dengan dukungan CUDA 13.2
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu132

# Install sisa dependencies (FastAPI, Ultralytics, OpenCV, dll)
pip install -r requirements.txt # Perhatikan juga panduan di file requirements.txt agar tidak mismatch antar dependencies
```

### 3. Menjalankan FastAPI Server

```bash
uvicorn api.main:app --reload
```

Server akan berjalan di http://127.0.0.1:8000.
Untuk melihat antarmuka testing API dan struktur JSON Contract, buka http://127.0.0.1:8000/docs di browser Anda.

## 🏗️ Struktur Folder backend_ai

- api/: Mengatur endpoint HTTP, CORS, dan Skema Pydantic. Model AI di-load ke VRAM GPU melalui fungsi lifespan di main.py.
- ai_models/yolov11_scanner/: Logika untuk mendeteksi baju dan mengekstrak warna dominan (OpenCV K-Means).
- ai_models/pnet_recommender/: Arsitektur Deep Learning kustom (ResNet18 + GNN Message Passing + Transformer).
- data/: Tempat menyimpan dataset mentah dan file konfigurasi YAML (Di-ignore oleh git).
- notebooks/: File .ipynb untuk riset dan eksperimen tanpa mengganggu core system.

## 🔮 Rencana Tindak Lanjut (Next Steps) - Pencarian Dataset Asli

Untuk mengembangkan AI ini menjadi produk siap pakai (production-ready), kita perlu mengganti dummy dataset dengan dataset fashion asli:

1. Untuk YOLOv11 (Object Detection):

   - Rekomendasi: Cari dataset "Clothes Detection YOLO" di Roboflow Universe.
   - Alternatif: DeepFashion2 Dataset (Membutuhkan konversi label ke format teks YOLO).
   - Target: Melatih YOLO untuk mengenali setidaknya 5 kelas utama: Top, Bottom, Dress, Shoes, dan Bag.
2. Untuk P-Net (Personality Recommendation):

   - Rekomendasi: Berdasarkan paper referensi, kita membutuhkan SOP (Stylish Outfit of Personality) dataset.
   - Karena keterbatasan akses dataset privat, kita perlu memodifikasi file mbti_style_mapping.json (Expert Knowledge Base) dan memasangkannya dengan dataset fashion terbuka (seperti O4U - Outfit for You) untuk melakukan fine-tuning pada Transformer Matcher.

---
