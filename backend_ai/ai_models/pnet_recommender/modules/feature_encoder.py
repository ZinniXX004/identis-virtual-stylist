import torch
import torch.nn as nn
from torchvision.models import resnet18, ResNet18_Weights

class FeatureEncoder(nn.Module):
    def __init__(self, output_dim=512):
        """
        Mengekstrak fitur visual pakaian menjadi Vektor Embedding.
        Sesuai Paper: Personalized Fashion Recommendation via Deep Personality Learning.
        """
        super(FeatureEncoder, self).__init__()
        
        # 1. Load Pre-trained ResNet18
        # Kita pakai pre-trained ImageNet sebagai baseline pengetahuan visual AI
        resnet = resnet18(weights=ResNet18_Weights.IMAGENET1K_V1)
        
        # 2. Buang layer classification terakhir (FC) karena kita hanya butuh fiturnya
        self.backbone = nn.Sequential(*list(resnet.children())[:-1])
        
        # 3. Layer linear untuk menyesuaikan dimensi output (Paper menggunakan 'd' dimensi)
        self.fc = nn.Linear(resnet.fc.in_features, output_dim)
        
    def forward(self, x):
        """
        Input: Tensor gambar (B, C, H, W)
        Output: Tensor Vektor 2D (B, output_dim)
        """
        # Ekstraksi fitur spasial
        features = self.backbone(x)
        
        # Flattening (meratakan matrix fitur menjadi vektor)
        features_flat = torch.flatten(features, 1)
        
        # Transformasi akhir
        embeddings = self.fc(features_flat)
        return embeddings