FROM rayproject/ray:2.48.0-py310

# Install Python dependencies needed for your remote tasks
RUN pip install --upgrade pip && \
    pip install \
      diffusers transformers accelerate \
      torch torchvision torchaudio \
      sentencepiece \
      imageio imageio-ffmpeg \
      redis \
      psutil

# Set working directory
WORKDIR /app

# Copy warmup script for model preloading (from root directory)
COPY ray_worker_warmup.py /app/ray_worker_warmup.py

# Copy the backend files so Ray workers can access main.py
COPY backend/main.py /app/main.py

# Create a startup script that preloads the model when Ray worker starts
RUN echo '#!/bin/bash\n\
echo "🚀 Starting Ray worker with model preloading..."\n\
python /app/ray_worker_warmup.py &\n\
exec "$@"' > /app/start_with_warmup.sh && chmod +x /app/start_with_warmup.sh

# Use the startup script as entrypoint
ENTRYPOINT ["/app/start_with_warmup.sh"]

