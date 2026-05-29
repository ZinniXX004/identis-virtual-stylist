import os
from ultralytics import YOLO

def train_yolov11_fashion():
    print("🚀 Memulai proses Fine-Tuning YOLOv11 untuk Fashion IDENTIS...")
    
    # 1. Load model pre-trained (Nano version - sangat ringan dan cepat untuk mobile)
    # File yolo11n.pt akan otomatis di-download jika belum ada di folder weights/
    weight_path = os.path.join(os.path.dirname(__file__), 'weights', 'yolo11n.pt')
    model = YOLO(weight_path)
    
    # 2. Tentukan path ke file konfigurasi YAML dataset Anda
    # TODO: Ganti path ini ke lokasi file fashion_dataset.yaml Anda yang sebenarnya nanti
    current_dir = os.path.dirname(__file__)
    # dataset_yaml_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../data/raw_images/fashion_datasets.yaml'))
    dataset_yaml_path = os.path.abspath(os.path.join(current_dir, '../../data/raw_images/fashion_dataset_dummy.yaml'))
    
    # Pastikan file yaml ada sebelum training (Di-comment dulu jika ingin test run tanpa dataset)
    # if not os.path.exists(dataset_yaml_path):
    #     raise FileNotFoundError(f"File dataset YAML tidak ditemukan di: {dataset_yaml_path}")
    
    # 3. Mulai Training (Aman untuk RTX 4050 6GB VRAM)
    try:
        results = model.train(
            data=dataset_yaml_path,
            epochs=50,               # Jumlah iterasi pelatihan (bisa dinaikkan ke 100 nanti)
            imgsz=640,               # Resolusi gambar standar YOLO
            batch=8,                 # Batch size 8 aman untuk VRAM 6GB
            device=0,                # 0 = Memaksa menggunakan GPU RTX 4050
            workers=4,               # Jumlah thread CPU untuk memuat data
            project='runs/fashion',  # Folder tempat menyimpan hasil training
            name='yolo_identis_v1',  # Nama eksperimen
            save=True,               # Simpan model terbaik (.pt)
            pretrained=True          # Gunakan pengetahuan awal COCO (Transfer Learning)
        )
        print("✅ Training YOLOv11 Selesai! Model terbaik tersimpan di runs/fashion/yolo_identis_v1/weights/best.pt")
        
    except Exception as e:
        print(f"❌ Terjadi kesalahan saat training: {e}")

if __name__ == '__main__':
    train_yolov11_fashion()