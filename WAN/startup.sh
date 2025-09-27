#!/bin/bash
set -e

echo "Starting ComfyUI WAN 2.2 + LightX2V Environment Setup..."

# Function to check if a file exists and has reasonable size (>100MB for models, >10MB for LoRAs)
check_model() {
    local file="$1"
    local min_size="${2:-104857600}"  # Default 100MB, can override for smaller files
    if [[ -f "$file" && $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0) -gt $min_size ]]; then
        return 0
    else
        return 1
    fi
}

# Setup ComfyUI if not exists
if [ ! -d "$COMFY_PATH" ]; then
    echo "Installing ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_PATH"
    
    echo "Installing Python requirements..."
    pip3 install -r "$COMFY_PATH/requirements.txt"
    
    echo "Installing essential custom nodes..."
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git "$COMFY_PATH/custom_nodes/ComfyUI-Manager"
    git clone https://github.com/city96/ComfyUI-GGUF.git "$COMFY_PATH/custom_nodes/ComfyUI-GGUF"
    
    # Video workflow nodes
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "$COMFY_PATH/custom_nodes/ComfyUI-VideoHelperSuite"
    git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git "$COMFY_PATH/custom_nodes/ComfyUI-Frame-Interpolation"
else
    echo "ComfyUI already exists, skipping installation..."
fi

# Create model directory structure
echo "Setting up model directories..."
mkdir -p "${PERSISTENT_MODEL_PATH}/text_encoders"
mkdir -p "${PERSISTENT_MODEL_PATH}/vae"
mkdir -p "${PERSISTENT_MODEL_PATH}/diffusion_models"
mkdir -p "${PERSISTENT_MODEL_PATH}/unet"
mkdir -p "${PERSISTENT_MODEL_PATH}/loras"
mkdir -p "${PERSISTENT_MODEL_PATH}/clip"
mkdir -p "${PERSISTENT_MODEL_PATH}/controlnet"

# WAN 2.2 Core Models
echo "Checking for WAN 2.2 core models..."

# Text encoder
if ! check_model "${PERSISTENT_MODEL_PATH}/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"; then
    echo "Downloading UMT5 text encoder model..."
    wget -P "${PERSISTENT_MODEL_PATH}/text_encoders" \
        https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
fi

# VAE
if ! check_model "${PERSISTENT_MODEL_PATH}/vae/wan_2.1_vae.safetensors"; then
    echo "Downloading WAN VAE model..."
    wget -P "${PERSISTENT_MODEL_PATH}/vae" \
        https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
fi

# High noise diffusion model
if ! check_model "${PERSISTENT_MODEL_PATH}/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors"; then
    echo "Downloading WAN high noise diffusion model..."
    wget -P "${PERSISTENT_MODEL_PATH}/diffusion_models" \
        https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors
fi

# Low noise diffusion model
if ! check_model "${PERSISTENT_MODEL_PATH}/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors"; then
    echo "Downloading WAN low noise diffusion model..."
    wget -P "${PERSISTENT_MODEL_PATH}/diffusion_models" \
        https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors
fi

# LightX2V LoRA Models (for faster 4-step inference)
echo "Checking for LightX2V LoRA models..."

# Low noise LoRA (use smaller size check for LoRAs - 10MB)
if ! check_model "${PERSISTENT_MODEL_PATH}/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" 10485760; then
    echo "Downloading LightX2V low noise LoRA..."
    wget -P "${PERSISTENT_MODEL_PATH}/loras" \
        https://huggingface.co/kijai/LightX2V-ComfyUI/resolve/main/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors
fi

# High noise LoRA
if ! check_model "${PERSISTENT_MODEL_PATH}/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" 10485760; then
    echo "Downloading LightX2V high noise LoRA..."
    wget -P "${PERSISTENT_MODEL_PATH}/loras" \
        https://huggingface.co/kijai/LightX2V-ComfyUI/resolve/main/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors
fi

# Optional: GGUF models for memory efficiency (if you want them as backup)
if ! check_model "${PERSISTENT_MODEL_PATH}/unet/wan2.2_i2v_high_noise_14B_Q2_K.gguf"; then
    echo "Downloading WAN high noise GGUF model (optional backup)..."
    wget -O "${PERSISTENT_MODEL_PATH}/unet/wan2.2_i2v_high_noise_14B_Q2_K.gguf" \
        "https://huggingface.co/bullerwins/Wan2.2-I2V-A14B-GGUF/resolve/main/wan2.2_i2v_high_noise_14B_Q2_K.gguf?download=true"
fi

if ! check_model "${PERSISTENT_MODEL_PATH}/unet/wan2.2_i2v_low_noise_14B_Q2_K.gguf"; then
    echo "Downloading WAN low noise GGUF model (optional backup)..."
    wget -O "${PERSISTENT_MODEL_PATH}/unet/wan2.2_i2v_low_noise_14B_Q2_K.gguf" \
        "https://huggingface.co/bullerwins/Wan2.2-I2V-A14B-GGUF/resolve/main/wan2.2_i2v_low_noise_14B_Q2_K.gguf?download=true"
fi

# Link models to ComfyUI
echo "Linking models to ComfyUI..."
rm -rf "$COMFY_PATH/models/text_encoders" "$COMFY_PATH/models/vae" "$COMFY_PATH/models/diffusion_models" "$COMFY_PATH/models/unet" "$COMFY_PATH/models/loras" "$COMFY_PATH/models/clip" "$COMFY_PATH/models/controlnet"
ln -sf "${PERSISTENT_MODEL_PATH}/text_encoders" "$COMFY_PATH/models/text_encoders"
ln -sf "${PERSISTENT_MODEL_PATH}/vae" "$COMFY_PATH/models/vae"
ln -sf "${PERSISTENT_MODEL_PATH}/diffusion_models" "$COMFY_PATH/models/diffusion_models"
ln -sf "${PERSISTENT_MODEL_PATH}/unet" "$COMFY_PATH/models/unet"
ln -sf "${PERSISTENT_MODEL_PATH}/loras" "$COMFY_PATH/models/loras"
ln -sf "${PERSISTENT_MODEL_PATH}/clip" "$COMFY_PATH/models/clip"
ln -sf "${PERSISTENT_MODEL_PATH}/controlnet" "$COMFY_PATH/models/controlnet"

echo "✅ WAN 2.2 + LightX2V Environment ready!"
echo "📁 ComfyUI: $COMFY_PATH"
echo "🤖 Models: $PERSISTENT_MODEL_PATH"
echo "🎬 WAN 2.2: Ready for video generation"
echo "⚡ LightX2V: Ready for 4-step fast inference"
echo "📝 Available models:"
echo "   - UMT5 Text Encoder"
echo "   - WAN VAE"
echo "   - High/Low Noise Diffusion Models"
echo "   - LightX2V LoRAs (4-step inference)"
echo "🚀 Starting ComfyUI server..."

exec "$@"