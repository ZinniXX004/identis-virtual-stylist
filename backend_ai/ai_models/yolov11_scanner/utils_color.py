import cv2
import numpy as np

# Kamus Warna Fashion (Diambil dari standar palet baju)
FASHION_COLORS = {
    "Pure White": (255, 255, 255),
    "Charcoal Black": (40, 40, 40),
    "Soft Grey": (160, 160, 160),
    "Navy Blue": (10, 10, 50),
    "Denim Blue": (40, 90, 150),
    "Crimson Red": (180, 20, 40),
    "Olive Green": (80, 100, 50),
    "Beige/Khaki": (220, 210, 180),
    "Mustard": (205, 165, 30),
    "Maroon": (128, 0, 0),
    "Pastel Pink": (255, 200, 200)
}

def rgb_to_fashion_name(rgb_color):
    """
    Menghitung jarak Euclidean terkecil antara warna yang dideteksi 
    dengan kamus warna fashion kita.
    """
    min_dist = float('inf')
    closest_name = "Unknown"
    
    for name, color_val in FASHION_COLORS.items():
        # Hitung jarak Euclidean (r1-r2)^2 + (g1-g2)^2 + (b1-b2)^2
        dist = sum((a - b) ** 2 for a, b in zip(rgb_color, color_val))
        if dist < min_dist:
            min_dist = dist
            closest_name = name
            
    return closest_name

def extract_dominant_color(image_bgr, k=3):
    """
    Mengekstrak warna dominan menggunakan algoritma K-Means Clustering dari OpenCV.
    image_bgr: potongan gambar baju hasil deteksi YOLO (dalam format BGR dari cv2).
    """
    if image_bgr is None or image_bgr.size == 0:
        return "Unknown"

    # Konversi BGR (format bawaan OpenCV) ke RGB
    image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
    
    # Ubah bentuk array gambar (Height, Width, 3) menjadi (N_pixels, 3)
    pixels = image_rgb.reshape((-1, 3)).astype(np.float32)

    # Definisikan kriteria untuk algoritma K-Means OpenCV
    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 10, 1.0)
    
    # Jalankan K-Means
    _, labels, centers = cv2.kmeans(pixels, k, None, criteria, 10, cv2.KMEANS_RANDOM_CENTERS)
    
    # Cari klaster (label) warna yang paling banyak muncul di piksel
    counts = np.bincount(labels.flatten())
    dominant_rgb = centers[np.argmax(counts)]
    
    # Terjemahkan ke nama warna fashion
    fashion_color_name = rgb_to_fashion_name(dominant_rgb)
    return fashion_color_name