# Use RunPod's PyTorch base image for deployment
FROM runpod/pytorch:2.2.0-py3.11-cuda12.1.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Define paths as environment variables
ENV WORKSPACE_PATH="/workspace"
ENV COMFY_PATH="/workspace/ComfyUI"
ENV PERSISTENT_MODEL_PATH="/workspace/comfyui/models"

# Install system dependencies in a single layer
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    vim \
    nano \
    htop \
    ffmpeg \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Install Python video libraries
RUN pip3 install --no-cache-dir \
    opencv-python \
    moviepy \
    pillow-simd \
    huggingface-hub

# Copy startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# Expose ports for ComfyUI and Jupyter (RunPod standard)
EXPOSE 8188 8888

# Set working directory to workspace (where persistent volume is mounted)
WORKDIR ${WORKSPACE_PATH}

# Set entrypoint
ENTRYPOINT ["/startup.sh"]
CMD ["python3", "/workspace/ComfyUI/main.py", "--listen", "0.0.0.0", "--port", "8188"]
