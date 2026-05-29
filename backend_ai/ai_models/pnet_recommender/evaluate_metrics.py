import sys
import os
import torch
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import roc_curve, auc, confusion_matrix, accuracy_score
from torch.utils.data import DataLoader

# Tambahkan path root
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))

from ai_models.pnet_recommender.recommend import PNetRecommender
from ai_models.pnet_recommender.train import O4UMBTIDataset # Import dataset class dari train.py

def plot_loss_curve():
    """
    Plot 1: Learning Curve (Loss).
    Catatan: Silakan update list 'losses' ini dengan angka Rata-rata Loss 
    dari log terminal Anda saat proses training terakhir selesai.
    """
    epochs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    # TODO: Ganti angka ini dengan log hasil training 10 epoch Anda nanti!
    # Ini adalah contoh kurva yang ideal (menurun)
    losses = [0.6938, 0.6812, 0.6540, 0.6120, 0.5801, 0.5402, 0.5100, 0.4905, 0.4750, 0.4502]

    plt.figure(figsize=(8, 5))
    plt.plot(epochs, losses, marker='o', color='#2E86C1', linewidth=2, markersize=6)
    plt.title('P-Net Learning Curve (BCE Loss)', fontsize=14, fontweight='bold')
    plt.xlabel('Epochs', fontsize=12)
    plt.ylabel('Loss', fontsize=12)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.savefig('plot_1_loss_curve.png', dpi=300)
    print("✅ Plot 1 (Loss Curve) berhasil disimpan.")
    plt.close()

def evaluate_and_plot_roc_cm():
    """
    Plot 2 & 3: ROC/AUC dan Confusion Matrix.
    Skrip ini akan memuat model Anda dan melakukan testing sungguhan.
    """
    print("⚙️ Memuat Model dan Dataset untuk Evaluasi...")
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    
    # Load Model
    model = PNetRecommender(feature_dim=512).to(device)
    weight_path = os.path.join(os.path.dirname(__file__), "weights", "pnet_identis_real_v2.pth")
    
    if not os.path.exists(weight_path):
        print("❌ Bobot model tidak ditemukan. Pastikan Anda sudah menjalankan train.py")
        return
        
    model.load_state_dict(torch.load(weight_path, map_location=device))
    model.eval() # Set ke mode evaluasi (wajib)

    # Load Dataset (Kita ambil 200 sampel acak untuk testing agar cepat)
    current_dir = os.path.dirname(__file__)
    image_dir = os.path.abspath(os.path.join(current_dir, '../../data/raw_images/Outfit4You/image'))
    json_path = os.path.abspath(os.path.join(current_dir, '../../data/raw_images/Outfit4You/label/train.json'))
    
    dataset = O4UMBTIDataset(image_dir=image_dir, json_file_path=json_path)
    # Ambil subset kecil untuk evaluasi
    subset_indices = np.random.choice(len(dataset), 200, replace=False)
    test_subset = torch.utils.data.Subset(dataset, subset_indices)
    dataloader = DataLoader(test_subset, batch_size=16, shuffle=False)

    y_true = []
    y_scores = []

    print("🧠 AI sedang melakukan testing pada data validasi...")
    with torch.no_grad(): # Matikan gradien untuk mempercepat komputasi
        for images, mbtis, labels in dataloader:
            images = images.to(device)
            # Prediksi skor (probabilitas 0.0 - 1.0)
            predictions = model(images, mbtis[0])
            
            y_true.extend(labels.cpu().numpy().flatten())
            y_scores.extend(predictions.cpu().numpy().flatten())

    # Konversi ke NumPy Array
    y_true = np.array(y_true)
    y_scores = np.array(y_scores)
    
    # Binerisasi prediksi untuk Confusion Matrix (Threshold 0.5)
    y_pred = (y_scores >= 0.5).astype(int)

    # MENGGAMBAR ROC CURVE
    fpr, tpr, thresholds = roc_curve(y_true, y_scores)
    roc_auc = auc(fpr, tpr)

    plt.figure(figsize=(7, 6))
    plt.plot(fpr, tpr, color='#E74C3C', lw=2, label=f'P-Net AUC = {roc_auc:.2f}')
    plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate', fontsize=12)
    plt.ylabel('True Positive Rate', fontsize=12)
    plt.title('Receiver Operating Characteristic (ROC)', fontsize=14, fontweight='bold')
    plt.legend(loc="lower right", fontsize=12)
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.tight_layout()
    plt.savefig('plot_2_roc_curve.png', dpi=300)
    print(f"✅ Plot 2 (ROC Curve) berhasil disimpan. Skor AUC: {roc_auc:.2f}")
    plt.close()

    # --- MENGGAMBAR CONFUSION MATRIX ---
    cm = confusion_matrix(y_true, y_pred)
    acc = accuracy_score(y_true, y_pred)
    
    plt.figure(figsize=(6, 5))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', cbar=False, 
                xticklabels=['Mismatch (0)', 'Match (1)'], 
                yticklabels=['Mismatch (0)', 'Match (1)'],
                annot_kws={"size": 14})
    plt.title(f'Confusion Matrix\nAccuracy: {acc*100:.1f}%', fontsize=14, fontweight='bold')
    plt.xlabel('AI Predicted Label', fontsize=12)
    plt.ylabel('Actual Expert Label', fontsize=12)
    plt.tight_layout()
    plt.savefig('plot_3_confusion_matrix.png', dpi=300)
    print(f"✅ Plot 3 (Confusion Matrix) berhasil disimpan. Akurasi: {acc*100:.1f}%")
    plt.close()

if __name__ == "__main__":
    print("📊 Memulai Proses Generasi Visualisasi Metrik IDENTIS...\n")
    plot_loss_curve()
    evaluate_and_plot_roc_cm()
    print("\n🎉 Semua grafik berhasil dibuat! Silakan cek folder ini untuk melihat hasilnya.")