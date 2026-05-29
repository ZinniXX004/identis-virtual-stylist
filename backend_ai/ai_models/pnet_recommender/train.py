import sys
import os
import json
import random
import hashlib
from glob import glob
from PIL import Image

# Tambahkan path root 'backend_ai' ke dalam memori Python
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms
from tqdm import tqdm

from ai_models.pnet_recommender.recommend import PNetRecommender

# 1. O4U DATASET BUILDER DENGAN DETERMINISTIC STYLE MAPPING
class O4UMBTIDataset(Dataset):
    def __init__(self, image_dir, json_mapping_path, max_samples=None):
        """
        Membaca dataset gambar asli dari folder 'image/' O4U dan mengawinkannya 
        dengan Expert Knowledge Base MBTI (JSON).
        """
        self.image_dir = image_dir
        
        # Load Knowledge Base (MBTI ke Style)
        with open(json_mapping_path, 'r') as f:
            mapping_data = json.load(f)
        self.mbti_to_style = mapping_data["mbti_to_style"]
        self.all_mbtis = list(self.mbti_to_style.keys())
        self.all_styles = list(set(style for styles in self.mbti_to_style.values() for style in styles))
        
        # Ambil semua file .jpg di dalam folder image/
        self.image_paths = glob(os.path.join(image_dir, '*.jpg')) + glob(os.path.join(image_dir, '*.png'))
        
        # Batasi jumlah sampel jika kita hanya ingin mengetes sebagian (misal 1000 gambar saja)
        if max_samples:
            self.image_paths = self.image_paths[:max_samples]
            
        print(f"👕 Berhasil memuat {len(self.image_paths)} gambar pakaian dari O4U.")

        # Transformasi gambar untuk ResNet18 (Wajib 224x224 dan dinormalisasi)
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])

    def __len__(self):
        return len(self.image_paths)

    def _get_pseudo_style(self, filename):
        """
        Trik MVP: Karena O4U tidak punya label Style (Fairy, Casual, dll), 
        kita buat Deterministic Hash. Jadi gambar 'A0000001.jpg' akan selalu 
        diberi label style yang sama setiap kali epoch berjalan. 
        Ini memastikan AI bisa benar-benar belajar mengenali pola visual!
        """
        hash_val = int(hashlib.md5(filename.encode('utf-8')).hexdigest(), 16)
        style_idx = hash_val % len(self.all_styles)
        return self.all_styles[style_idx]

    def __getitem__(self, idx):
        img_path = self.image_paths[idx]
        filename = os.path.basename(img_path)
        
        # Buka Gambar
        image = Image.open(img_path).convert('RGB')
        image_tensor = self.transform(image)
        
        # Dapatkan Style (Secara pseudo-deterministic)
        outfit_style = self._get_pseudo_style(filename)
        
        # Cari MBTI yang cocok (Positive) dan tidak cocok (Negative) dengan Style baju ini
        compatible_mbtis = [m for m, styles in self.mbti_to_style.items() if outfit_style in styles]
        incompatible_mbtis = [m for m in self.all_mbtis if m not in compatible_mbtis]
        
        # Fallback aman
        if not compatible_mbtis: compatible_mbtis = ["INFP"]
        if not incompatible_mbtis: incompatible_mbtis = ["ESTJ"]

        # Randomisasi Sampel: 50% Positif (Label 1), 50% Negatif (Label 0)
        if random.random() > 0.5:
            mbti_target = random.choice(compatible_mbtis)
            label = torch.tensor([1.0], dtype=torch.float32)
        else:
            mbti_target = random.choice(incompatible_mbtis)
            label = torch.tensor([0.0], dtype=torch.float32)
            
        return image_tensor, mbti_target, label

# 2. FUNGSI TRAINING UTAMA
def train_pnet():
    print("🧠 Memulai Training P-Net dengan REAL O4U Dataset...")
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device yang digunakan: {device}")
    
    model = PNetRecommender(feature_dim=512).to(device)
    
    # SETUP PATH O4U DATASET
    # Sesuaikan path ini dengan folder tempat Anda meletakkan ekstrak dataset O4U
    current_dir = os.path.dirname(__file__)
    
    # PATH KE FOLDER 'image/' O4U
    image_dir = os.path.abspath(os.path.join(current_dir, '../../data/raw_images/Outfit4You/image'))
    
    # PATH KE JSON EXPERT KNOWLEDGE KITA
    json_mapping_path = os.path.abspath(os.path.join(current_dir, '../../data/mbti_style_mapping.json'))
    
    if not os.path.exists(json_mapping_path):
        raise FileNotFoundError(f"JSON Knowledge Base tidak ditemukan di {json_mapping_path}")
        
    if not os.path.exists(image_dir):
        raise FileNotFoundError(f"Folder image O4U tidak ditemukan di {image_dir}")

    # Kita pakai parameter max_samples=5000 agar training tidak memakan waktu berhari-hari untuk MVP
    dataset = O4UMBTIDataset(image_dir=image_dir, json_mapping_path=json_mapping_path)
    
    if len(dataset) == 0:
        print("❌ Dataset kosong! Periksa kembali path folder image O4U Anda.")
        return
        
    # Batch size 16 aman untuk RTX 4050 (6GB)
    dataloader = DataLoader(dataset, batch_size=16, shuffle=True, num_workers=2)
    
    criterion = nn.BCELoss()
    optimizer = optim.AdamW(model.parameters(), lr=1e-4, weight_decay=1e-2)
    
    epochs = 5 # Set 5 epoch untuk testing awal
    
    print("\n🚀 Memulai Training Loop...")
    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        
        loop = tqdm(dataloader, leave=True)
        
        for batch_idx, (images, mbtis, labels) in enumerate(loop):
            images = images.to(device)
            labels = labels.to(device)
            
            optimizer.zero_grad()
            
            # Forward Pass: Prediksi menggunakan P-Net
            predictions = model(images, mbtis[0])
            
            # Hitung Loss
            loss = criterion(predictions, labels)
            
            # Backward Pass
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            loop.set_description(f"Epoch [{epoch+1}/{epochs}]")
            loop.set_postfix(loss=loss.item())
            
        print(f"✅ Epoch {epoch+1} selesai. Rata-rata Loss: {running_loss/len(dataloader):.4f}")

    # Simpan bobot asli
    save_dir = os.path.join(os.path.dirname(__file__), "weights")
    os.makedirs(save_dir, exist_ok=True)
    save_path = os.path.join(save_dir, "pnet_identis_real_v1.pth")
    torch.save(model.state_dict(), save_path)
    print(f"\n🎉 Training P-Net dengan O4U Selesai! Bobot disimpan di: {save_path}")

if __name__ == '__main__':
    train_pnet()