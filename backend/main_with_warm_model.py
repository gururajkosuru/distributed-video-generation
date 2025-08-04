import uuid
import asyncio
from fastapi import FastAPI, BackgroundTasks, HTTPException
from pydantic import BaseModel
from typing import Dict, List
import torch
from diffusers import MochiPipeline
from diffusers.utils import export_to_video
from fastapi.responses import FileResponse
from fastapi import Depends, Path, Query
import ray
import os
import redis
import json
import time
import logging
import traceback
import psutil
import subprocess

# Setup detailed logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Global Inits
logger.info("🚀 Starting backend application with warm model actors")
ray_address = os.getenv("RAY_ADDRESS", "ray://ray-head-service:10001")
logger.info(f"🔗 Attempting to connect to Ray at: {ray_address}")

for attempt in range(10):
    try:
        ray.init(address=ray_address, ignore_reinit_error=True)
        logger.info("✅ Ray connection successful")
        logger.info(f"📊 Ray cluster resources: {ray.cluster_resources()}")
        break
    except Exception as e:
        logger.error(f"❌ Ray connection attempt {attempt + 1} failed: {e}")
        if attempt < 9:
            logger.info("⏳ Retrying Ray connection in 2 seconds...")
            time.sleep(2)
else:
    logger.critical("💥 Could not connect to Ray cluster after 10 attempts")
    raise RuntimeError("Could not connect to Ray cluster")

app = FastAPI()

# Redis connection with detailed logging
redis_host = os.getenv("REDIS_HOST", "redis-service")
redis_port = int(os.getenv("REDIS_PORT", "6379"))
redis_db = int(os.getenv("REDIS_DB", "0"))
logger.info(f"🔗 Connecting to Redis at {redis_host}:{redis_port} db={redis_db}")

try:
    rdb = redis.Redis(host=redis_host, port=redis_port, db=redis_db)
    # Test Redis connection
    rdb.ping()
    logger.info("✅ Redis connection successful")
except Exception as e:
    logger.critical(f"💥 Redis connection failed: {e}")
    raise RuntimeError(f"Could not connect to Redis: {e}")

# Job structure
class GenerateRequest(BaseModel):
    prompt: str
    account_id: str

class JobStatus(str):
    PENDING = "PENDING"
    RUNNING = "RUNNING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"

