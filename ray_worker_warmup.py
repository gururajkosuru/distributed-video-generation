#!/usr/bin/env python3
"""
Ray worker warmup script to preload Mochi model
This runs when Ray worker starts up to keep the model warm
"""
import os
import logging
import time
import traceback
import torch
from diffusers import MochiPipeline

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - RAY-WARMUP - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Global model cache - shared across all Ray tasks on this worker
_MOCHI_PIPELINE_CACHE = None

def preload_mochi_model():
    """Preload the Mochi model into global cache"""
    global _MOCHI_PIPELINE_CACHE
    
    if _MOCHI_PIPELINE_CACHE is not None:
        logger.info("♻️  Mochi model already preloaded")
        return _MOCHI_PIPELINE_CACHE
    
    logger.info("🔥 RAY WORKER preloading Mochi model...")
    logger.info(f"💻 Worker node: {os.uname().nodename}")
    logger.info(f"🖥️  Available GPUs: {torch.cuda.device_count()}")
    
    if torch.cuda.is_available():
        logger.info(f"🔥 CUDA device: {torch.cuda.current_device()}")
        logger.info(f"🔥 CUDA device name: {torch.cuda.get_device_name()}")
        logger.info(f"🔥 CUDA memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f}GB")
    
    start_time = time.time()
    
    try:
        # Load the model with float16 precision to reduce memory usage
        _MOCHI_PIPELINE_CACHE = MochiPipeline.from_pretrained(
            "genmo/mochi-1-preview", 
            torch_dtype=torch.float16
        ).to("cuda")
        _MOCHI_PIPELINE_CACHE.enable_model_cpu_offload()
        _MOCHI_PIPELINE_CACHE.enable_vae_tiling()
        
        load_time = time.time() - start_time
        logger.info(f"✅ RAY WORKER Mochi model preloaded in {load_time:.2f}s")
        
        # Optional: Quick warmup generation to make sure everything works
        logger.info("🧪 RAY WORKER running warmup generation...")
        warmup_start = time.time()
        try:
            with torch.autocast("cuda", torch.bfloat16, cache_enabled=False):
                # Very small test - just 4 frames
                test_result = _MOCHI_PIPELINE_CACHE("warmup test", num_frames=4)
            warmup_time = time.time() - warmup_start
            logger.info(f"✅ RAY WORKER warmup generation completed in {warmup_time:.2f}s")
        except Exception as e:
            logger.warning(f"⚠️  RAY WORKER warmup generation failed (model still loaded): {e}")
        
        logger.info("🎉 RAY WORKER ready with warm Mochi model!")
        return _MOCHI_PIPELINE_CACHE
        
    except Exception as e:
        logger.error(f"💥 RAY WORKER failed to preload Mochi model: {e}")
        logger.error(f"🔍 RAY WORKER traceback: {traceback.format_exc()}")
        raise

def get_warm_mochi_pipeline():
    """Get the preloaded Mochi pipeline"""
    global _MOCHI_PIPELINE_CACHE
    
    if _MOCHI_PIPELINE_CACHE is None:
        logger.info("🔄 RAY WORKER model not preloaded, loading now...")
        return preload_mochi_model()
    
    logger.info("♻️  RAY WORKER using preloaded warm model")
    return _MOCHI_PIPELINE_CACHE

# Preload model when this module is imported
logger.info("🚀 RAY WORKER warmup script starting...")
preload_mochi_model()
logger.info("✅ RAY WORKER warmup script completed")