#!/usr/bin/env python3
"""
Model preloader for Ray workers to keep Mochi pipeline warm
"""
import ray
import torch
from diffusers import MochiPipeline
import logging
import os

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - PRELOADER - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Global model instance
_mochi_pipeline = None

def get_mochi_pipeline():
    """Get the preloaded Mochi pipeline instance"""
    import time
    global _mochi_pipeline
    
    if _mochi_pipeline is None:
        logger.info("🚀 Loading Mochi pipeline for the first time...")
        start_time = time.time()
        
        _mochi_pipeline = MochiPipeline.from_pretrained("genmo/mochi-1-preview").to("cuda")
        _mochi_pipeline.enable_model_cpu_offload() 
        _mochi_pipeline.enable_vae_tiling()
        
        load_time = time.time() - start_time
        logger.info(f"✅ Mochi pipeline loaded and warmed in {load_time:.2f}s")
    else:
        logger.info("♻️  Using preloaded Mochi pipeline")
    
    return _mochi_pipeline

@ray.remote(num_gpus=1)
class MochiWorker:
    """Ray actor that keeps the model loaded in memory"""
    
    def __init__(self):
        self.pipeline = None
        self._warmup()
    
    def _warmup(self):
        """Load and warm up the model"""
        import time
        logger.info("🔥 Warming up Mochi pipeline...")
        start_time = time.time()
        
        self.pipeline = MochiPipeline.from_pretrained("genmo/mochi-1-preview").to("cuda")
        self.pipeline.enable_model_cpu_offload()
        self.pipeline.enable_vae_tiling()
        
        load_time = time.time() - start_time
        logger.info(f"✅ MochiWorker pipeline warmed up in {load_time:.2f}s")
    
    def generate_video(self, job_id: str, prompt: str) -> str:
        """Generate video using the pre-loaded model"""
        import redis
        import json
        import time
        from diffusers.utils import export_to_video
        
        logger.info(f"🎬 MochiWorker generating video for job {job_id}")
        
        # Connect to Redis
        rdb = redis.Redis(
            host=os.getenv("REDIS_HOST", "redis-service"),
            port=int(os.getenv("REDIS_PORT", "6379")),
            db=int(os.getenv("REDIS_DB", "0"))
        )
        
        # Update status to RUNNING
        job_data = json.loads(rdb.get(job_id))
        job_data["status"] = "RUNNING"
        rdb.set(job_id, json.dumps(job_data))
        
        try:
            output_path = f"/data/{job_id}.mp4"
            
            # Generate video (model already loaded!)
            gen_start_time = time.time()
            with torch.autocast("cuda", torch.bfloat16, cache_enabled=False):
                result = self.pipeline(prompt, num_frames=84)
                frames = result.frames[0]
            gen_time = time.time() - gen_start_time
            
            # Export video
            export_start_time = time.time()
            export_to_video(frames, output_path, fps=30)
            export_time = time.time() - export_start_time
            
            # Update status to COMPLETED
            job_data["status"] = "COMPLETED"
            job_data["output"] = output_path
            rdb.set(job_id, json.dumps(job_data))
            
            logger.info(f"✅ MochiWorker completed job {job_id} - generation: {gen_time:.2f}s, export: {export_time:.2f}s")
            return output_path
            
        except Exception as e:
            logger.error(f"💥 MochiWorker failed for job {job_id}: {e}")
            job_data["status"] = "FAILED"
            job_data["error"] = str(e)
            rdb.set(job_id, json.dumps(job_data))
            raise

if __name__ == "__main__":
    # Test the preloader
    import time
    
    ray.init(address="ray://ray-head-service:10001", ignore_reinit_error=True)
    
    # Create a warm worker
    worker = MochiWorker.remote()
    
    # Keep it running
    logger.info("🔄 MochiWorker is ready and keeping model warm...")
    
    # Test generation
    test_result = ray.get(worker.generate_video.remote("test-job", "A cat walking"))
    logger.info(f"🧪 Test result: {test_result}")