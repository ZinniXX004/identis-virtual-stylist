import torch
import torch.nn as nn
from ai_models.pnet_recommender.modules.feature_encoder import FeatureEncoder
from ai_models.pnet_recommender.modules.message_passing import OutfitMessagePassing
from ai_models.pnet_recommender.modules.transformer import PersonalityStyleTransformer

class PNetRecommender(nn.Module):
    def __init__(self, feature_dim=512):
        super(PNetRecommender, self).__init__()
        
        # Inisialisasi 3 pilar utama P-Net
        self.encoder = FeatureEncoder(output_dim=feature_dim)
        self.message_passing = OutfitMessagePassing(feature_dim=feature_dim)
        self.transformer_matcher = PersonalityStyleTransformer(feature_dim=feature_dim)
        
        # Dictionary bantuan untuk MBTI ke index
        self.mbti_map = {
            "INTJ": 0, "INTP": 1, "ENTJ": 2, "ENTP": 3,
            "INFJ": 4, "INFP": 5, "ENFJ": 6, "ENFP": 7,
            "ISTJ": 8, "ISFJ": 9, "ESTJ": 10, "ESFJ": 11,
            "ISTP": 12, "ISFP": 13, "ESTP": 14, "ESFP": 15
        }

    def forward(self, images, mbti_string):
        """
        images: Tensor kumpulan gambar baju di lemari user (Batch, 3, 224, 224)
        mbti_string: string seperti "INFP"
        """
        # 1. Ekstraksi visual baju menjadi angka
        features = self.encoder(images)
        
        # 2. Pahami relasi antar-baju di lemari (misal: mencari warna/pola yang nyambung)
        refined_features = self.message_passing(features)
        
        # 3. Ubah MBTI string ke index tensor
        idx = self.mbti_map.get(mbti_string.upper(), 5) # Default INFP jika tidak ketemu
        mbti_tensor = torch.tensor([idx] * features.size(0)).to(features.device)
        
        # 4. Cocokkan baju dengan kepribadian
        match_scores = self.transformer_matcher(refined_features, mbti_tensor)
        
        return match_scores