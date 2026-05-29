import os
import cv2
from ultralytics import YOLO
from .utils_color import extract_dominant_color

class WardrobeScanner:
    def __init__(self, model_weight='yolo11n.pt'):
        weight_path = os.path.join(os.path.dirname(__file__), 'weights', model_weight)
        os.makedirs(os.path.dirname(weight_path), exist_ok=True)
        self.model = YOLO(weight_path)
        
    def detect_item(self, image_path, conf_threshold=0.5):
        # Jalankan inferensi dengan YOLO
        results = self.model.predict(source=image_path, conf=conf_threshold, device=0, verbose=False)
        
        # Baca gambar asli menggunakan OpenCV (untuk di-crop warnanya nanti)
        original_img = cv2.imread(image_path)
        
        detected_items = []
        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = box.xyxy[0].int().tolist()
                cls_id = int(box.cls[0])
                conf = float(box.conf[0])
                category_name = self.model.names[cls_id]
                
                # --- PROSES WARNA ---
                # 1. Potong (Crop) gambar asli khusus di area bounding box baju ini
                cropped_img = original_img[y1:y2, x1:x2]
                
                # 2. Ekstrak warna dari potongan baju tersebut
                color = extract_dominant_color(cropped_img)
                
                detected_items.append({
                    "category": category_name,
                    "color_dominant": color, # <-- Warna kini asli, bukan hardcode!
                    "confidence": round(conf, 2),
                    "bounding_box": {"x1": x1, "y1": y1, "x2": x2, "y2": y2}
                })
                
        return detected_items