import sys
import os
import json
import random
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

# 1. O4U DATASET BUILDER (MEMBACA JSON ASLI)
class O4UMBTIDataset(Dataset):
    def __init__(self, image_dir, json_file_path):
        """
        Membaca train.json dari O4U dan mengambil gambar utamanya (item_1).
        Lalu memetakannya ke MBTI berdasarkan Atribut Fisik.
        """
        self.image_dir = image_dir
        self.valid_data = []
        
        print(f"📖 Membaca file JSON: {json_file_path}...")
        with open(json_file_path, 'r') as f:
            raw_data = json.load(f)
            
        # Filter data yang valid (memiliki gambar item_1 dan file fisiknya ada)
        for entry in raw_data:
            # Kita ambil item_1 (Biasanya Atasan/Dress) sebagai representasi visual outfit untuk MVP
            img_filename = entry.get("item_1")
            
            if img_filename and img_filename != "null":
                img_path = os.path.join(image_dir, img_filename)
                
                # Pastikan file gambar benar-benar ada di harddisk
                if os.path.exists(img_path):
                    self.valid_data.append({
                        "image_path": img_path,
                        "body_figure": entry.get("body_figure", ""),
                        "skin_color": entry.get("skin_color", ""),
                        "height": entry.get("height", "")
                    })
                    
        print(f"✅ Ditemukan {len(self.valid_data)} outfit valid yang siap ditraining.")

        # Transformasi gambar untuk ResNet18
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])

    def __len__(self):
        return len(self.valid_data)

    def _map_physical_to_mbti(self, physical_data):
        """
        [THE MAGIC BRIDGE]
        Memetakan Atribut Fisik (O4U) ke MBTI (Sesuai Proposal PKM-K Identis)
        """
        body = physical_data["body_figure"].lower()
        skin = physical_data["skin_color"].lower()
        height = physical_data["height"].lower()
        
        # Aturan Pakar (Expert Rule Base)
        if "athietic" in body or "inverted_triangle" in body:
            return ["ESTP", "ENTP", "ISTP"] # Sporty / Streetwear
        elif "hourglass" in body or "fair" in skin:
            return ["INFP", "INFJ", "ENFJ"] # Elegant / Fairy / Soft
        elif "high" in height or "rectangle" in body:
            return ["INTJ", "ESTJ", "ISTJ"] # Formal / Dark Academia / Minimalist
        elif "spoon" in body or "round" in body:
            return ["ISFJ", "ESFJ", "ISFP"] # Casual / Modest
        else:
            return ["ENFP", "ESFP", "INTP"] # Eclectic / Y2K / Grunge

    def __getitem__(self, idx):
        data = self.valid_data[idx]
        
        # 1. Load Gambar
        image = Image.open(data["image_path"]).convert('RGB')
        image_tensor = self.transform(image)
        
        # 2. Tentukan MBTI yang cocok berdasarkan ciri fisik di JSON
        compatible_mbtis = self._map_physical_to_mbti(data)
        
        # Daftar semua MBTI
        all_mbtis = ["INTJ", "INTP", "ENTJ", "ENTP", "INFJ", "INFP", "ENFJ", "ENFP", 
                     "ISTJ", "ISFJ", "ESTJ", "ESFJ", "ISTP", "ISFP", "ESTP", "ESFP"]
        
        incompatible_mbtis = [m for m in all_mbtis if m not in compatible_mbtis]

        # 3. Positive vs Negative Sampling untuk Training AI
        if random.random() > 0.5:
            # POSITIVE SAMPLE: Baju ini COCOK untuk MBTI ini
            mbti_target = random.choice(compatible_mbtis)
            label = torch.tensor([1.0], dtype=torch.float32)
        else:
            # NEGATIVE SAMPLE: Baju ini TIDAK COCOK untuk MBTI ini
            mbti_target = random.choice(incompatible_mbtis)
            label = torch.tensor([0.0], dtype=torch.float32)
            
        return image_tensor, mbti_target, label


# 2. FUNGSI TRAINING UTAMA
def train_pnet():
    print("🧠 Memulai Training P-Net dengan REAL JSON O4U Dataset...")
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device yang digunakan: {device}")
    
    model = PNetRecommender(feature_dim=512).to(device)
    
    # SETUP PATH O4U DATASET
    current_dir = os.path.dirname(__file__)
    
    # Path ke folder 'image' dan file 'train.json' O4U Anda
    image_dir = os.path.abspath(os.path.join(current_dir, '../../data/raw_images/Outfit4You/image'))
    json_path = os.path.abspath(os.path.join(current_dir, '../../data/raw_images/Outfit4You/label/train.json'))
    
    if not os.path.exists(json_path):
        raise FileNotFoundError(f"File JSON O4U tidak ditemukan di {json_path}")

    dataset = O4UMBTIDataset(image_dir=image_dir, json_file_path=json_path)
    
    # Batch size 16 aman untuk RTX 4050 (6GB)
    dataloader = DataLoader(dataset, batch_size=16, shuffle=True, num_workers=2)
    
    criterion = nn.BCELoss()
    optimizer = optim.AdamW(model.parameters(), lr=1e-4, weight_decay=1e-2)
    
    epochs = 10 # Kita naikkan jadi 10 karena datanya sekarang nyata dan punya pola
    
    print("\n🚀 Memulai Training Loop...")
    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        
        loop = tqdm(dataloader, leave=True)
        
        for batch_idx, (images, mbtis, labels) in enumerate(loop):
            images = images.to(device)
            labels = labels.to(device)
            
            optimizer.zero_grad()
            predictions = model(images, mbtis[0])
            loss = criterion(predictions, labels)
            
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            loop.set_description(f"Epoch [{epoch+1}/{epochs}]")
            loop.set_postfix(loss=loss.item())
            
        print(f"✅ Epoch {epoch+1} selesai. Rata-rata Loss: {running_loss/len(dataloader):.4f}")

    # Simpan bobot asli
    save_dir = os.path.join(os.path.dirname(__file__), "weights")
    os.makedirs(save_dir, exist_ok=True)
    save_path = os.path.join(save_dir, "pnet_identis_real_v2.pth")
    torch.save(model.state_dict(), save_path)
    print(f"\n🎉 Training P-Net dengan JSON O4U Selesai! Bobot disimpan di: {save_path}")

if __name__ == '__main__':
    train_pnet()