import os
import shutil
import torch
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

# Import Schemas
from api.schemas import ScanResponse, RecommendRequest, RecommendResponse, OutfitRecommendation

# Import AI Models (Pastikan path import ini sesuai dengan letak file saat dijalankan)
from ai_models.yolov11_scanner.inference import WardrobeScanner
from ai_models.pnet_recommender.recommend import PNetRecommender

# Dictionary global untuk menyimpan model AI di memory (VRAM GPU)
ml_models = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Fungsi ini berjalan SATU KALI saat server FastAPI baru dinyalakan.
    Sangat krusial untuk meload model Deep Learning ke GPU agar tidak ada delay saat inferensi.
    """
    print("🚀 Memuat model AI ke dalam memori GPU...")
    
    # 1. Load YOLOv11
    ml_models["yolo"] = WardrobeScanner()
    
    # 2. Load P-Net Architecture (Saat ini bobotnya masih inisialisasi random karena belum ditraining)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    ml_models["pnet"] = PNetRecommender(feature_dim=512).to(device)
    ml_models["pnet"].eval() # Set mode evaluasi (bukan training)
    ml_models["device"] = device
    
    print(f"✅ Semua model berhasil dimuat di device: {device}")
    yield
    
    # Membersihkan memori GPU saat server dimatikan
    print("🧹 Membersihkan memori AI dari GPU...")
    ml_models.clear()
    torch.cuda.empty_cache()

# Inisialisasi FastAPI dengan lifespan
app = FastAPI(
    title="IDENTIS API",
    description="Backend AI for IDENTIS Virtual Personal Stylist",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "IDENTIS API is running with AI integrated!"}

@app.post("/scan", response_model=ScanResponse)
async def scan_wardrobe(file: UploadFile = File(...)):
    """
    Endpoint untuk YOLOv11. Menerima gambar dari Flutter, menyimpannya sementara,
    lalu dideteksi oleh YOLO, dan gambar sementaranya dihapus kembali.
    """
    if not file.filename.endswith(('.jpg', '.jpeg', '.png')):
        raise HTTPException(status_code=400, detail="Hanya menerima file gambar (.jpg, .jpeg, .png).")
    
    # Simpan file sementara di disk
    temp_file_path = f"temp_{file.filename}"
    with open(temp_file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    try:
        # Panggil YOLOv11 dari memori
        detected_items = ml_models["yolo"].detect_item(temp_file_path)
        
        return {
            "status": "success",
            "data": {
                "items_detected": len(detected_items),
                "predictions": detected_items
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error saat inferensi YOLO: {str(e)}")
    finally:
        # Pastikan file sementara selalu dihapus agar harddisk tidak penuh
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)

@app.post("/recommend", response_model=RecommendResponse)
async def get_recommendation(request: RecommendRequest):
    """
    Endpoint untuk P-Net.
    CATATAN ARSITEKTUR: Dalam skenario nyata, P-Net butuh Tensor gambar baju.
    Di sini kita menstimulasikan (mock) tensor gambarnya untuk membuktikan arsitektur berjalan.
    """
    try:
        device = ml_models["device"]
        pnet_model = ml_models["pnet"]
        
        # --- SIMULASI TENSOR GAMBAR ---
        # Karena kita hanya menerima ID baju dari Flutter (misal: "baju_1"), 
        # kita buat tensor dummy berukuran (Batch, Channel, Height, Width) untuk menguji P-Net.
        # Nanti, backend harusnya meload gambar betulan dari database/lokal berdasarkan ID ini.
        batch_size = len(request.wardrobe_item_ids) if len(request.wardrobe_item_ids) > 0 else 2
        dummy_images = torch.randn(batch_size, 3, 224, 224).to(device)
        
        # Inferensi P-Net (Panggil fungsi forward)
        with torch.no_grad(): # Matikan perhitungan gradien agar memori hemat
            # Outputnya adalah tensor skor kecocokan
            match_scores = pnet_model(dummy_images, request.mbti)
        
        # Ekstrak skor tertinggi (Simulasi)
        best_score = match_scores[0].item() if match_scores.size(0) > 0 else 0.85
        
        return {
            "status": "success",
            "mbti_analyzed": request.mbti.upper(),
            "style_matched": "Fairy/Casual" if request.mbti.upper() in ["INFP", "ENFP"] else "Smart Casual",
            "recommendations": [
                {
                    "top_id": request.wardrobe_item_ids[0] if len(request.wardrobe_item_ids) > 0 else "item_top_01",
                    "bottom_id": request.wardrobe_item_ids[1] if len(request.wardrobe_item_ids) > 1 else "item_bottom_01",
                    "match_score": round(best_score, 2)
                }
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error saat inferensi P-Net: {str(e)}")