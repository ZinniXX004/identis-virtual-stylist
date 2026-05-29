import torch
import torch.nn as nn

class PersonalityStyleTransformer(nn.Module):
    def __init__(self, feature_dim=512, mbti_classes=16):
        """
        Sesuai Paper P-Net (Sec 2.4 & 2.5): User-Style Matching & Transformer.
        """
        super(PersonalityStyleTransformer, self).__init__()
        
        # Embedding untuk 16 tipe MBTI (Mengubah teks 'INFP' menjadi vektor angka)
        self.mbti_embedding = nn.Embedding(num_embeddings=mbti_classes, embedding_dim=feature_dim)
        
        # Transformer Encoder Block untuk membandingkan Pakaian vs Kepribadian
        encoder_layer = nn.TransformerEncoderLayer(d_model=feature_dim, nhead=8, batch_first=True)
        self.transformer = nn.TransformerEncoder(encoder_layer, num_layers=2)
        
        # Classifier akhir untuk memprediksi Match Score (0.0 hingga 1.0)
        self.match_scorer = nn.Sequential(
            nn.Linear(feature_dim, 128),
            nn.ReLU(),
            nn.Linear(128, 1),
            nn.Sigmoid() # Memastikan skor output berada di range 0 - 1
        )

    def forward(self, outfit_features, mbti_idx):
        """
        outfit_features: Vektor baju (Batch, Feature_dim)
        mbti_idx: Index MBTI user (Contoh: INFP = index 9)
        """
        # Ambil vektor kepribadian
        mbti_vec = self.mbti_embedding(mbti_idx) # (Batch, Feature_dim)
        
        # Gabungkan vektor kepribadian dengan setiap baju untuk dianalisa Transformer
        # Format: (Batch, Sequence_length=2, Feature_dim) 
        # Dimana seq 0 = Baju, seq 1 = MBTI
        combined_features = torch.stack([outfit_features, mbti_vec], dim=1)
        
        # Transformer mencari relasi ('Apakah baju ini merepresentasikan MBTI ini?')
        transformed_out = self.transformer(combined_features)
        
        # Kita ambil representasi hasil penggabungan (misal dari elemen pertama)
        fused_representation = transformed_out[:, 0, :]
        
        # Hitung skor kecocokan
        match_score = self.match_scorer(fused_representation)
        
        return match_score