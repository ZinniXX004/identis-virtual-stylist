# 📄 IDENTIS - API Contract and Mock Data

Dokumen ini berisi kesepakatan struktur komunikasi antara **Frontend (Flutter)** dan **Backend (FastAPI + AI)**. Selama masa development, Frontend dapat melakukan HTTP Request ke server lokal (localhost).

**Base URL (Local Development):** `http://127.0.0.1:8000`

---

## 1. Wardrobe Scanner (Computer Vision)

Endpoint ini digunakan ketika user mengambil/mengunggah foto pakaian untuk mendeteksi jenis baju dan warnanya menggunakan YOLOv11 dan K-Means.

* **Endpoint:** `/scan`
* **Method:** `POST`
* **Content-Type:** `multipart/form-data`

### Request Body

| Field    | Type             | Description                        |
| :------- | :--------------- | :--------------------------------- |
| `file` | `File (Image)` | Gambar pakaian (.jpg, .jpeg, .png) |

### Success Response (200 OK)

```json
{
  "status": "success",
  "data": {
    "items_detected": 1,
    "predictions": [
      {
        "category": "Top",
        "color_dominant": "Soft Grey",
        "confidence": 0.96,
        "bounding_box": {
          "x1": 10,
          "y1": 20,
          "x2": 210,
          "y2": 270
        }
      }
    ]
  }
}
```
*(Catatan Frontend: Gunakan nilai category dan color_dominant untuk mengisi metadata di lemari digital).*

## 2. P-Net Magic Recommender (AI Styling)

Endpoint ini digunakan ketika user meminta rekomendasi Mix & Match harian. AI akan menganalisa MBTI dan ID pakaian yang ada di lemari lokal HP user.

- Endpoint: /recommend
- Method: POST
- Content-Type: application/json

### Request Body
```json
{
  "mbti": "INFP",
  "wardrobe_item_ids": [
    "item_top_01",
    "item_top_02",
    "item_bottom_01",
    "item_bottom_02"
  ]
}
```
### Success Response (200 OK)
```json
{
  "status": "success",
  "mbti_analyzed": "INFP",
  "style_matched": "Fairy/Casual",
  "recommendations": [
    {
      "top_id": "item_top_01",
      "bottom_id": "item_bottom_02",
      "match_score": 0.92
    }
  ]
}
```
*(Catatan Frontend: Tangkap top_id dan bottom_id dari JSON ini, lalu tampilkan gambarnya dari Local Storage HP user dengan layout Flat-lay).*

---