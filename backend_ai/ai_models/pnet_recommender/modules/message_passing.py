import torch
import torch.nn as nn
import torch.nn.functional as F

class OutfitMessagePassing(nn.Module):
    def __init__(self, feature_dim=512, num_heads=4):
        """
        Sesuai Paper P-Net (Sec 2.3): Message Passing Among Outfits.
        Menggunakan mekanisme multi-query & key matrices untuk mencari relasi 
        (attention score) antar baju di lemari.
        """
        super(OutfitMessagePassing, self).__init__()
        self.feature_dim = feature_dim
        self.num_heads = num_heads
        
        # Linear layer untuk menghitung Query, Key, dan Value (Mewakili W_q, W_k, W_v di paper)
        self.q_linear = nn.Linear(feature_dim, feature_dim)
        self.k_linear = nn.Linear(feature_dim, feature_dim)
        self.v_linear = nn.Linear(feature_dim, feature_dim)
        
        # Layer Normalization dan Feed Forward (Persamaan 5 di paper)
        self.layer_norm = nn.LayerNorm(feature_dim)
        self.ffn = nn.Sequential(
            nn.Linear(feature_dim, feature_dim * 2),
            nn.ReLU(),
            nn.Linear(feature_dim * 2, feature_dim)
        )

    def forward(self, h):
        """
        Input 'h': Tensor dari fitur baju hasil ResNet18 (Batch, Feature_Dim)
        """
        # Karena kita memproses sekumpulan baju dalam lemari (sebagai graph)
        # Kita ubah bentuknya seolah-olah menjadi sequence (1, Batch, Feature_Dim)
        h_seq = h.unsqueeze(0)
        
        Q = self.q_linear(h_seq)
        K = self.k_linear(h_seq)
        V = self.v_linear(h_seq)
        
        # Menghitung Attention Score antar baju (Persamaan 3 di paper)
        # Scaled dot-product attention
        d_k = Q.size(-1) // self.num_heads
        scores = torch.matmul(Q, K.transpose(-2, -1)) / (d_k ** 0.5)
        attention_weights = F.softmax(scores, dim=-1)
        
        # Mengupdate embedding baju dengan informasi dari baju tetangganya (Persamaan 4)
        h_updated = torch.matmul(attention_weights, V)
        h_updated = h_updated.squeeze(0)
        
        # Skip connection & Layer Normalization (Persamaan 5)
        h_norm = self.layer_norm(h_updated + h)
        
        # Feed forward + Skip connection
        out = self.layer_norm(self.ffn(h_norm) + h_norm)
        
        return out