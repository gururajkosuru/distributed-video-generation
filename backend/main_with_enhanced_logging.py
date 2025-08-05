import uuid
import asyncio
from fastapi import FastAPI, BackgroundTasks, HTTPException
from pydantic import BaseModel
from typing import Dict
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

# Setup detailed logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Global Inits
logger.info("🚀 Starting backend application")
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
def run_generation_ray(job_id: str, prompt: str) -> str:
    import redis
    import json
    from diffusers import MochiPipeline
    from diffusers.utils import export_to_video
    import torch
    import os
    import logging
    import traceback
    import time
    import psutil
    import subprocess

    # Setup logging for Ray worker - force console output
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - RAY-WORKER - %(levelname)s - %(message)s',
        force=True
    )
    worker_logger = logging.getLogger(f"ray_worker_{job_id}")
    
    # Print to both logger and stdout for visibility
    def log_and_print(message):
        worker_logger.info(message)
        print(f"RAY-WORKER: {message}")
    
    log_and_print(f"🚀 RAY WORKER STARTED for job {job_id}")
    log_and_print(f"📝 Prompt: {prompt}")
    log_and_print(f"🖥️  Available GPUs: {torch.cuda.device_count()}")
    
    # Log system information
    log_and_print(f"💻 Ray worker node: {os.uname().nodename}")
    log_and_print(f"🧠 RAM usage: {psutil.virtual_memory().percent}%")
    log_and_print(f"💾 Disk usage: {psutil.disk_usage('/').percent}%")
    
    # Log GPU information if available
    try:
        result = subprocess.run(['nvidia-smi', '--query-gpu=index,name,memory.total,memory.used', '--format=csv,noheader,nounits'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            log_and_print(f"🎮 GPU info: {result.stdout.strip()}")
        else:
            log_and_print(f"❓ nvidia-smi failed: {result.stderr}")
    except Exception as e:
        log_and_print(f"❓ Could not get GPU info: {e}")
    
    # Log environment variables
    log_and_print(f"🌍 REDIS_HOST: {os.getenv('REDIS_HOST', 'NOT_SET')}")
    log_and_print(f"🌍 RAY_ADDRESS: {os.getenv('RAY_ADDRESS', 'NOT_SET')}")
    log_and_print(f"🌍 CUDA_VISIBLE_DEVICES: {os.getenv('CUDA_VISIBLE_DEVICES', 'NOT_SET')}")
    
    # Connect to Redis from within Ray worker
    redis_host = os.getenv("REDIS_HOST", "redis-service")
    redis_port = int(os.getenv("REDIS_PORT", "6379"))
    redis_db = int(os.getenv("REDIS_DB", "0"))
    log_and_print(f"🔗 RAY WORKER connecting to Redis at {redis_host}:{redis_port} db={redis_db}")
    
    try:
        rdb = redis.Redis(host=redis_host, port=redis_port, db=redis_db)
        rdb.ping()
        log_and_print("✅ RAY WORKER Redis connection successful")
    except Exception as e:
        log_and_print(f"💥 RAY WORKER Redis connection failed: {e}")
        log_and_print(f"🔍 RAY WORKER Redis error traceback: {traceback.format_exc()}")
        raise RuntimeError(f"Redis connection failed in Ray worker: {e}")
    
    # Get and update job status
    try:
        log_and_print(f"📖 RAY WORKER retrieving job data for {job_id}")
        job_data_raw = rdb.get(job_id)
        if not job_data_raw:
            log_and_print(f"❌ RAY WORKER job {job_id} not found in Redis")
            raise ValueError(f"Job {job_id} not found in Redis")
        
        job_data = json.loads(job_data_raw)
        log_and_print(f"📊 RAY WORKER current job status: {job_data.get('status')}")
        log_and_print(f"📋 RAY WORKER job data: {job_data}")
        
        # Update status to RUNNING
        job_data["status"] = "RUNNING"
        rdb.set(job_id, json.dumps(job_data))
        log_and_print("✅ RAY WORKER updated job status to RUNNING")
        
    except Exception as e:
        log_and_print(f"💥 RAY WORKER failed to update job status: {e}")
        log_and_print(f"🔍 RAY WORKER traceback: {traceback.format_exc()}")
        raise

    try:
        # Write directly to /data directory (ray user has write access)
        output_path = f"/data/{job_id}.mp4"
        log_and_print(f"📁 RAY WORKER output path: {output_path}")
        
        # Check if output directory exists and is writable
        output_dir = os.path.dirname(output_path)
        if os.path.exists(output_dir):
            log_and_print(f"✅ RAY WORKER output directory {output_dir} exists")
            if os.access(output_dir, os.W_OK):
                log_and_print(f"✅ RAY WORKER output directory {output_dir} is writable")
            else:
                log_and_print(f"❌ RAY WORKER output directory {output_dir} is NOT writable")
        else:
            log_and_print(f"❌ RAY WORKER output directory {output_dir} does NOT exist")
        
        # Use preloaded warm model instead of loading each time
        log_and_print("🔥 RAY WORKER getting warm Mochi pipeline...")
        start_time = time.time()
        
        # Import the warmup module to get preloaded model
        try:
            import sys
            sys.path.append('/app')
            from ray_worker_warmup import get_warm_mochi_pipeline
            
            pipe = get_warm_mochi_pipeline()
            load_time = time.time() - start_time
            log_and_print(f"♻️  RAY WORKER got warm pipeline in {load_time:.3f}s (no loading needed!)")
            
        except ImportError as e:
            log_and_print(f"⚠️  RAY WORKER warmup module not found, loading model cold: {e}")
            # Fallback to cold loading
            log_and_print("🤖 RAY WORKER loading Mochi pipeline (cold start)...")
            
            # Check CUDA availability
            log_and_print(f"🔥 RAY WORKER CUDA available: {torch.cuda.is_available()}")
            if torch.cuda.is_available():
                log_and_print(f"🔥 RAY WORKER Current CUDA device: {torch.cuda.current_device()}")
                log_and_print(f"🔥 RAY WORKER CUDA device name: {torch.cuda.get_device_name()}")
                log_and_print(f"🔥 RAY WORKER CUDA memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f}GB")
                
            pipe = MochiPipeline.from_pretrained("genmo/mochi-1-preview").to("cuda")
            pipe.enable_model_cpu_offload()
            pipe.enable_vae_tiling()
            load_time = time.time() - start_time
            log_and_print(f"✅ RAY WORKER pipeline loaded in {load_time:.2f}s (cold start)")

        log_and_print("🎬 RAY WORKER starting video generation...")
        gen_start_time = time.time()
        with torch.autocast("cuda", torch.bfloat16, cache_enabled=False):
            result = pipe(prompt, num_frames=84)
            frames = result.frames[0]
        gen_time = time.time() - gen_start_time
        log_and_print(f"✅ RAY WORKER video generation completed in {gen_time:.2f}s")

        log_and_print("💾 RAY WORKER exporting video...")
        export_start_time = time.time()
        export_to_video(frames, output_path, fps=30)
        export_time = time.time() - export_start_time
        log_and_print(f"✅ RAY WORKER video exported in {export_time:.2f}s")
        
        # Verify the output file was created
        if os.path.exists(output_path):
            file_size = os.path.getsize(output_path)
            log_and_print(f"✅ RAY WORKER output file created: {output_path} ({file_size} bytes)")
        else:
            log_and_print(f"❌ RAY WORKER output file NOT created: {output_path}")
        
        # Update status to COMPLETED
        job_data["status"] = "COMPLETED"
        job_data["output"] = output_path
        rdb.set(job_id, json.dumps(job_data))
        log_and_print("✅ RAY WORKER updated job status to COMPLETED")
        
        total_time = time.time() - start_time
        log_and_print(f"🎉 RAY WORKER job {job_id} completed successfully in {total_time:.2f}s")
        return output_path
        
    except Exception as e:
        log_and_print(f"💥 RAY WORKER generation failed: {str(e)}")
        log_and_print(f"🔍 RAY WORKER full traceback: {traceback.format_exc()}")
        
        try:
            # Update status to FAILED
            job_data["status"] = "FAILED"
            job_data["error"] = str(e)
            job_data["traceback"] = traceback.format_exc()
            rdb.set(job_id, json.dumps(job_data))
            log_and_print("✅ RAY WORKER updated job status to FAILED")
        except Exception as redis_error:
            log_and_print(f"💥 RAY WORKER failed to update error status: {redis_error}")
        
        raise e


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

        # Submit Ray job and store reference (don't await it)
        logger.info(f"🚀 BACKEND submitting Ray task for job {job_id}")
        logger.info(f"📊 BACKEND current Ray cluster resources: {ray.cluster_resources()}")
        
        future = run_generation_ray.remote(job_id, req.prompt)
        logger.info(f"✅ BACKEND Ray task submitted successfully for job {job_id}")
        logger.info(f"🔗 BACKEND Ray task reference: {future}")
        
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

@app.get("/result/{job_id}")
async def get_result(job_id: str):
    job = jobs.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job ID not found")

    ref = job.get("ref")
    if not ref:
        return {"status": job["status"]}

    ready, _ = ray.wait([ref], timeout=0)
    if ready:
        try:
            path = ray.get(ref)
            jobs[job_id]["status"] = JobStatus.COMPLETED
            jobs[job_id]["output"] = path
            return {"output_path": path}
        except Exception as e:
            jobs[job_id]["status"] = JobStatus.FAILED
            jobs[job_id]["error"] = str(e)
            raise HTTPException(status_code=500, detail=str(e))
    else:
        return {"status": JobStatus.RUNNING}


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


def get_job_with_account_validation(
    job_id: str = Path(...),
    account_id: str = Query(...)
) -> dict:
    job_data = rdb.get(job_id)
    if not job_data:
        raise HTTPException(status_code=404, detail="Job ID not found")

    job = json.loads(job_data)
    if job.get("account_id") != account_id:
        raise HTTPException(status_code=403, detail="Access denied")

    return job

