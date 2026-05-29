from pydantic import BaseModel
from typing import List, Dict, Any, Optional

# Schemas untuk Endpoint /scan (YOLOv11)
class DetectedItem(BaseModel):
    category: str
    color_dominant: str
    confidence: float
    bounding_box: Dict[str, int] # {"x1": 0, "y1": 0, "x2": 0, "y2": 0}

class ScanResponse(BaseModel):
    status: str
    data: Dict[str, Any] # Berisi 'items_detected' dan list dari 'predictions'

# Schemas untuk Endpoint/recommend (P-Net)
class RecommendRequest(BaseModel):
    mbti: str
    wardrobe_item_ids: List[str]

class OutfitRecommendation(BaseModel):
    top_id: str
    bottom_id: str
    match_score: float

class RecommendResponse(BaseModel):
    status: str
    mbti_analyzed: str
    style_matched: str
    recommendations: List[OutfitRecommendation]