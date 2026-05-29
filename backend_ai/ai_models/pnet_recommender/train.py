import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from tqdm import tqdm

# Gunakan Absolute Import
from ai_models.pnet_recommender.modules.feature_encoder import FeatureEncoder
from ai_models.pnet_recommender.modules.message_passing import OutfitMessagePassing
from ai_models.pnet_recommender.modules.transformer import PersonalityStyleTransformer
from ai_models.pnet_recommender.recommend import PNetRecommender

# 1. DUMMY DATASET (Hanya untuk testing kode berjalan tanpa error)
class DummyFashionDataset(Dataset):
    def __init__(self, num_samples=100):
        self.num_samples = num_samples
        self.mbti_list = ["INFP", "INTJ", "ESFP", "ESTJ"]
        
    def __len__(self):
        return self.num_samples
        
    def __getitem__(self, idx):
        # Simulasi gambar baju (3 channels RGB, 224x224 resolusi ResNet)
        image = torch.randn(3, 224, 224)
        # Random MBTI
        mbti = self.mbti_list[idx % 4]
        # Random label kecocokan: 1.0 (Cocok) atau 0.0 (Tidak Cocok)
        label = torch.tensor([1.0 if idx % 2 == 0 else 0.0], dtype=torch.float32)
        return image, mbti, label

# 2. FUNGSI TRAINING UTAMA
def train_pnet():
    print("🧠 Memulai Inisialisasi Training P-Net...")
    
    # Setup Device (Deteksi RTX 4050)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device yang digunakan: {device}")
    
    # Inisialisasi Model P-Net
    model = PNetRecommender(feature_dim=512).to(device)
    
    # Setup Dataloader
    dataset = DummyFashionDataset(num_samples=200) # Ganti ini dengan dataset SOP sungguhan nanti
    dataloader = DataLoader(dataset, batch_size=16, shuffle=True)
    
    # Definisikan Optimizer dan Loss Function
    # Binary Cross Entropy (BCE) sangat cocok karena output transformer kita pakai Sigmoid (0 s.d 1)
    criterion = nn.BCELoss()
    # AdamW adalah optimizer modern yang lebih stabil mencegah overfitting
    optimizer = optim.AdamW(model.parameters(), lr=1e-4, weight_decay=1e-2)
    
    epochs = 5 # Set ke 50 atau 100 saat training dataset asli
    
    print("\n🚀 Memulai Training Loop...")
    for epoch in range(epochs):
        model.train() # Set model ke mode training
        running_loss = 0.0
        
        # Progress bar untuk terminal
        loop = tqdm(dataloader, leave=True)
        
        for batch_idx, (images, mbtis, labels) in enumerate(loop):
            # Pindahkan data ke GPU
            images = images.to(device)
            labels = labels.to(device)
            
            # 1. Reset gradient (Wajib di PyTorch)
            optimizer.zero_grad()
            
            # 2. Forward Pass: Prediksi menggunakan P-Net
            # Catatan: di recommend.py, kita harus menerima list/tuple string, 
            # tapi karena kita loop manual, kita proses satu per satu atau modifikasi fungsi forward.
            # Untuk skrip ini, kita asumsikan mbtis seragam dalam batch (hanya untuk testing logic)
            mbti_batch_string = mbtis[0] 
            predictions = model(images, mbti_batch_string)
            
            # 3. Hitung Loss (Seberapa jauh prediksi AI dari label aslinya)
            loss = criterion(predictions, labels)
            
            # 4. Backward Pass (Hitung kemiringan/gradient)
            loss.backward()
            
            # 5. Update Bobot Model (Belajar)
            optimizer.step()
            
            running_loss += loss.item()
            
            # Update info di progress bar
            loop.set_description(f"Epoch [{epoch+1}/{epochs}]")
            loop.set_postfix(loss=loss.item())
            
        print(f"✅ Epoch {epoch+1} selesai. Rata-rata Loss: {running_loss/len(dataloader):.4f}")

# 3. SIMPAN MODEL TERBAIK
    # Buat foldernya otomatis jika belum ada
    save_dir = os.path.join(os.path.dirname(__file__), "weights")
    os.makedirs(save_dir, exist_ok=True)
    
    save_path = os.path.join(save_dir, "pnet_identis_v1.pth")
    torch.save(model.state_dict(), save_path)
    print(f"\n🎉 Training P-Net Selesai! Model disimpan di: {save_path}")

if __name__ == '__main__':
    train_pnet()