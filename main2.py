from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from diffusers import DiffusionPipeline
from diffusers.utils import export_to_video
from accelerate import init_empty_weights, infer_auto_device_map
import torch
import imageio
import uuid
import os

app = FastAPI()

# Load model at startup
pipe = DiffusionPipeline.from_pretrained("genmo/mochi-1-preview", torch_dtype=torch.float16)
pipe = pipe.to("cuda")
pipe.enable_model_cpu_offload()
pipe.enable_vae_tiling()
# Try to use accelerate to spread it
# Manually assign submodules if possible
pipe.text_encoder.to("cuda:0")
pipe.unet.to("cuda:1")
pipe.vae.to("cuda:0")

OUTPUT_DIR = "/data/videos"
os.makedirs(OUTPUT_DIR, exist_ok=True)

class PromptRequest(BaseModel):
    prompt: str

@app.post("/generate")
def generate_video(req: PromptRequest):
    try:
        video_path = generate_video(req.prompt)
        return {"message": "Video generated", "path": video_path}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def generate_video(prompt: str, output_path: str = "mochi.mp4", num_frames: int = 84, fps: int = 30):
    with torch.autocast("cuda", torch.bfloat16, enabled=True):
        output = pipe(prompt, num_frames=num_frames)
        frames = output.frames[0]  # <--- this is correct per Mochi docs
    export_to_video(frames, output_path, fps=fps)
    return output_path

