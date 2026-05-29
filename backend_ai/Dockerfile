# Gunakan base image Python 3.14 yang slim untuk mengurangi ukuran (Debian-based)
FROM python:3.14.4-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system dependencies (Wajib untuk OpenCV dan PyTorch)
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements terlebih dahulu untuk caching Docker layers
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy seluruh source code backend_ai ke dalam container
COPY . .

# Expose port untuk FastAPI
EXPOSE 8000

# Command untuk menjalankan FastAPI via Uvicorn
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]