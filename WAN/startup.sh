#!/bin/bash
set -e

echo "🚀 Downloading WAN 2.2 models for ComfyUI workflow..."

# Base path for ComfyUI models
COMFY_MODELS_PATH="/workspace/ComfyUI/models"

# Function to check if a file exists and has reasonable size
check_model() {
    local file="$1"
    local min_size="${2:-104857600}"  # Default 100MB, can override for smaller files
    if [[ -f "$file" && $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0) -gt $min_size ]]; then
        return 0
    else
        return 1
    fi
}

# Create model directories
echo "📁 Creating model directories..."
mkdir -p "${COMFY_MODELS_PATH}/text_encoders"
mkdir -p "${COMFY_MODELS_PATH}/diffusion_models"
mkdir -p "${COMFY_MODELS_PATH}/vae"
mkdir -p "${COMFY_MODELS_PATH}/loras"

echo "🔍 Checking and downloading required models..."

# Text Encoder
echo "📝 Checking UMT5 text encoder..."
if ! check_model "${COMFY_MODELS_PATH}/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"; then
    echo "⬇️  Downloading UMT5 text encoder model..."
    wget -P "${COMFY_MODELS_PATH}/text_encoders" \
        https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
    echo "✅ UMT5 text encoder downloaded"
else
    echo "✅ UMT5 text encoder already exists"
fi

# VAE
echo "🎨 Checking WAN VAE..."
if ! check_model "${COMFY_MODELS_PATH}/vae/wan_2.1_vae.safetensors"; then
    echo "⬇️  Downloading WAN VAE model..."
    wget -P "${COMFY_MODELS_PATH}/vae" \
        https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
    echo "✅ WAN VAE downloaded"
else
    echo "✅ WAN VAE already exists"
fi

# High Noise Diffusion Model
echo "🔊 Checking high noise diffusion model..."
if ! check_model "${COMFY_MODELS_PATH}/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors"; then
    echo "⬇️  Downloading high noise diffusion model..."
    wget -P "${COMFY_MODELS_PATH}/diffusion_models" \
        https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors
    echo "✅ High noise diffusion model downloaded"
else
    echo "✅ High noise diffusion model already exists"
fi

# Low Noise Diffusion Model
echo "🔇 Checking low noise diffusion model..."
if ! check_model "${COMFY_MODELS_PATH}/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors"; then
    echo "⬇️  Downloading low noise diffusion model..."
    wget -P "${COMFY_MODELS_PATH}/diffusion_models" \
        https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors
    echo "✅ Low noise diffusion model downloaded"
else
    echo "✅ Low noise diffusion model already exists"
fi

# LightX2V LoRA - Low Noise (use smaller size check for LoRAs - 10MB)
echo "⚡ Checking LightX2V low noise LoRA..."
if ! check_model "${COMFY_MODELS_PATH}/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" 10485760; then
    echo "⬇️  Downloading LightX2V low noise LoRA..."
    wget -P "${COMFY_MODELS_PATH}/loras" \
        https://huggingface.co/kijai/LightX2V-ComfyUI/resolve/main/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors
    echo "✅ LightX2V low noise LoRA downloaded"
else
    echo "✅ LightX2V low noise LoRA already exists"
fi

# LightX2V LoRA - High Noise
echo "⚡ Checking LightX2V high noise LoRA..."
if ! check_model "${COMFY_MODELS_PATH}/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" 10485760; then
    echo "⬇️  Downloading LightX2V high noise LoRA..."
    wget -P "${COMFY_MODELS_PATH}/loras" \
        https://huggingface.co/kijai/LightX2V-ComfyUI/resolve/main/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors
    echo "✅ LightX2V high noise LoRA downloaded"
else
    echo "✅ LightX2V high noise LoRA already exists"
fi

echo ""
echo "🎉 All WAN 2.2 models ready!"
echo "📁 Models location: ${COMFY_MODELS_PATH}"
echo "📋 Downloaded models:"
echo "   ✅ UMT5 Text Encoder"
echo "   ✅ WAN VAE"
echo "   ✅ High Noise Diffusion Model"
echo "   ✅ Low Noise Diffusion Model"
echo "   ✅ LightX2V Low Noise LoRA"
echo "   ✅ LightX2V High Noise LoRA"
echo ""
echo "🚀 Ready for WAN 2.2 video generation workflows!"

# Display file sizes for verification
echo ""
echo "📊 Model file sizes:"
find "${COMFY_MODELS_PATH}" -name "*.safetensors" -exec ls -lh {} \; | awk '{print $5 " " $9}' | sort