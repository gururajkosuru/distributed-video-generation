#FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-runtime
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libgl1 \
    curl \
    redis-tools \
    python3 \
    python3-pip \
    python3-dev \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy app files
COPY . /app

# Install Python dependencies
RUN pip install --upgrade pip

# Install CUDA-specific PyTorch
#RUN pip install \
#    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Install app dependencies
RUN pip install \
    diffusers transformers accelerate \
    fastapi uvicorn \
    imageio imageio-ffmpeg \
    sentencepiece \
    redis \
    ray[client] \
    pydantic

# Expose FastAPI port
EXPOSE 8000

# Run app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