@ray.remote(num_gpus=1)
class MochiWorker:
    """Ray actor that keeps the Mochi model loaded and warm"""
    
    def __init__(self):
        self.pipeline = None
        self.worker_id = f"worker_{os.getpid()}"
        self.setup_logging()
        self.load_model()
    
    def setup_logging(self):
        """Setup logging for this worker actor"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - MOCHI-ACTOR - %(levelname)s - %(message)s',
            force=True
        )
        self.logger = logging.getLogger(f"mochi_actor_{self.worker_id}")
    
    def load_model(self):
        """Load and warm up the Mochi pipeline"""
        import time
        
        self.log_and_print(f"🔥 {self.worker_id} loading Mochi pipeline...")
        
        # Log system info
        self.log_and_print(f"💻 Worker node: {os.uname().nodename}")
        self.log_and_print(f"🖥️  Available GPUs: {torch.cuda.device_count()}")
        
        if torch.cuda.is_available():
            self.log_and_print(f"🔥 CUDA device: {torch.cuda.current_device()}")
            self.log_and_print(f"🔥 CUDA device name: {torch.cuda.get_device_name()}")
            self.log_and_print(f"🔥 CUDA memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f}GB")
        
        start_time = time.time()
        
        self.pipeline = MochiPipeline.from_pretrained("genmo/mochi-1-preview").to("cuda")
        self.pipeline.enable_model_cpu_offload()
        self.pipeline.enable_vae_tiling()
        
        load_time = time.time() - start_time
        self.log_and_print(f"✅ {self.worker_id} pipeline loaded and warmed in {load_time:.2f}s")
        
        # Optional: Run a quick warmup generation
        try:
            self.log_and_print(f"🧪 {self.worker_id} running warmup generation...")
            warmup_start = time.time()
            with torch.autocast("cuda", torch.bfloat16, cache_enabled=False):
                # Small test generation - just 4 frames
                warmup_result = self.pipeline("test", num_frames=4)
            warmup_time = time.time() - warmup_start
            self.log_and_print(f"✅ {self.worker_id} warmup completed in {warmup_time:.2f}s")
        except Exception as e:
            self.log_and_print(f"⚠️  {self.worker_id} warmup failed (model still loaded): {e}")
    
    def log_and_print(self, message):
        """Log message and print to stdout"""
        self.logger.info(message)
        print(f"MOCHI-ACTOR: {message}")
    
    def generate_video(self, job_id: str, prompt: str) -> str:
        """Generate video using the pre-loaded warm model"""
        import redis
        import json
        import time
        from diffusers.utils import export_to_video
        
        self.log_and_print(f"🎬 {self.worker_id} starting job {job_id}")
        self.log_and_print(f"📝 Prompt: {prompt}")
        
        # Connect to Redis
        redis_host = os.getenv("REDIS_HOST", "redis-service")
        redis_port = int(os.getenv("REDIS_PORT", "6379"))
        redis_db = int(os.getenv("REDIS_DB", "0"))
        
        try:
            rdb = redis.Redis(host=redis_host, port=redis_port, db=redis_db)
            rdb.ping()
            self.log_and_print(f"✅ {self.worker_id} Redis connection successful")
        except Exception as e:
            self.log_and_print(f"💥 {self.worker_id} Redis connection failed: {e}")
            raise RuntimeError(f"Redis connection failed: {e}")
        
        # Update job status to RUNNING
        try:
            job_data = json.loads(rdb.get(job_id))
            job_data["status"] = "RUNNING"
            rdb.set(job_id, json.dumps(job_data))
            self.log_and_print(f"✅ {self.worker_id} updated job {job_id} to RUNNING")
        except Exception as e:
            self.log_and_print(f"💥 {self.worker_id} failed to update job status: {e}")
            raise
        
        try:
            output_path = f"/data/{job_id}.mp4"
            self.log_and_print(f"📁 {self.worker_id} output path: {output_path}")
            
            # Generate video using pre-loaded pipeline (NO LOADING TIME!)
            self.log_and_print(f"🎬 {self.worker_id} generating video with warm model...")
            gen_start_time = time.time()
            
            with torch.autocast("cuda", torch.bfloat16, cache_enabled=False):
                result = self.pipeline(prompt, num_frames=84)
                frames = result.frames[0]
            
            gen_time = time.time() - gen_start_time
            self.log_and_print(f"✅ {self.worker_id} video generation completed in {gen_time:.2f}s")
            
            # Export video
            self.log_and_print(f"💾 {self.worker_id} exporting video...")
            export_start_time = time.time()
            export_to_video(frames, output_path, fps=30)
            export_time = time.time() - export_start_time
            self.log_and_print(f"✅ {self.worker_id} video exported in {export_time:.2f}s")
            
            # Verify output file
            if os.path.exists(output_path):
                file_size = os.path.getsize(output_path)
                self.log_and_print(f"✅ {self.worker_id} output file created: {output_path} ({file_size} bytes)")
            else:
                self.log_and_print(f"❌ {self.worker_id} output file NOT created: {output_path}")
                raise RuntimeError(f"Output file not created: {output_path}")
            
            # Update status to COMPLETED
            job_data["status"] = "COMPLETED"
            job_data["output"] = output_path
            rdb.set(job_id, json.dumps(job_data))
            self.log_and_print(f"✅ {self.worker_id} updated job {job_id} to COMPLETED")
            
            total_time = gen_time + export_time
            self.log_and_print(f"🎉 {self.worker_id} job {job_id} completed in {total_time:.2f}s (generation: {gen_time:.2f}s, export: {export_time:.2f}s)")
            
            return output_path
            
        except Exception as e:
            self.log_and_print(f"💥 {self.worker_id} generation failed: {str(e)}")
            self.log_and_print(f"🔍 {self.worker_id} traceback: {traceback.format_exc()}")
            
            try:
                # Update status to FAILED
                job_data["status"] = "FAILED"
                job_data["error"] = str(e)
                job_data["traceback"] = traceback.format_exc()
                rdb.set(job_id, json.dumps(job_data))
                self.log_and_print(f"✅ {self.worker_id} updated job {job_id} to FAILED")
            except Exception as redis_error:
                self.log_and_print(f"💥 {self.worker_id} failed to update error status: {redis_error}")
            
            raise e
    
    def get_status(self):
        """Get worker status"""
        return {
            "worker_id": self.worker_id,
            "model_loaded": self.pipeline is not None,
            "node": os.uname().nodename,
            "gpu_available": torch.cuda.is_available(),
            "gpu_count": torch.cuda.device_count() if torch.cuda.is_available() else 0
        }

# Global worker pool
worker_pool: List[ray.actor.ActorHandle] = []

def initialize_worker_pool():
    """Initialize a pool of warm Mochi workers"""
    global worker_pool
    
    # Get available GPU resources
    cluster_resources = ray.cluster_resources()
    available_gpus = int(cluster_resources.get('GPU', 0))
    
    logger.info(f"🏊 Initializing worker pool with {available_gpus} GPUs available")
    
    # Create one worker per available GPU (but limit to reasonable number)
    num_workers = min(available_gpus, 4)  # Max 4 workers
    
    logger.info(f"🚀 Creating {num_workers} warm Mochi workers...")
    
    for i in range(num_workers):
        try:
            worker = MochiWorker.remote()
            worker_pool.append(worker)
            logger.info(f"✅ Created warm worker {i+1}/{num_workers}")
        except Exception as e:
            logger.error(f"❌ Failed to create worker {i+1}: {e}")
    
    logger.info(f"🎉 Worker pool initialized with {len(worker_pool)} warm workers")

def get_available_worker():
    """Get an available worker from the pool"""
    if not worker_pool:
        raise RuntimeError("No workers available in pool")
    
    # For now, use round-robin. Could implement load balancing later
    import random
    return random.choice(worker_pool)

# Initialize worker pool on startup
initialize_worker_pool()

@app.post("/generate")
async def generate(req: GenerateRequest):
    logger.info(f"📥 BACKEND received generation request")
    logger.info(f"📝 BACKEND prompt: {req.prompt}")
    logger.info(f"👤 BACKEND account_id: {req.account_id}")
    
    job_id = str(uuid.uuid4())
    logger.info(f"🆔 BACKEND generated job_id: {job_id}")
    
    job_data = {
        "status": JobStatus.PENDING,
        "prompt": req.prompt,
        "account_id": req.account_id
    }
    
    try:
        # Store job in Redis
        logger.info(f"💾 BACKEND storing job {job_id} in Redis")
        rdb.set(job_id, json.dumps(job_data))
        logger.info(f"✅ BACKEND job {job_id} stored in Redis")
        
        # Add job ID to list for this account
        logger.info(f"📋 BACKEND adding job {job_id} to account {req.account_id} job list")
        rdb.rpush(f"account:{req.account_id}:jobs", job_id)
        logger.info(f"✅ BACKEND job {job_id} added to account list")

        # Get a warm worker and submit job
        logger.info(f"🎯 BACKEND getting warm worker for job {job_id}")
        worker = get_available_worker()
        logger.info(f"✅ BACKEND got warm worker for job {job_id}")
        
        # Submit to warm worker (model already loaded!)
        logger.info(f"🚀 BACKEND submitting job {job_id} to warm worker")
        future = worker.generate_video.remote(job_id, req.prompt)
        logger.info(f"✅ BACKEND job {job_id} submitted to warm worker")
        logger.info(f"🔗 BACKEND task reference: {future}")
        
        return {"job_id": job_id}
        
    except Exception as e:
        logger.error(f"💥 BACKEND failed to create/submit job {job_id}: {str(e)}")
        logger.error(f"🔍 BACKEND traceback: {traceback.format_exc()}")
        
        # Try to update job status to FAILED if it was created
        try:
            if rdb.exists(job_id):
                job_data["status"] = JobStatus.FAILED
                job_data["error"] = f"Backend error: {str(e)}"
                rdb.set(job_id, json.dumps(job_data))
                logger.info(f"✅ BACKEND updated job {job_id} status to FAILED")
        except Exception as redis_error:
            logger.error(f"💥 BACKEND failed to update job status to FAILED: {redis_error}")
        
        raise HTTPException(status_code=500, detail=f"Failed to create job: {str(e)}")

@app.get("/status/{job_id}")
async def get_status(job_id: str):
    logger.info(f"📊 BACKEND status check for job {job_id}")
    
    try:
        job_data = rdb.get(job_id)
        if not job_data:
            logger.warning(f"❓ BACKEND job {job_id} not found in Redis")
            raise HTTPException(status_code=404, detail="Job ID not found")
        
        job = json.loads(job_data)
        logger.info(f"📈 BACKEND job {job_id} status: {job['status']}")
        
        result = {"status": job["status"]}
        if job["status"] == JobStatus.COMPLETED and "output" in job:
            result["output"] = job["output"]
            logger.info(f"✅ BACKEND job {job_id} completed with output: {job['output']}")
        elif job["status"] == JobStatus.FAILED and "error" in job:
            result["error"] = job["error"]
            logger.error(f"❌ BACKEND job {job_id} failed with error: {job['error']}")
            if "traceback" in job:
                logger.error(f"🔍 BACKEND job {job_id} traceback: {job['traceback']}")
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"💥 BACKEND failed to get status for job {job_id}: {str(e)}")
        logger.error(f"🔍 BACKEND traceback: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=f"Failed to get job status: {str(e)}")

@app.get("/download/{job_id}")
async def download_video(job_id: str):
    job_data = rdb.get(job_id)
    if not job_data:
        raise HTTPException(status_code=404, detail="Job ID not found")
    
    job = json.loads(job_data)
    if job["status"] != JobStatus.COMPLETED:
        raise HTTPException(status_code=404, detail="Job not completed")
    
    output_path = job.get("output")
    if not output_path or not os.path.isfile(output_path):
        raise HTTPException(status_code=404, detail="File does not exist")

    return FileResponse(path=output_path, media_type="video/mp4", filename=f"{job_id}.mp4")

@app.get("/jobs/{account_id}")
async def list_jobs(account_id: str):
    job_ids = rdb.lrange(f"account:{account_id}:jobs", 0, -1)
    jobs_summary = []

    for jid in job_ids:
        job_raw = rdb.get(jid)
        if job_raw:
            job = json.loads(job_raw)
            jobs_summary.append({
                "job_id": jid,
                "status": job["status"],
                "prompt": job["prompt"]
            })

    return {"account_id": account_id, "jobs": jobs_summary}

@app.get("/workers/status")
async def get_worker_status():
    """Get status of all warm workers"""
    logger.info("🔍 BACKEND checking worker pool status")
    
    try:
        worker_statuses = []
        for i, worker in enumerate(worker_pool):
            try:
                status = ray.get(worker.get_status.remote(), timeout=5)
                worker_statuses.append({"worker_index": i, **status})
            except Exception as e:
                worker_statuses.append({"worker_index": i, "error": str(e), "status": "unreachable"})
        
        return {
            "total_workers": len(worker_pool),
            "workers": worker_statuses,
            "cluster_resources": ray.cluster_resources()
        }
    except Exception as e:
        logger.error(f"💥 BACKEND failed to get worker status: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get worker status: {str(e)}")