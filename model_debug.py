#!/usr/bin/env python3
import ray
import time
import os

ray_address = os.getenv("RAY_ADDRESS", "ray://ray-head-service:10001") 
ray.init(address=ray_address, ignore_reinit_error=True)

@ray.remote(num_gpus=1)
def test_model_loading():
    print("🚀 Starting model loading test...")
    import torch
    print(f"🔧 CUDA available: {torch.cuda.is_available()}")
    print(f"🔧 CUDA devices: {torch.cuda.device_count()}")
    
    if torch.cuda.is_available():
        print(f"🔧 Current device: {torch.cuda.current_device()}")
        print(f"🔧 Device name: {torch.cuda.get_device_name(0)}")
    
    try:
        print("📦 Importing diffusers...")
        from diffusers import MochiPipeline
        print("✅ Diffusers imported successfully")
        
        print("🔄 Loading Mochi pipeline...")
        # Test with a timeout to see if this is where it hangs
        pipe = MochiPipeline.from_pretrained("genmo/mochi-1-preview")
        print("✅ Pipeline loaded from pretrained")
        
        print("🎯 Moving to CUDA...")
        pipe = pipe.to("cuda")
        print("✅ Pipeline moved to CUDA")
        
        print("🚀 Enabling optimizations...")
        pipe.enable_model_cpu_offload()
        pipe.enable_vae_tiling()
        print("✅ Optimizations enabled")
        
        return "✅ Model loading completed successfully"
        
    except Exception as e:
        return f"❌ Model loading failed: {str(e)}"

print("📤 Submitting model loading test...")
future = test_model_loading.remote()

print("⏳ Waiting for model loading (this may take several minutes)...")
try:
    result = ray.get(future, timeout=300)  # 5 minute timeout
    print(f"Result: {result}")
except ray.exceptions.GetTimeoutError:
    print("❌ Model loading timed out after 5 minutes")
except Exception as e:
    print(f"❌ Model loading failed: {e}")