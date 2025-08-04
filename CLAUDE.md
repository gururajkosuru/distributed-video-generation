# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a distributed video generation application using the Mochi AI model. The system uses a microservices architecture with GPU-accelerated AI inference, distributed computing via Ray, and Redis for job queuing.

## Architecture

### Core Services
- **Frontend** (`frontend/`): React + Vite application serving the user interface
- **Backend** (`backend/`): FastAPI application handling API requests and job orchestration  
- **Ray Cluster** (`ray/`): Distributed computing cluster for GPU-intensive video generation tasks
- **Redis**: Job queue and state management

### Data Flow
1. User submits video generation prompt via React frontend
2. Frontend proxies requests to FastAPI backend on port 8000
3. Backend creates job in Redis and submits Ray remote task
4. Ray worker loads Mochi pipeline and generates video on GPU
5. Completed videos stored in `/data/videos/` and served via download endpoint

### Key Components
- **Mochi Pipeline**: `genmo/mochi-1-preview` model for text-to-video generation
- **Job Management**: Redis-backed job queue with account-based isolation
- **GPU Acceleration**: CUDA-enabled containers with model CPU offloading

## Development Commands

### Frontend Development
```bash
cd frontend/
npm run dev          # Start development server on port 5173
npm run build        # Build for production
npm run preview      # Preview production build
```

### Backend Development
```bash
cd backend/
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Full Stack Development
```bash
docker-compose up --build    # Start all services with GPU support
docker-compose down          # Stop all services
```

### Individual Service Management
```bash
docker-compose up redis      # Start only Redis
docker-compose up ray        # Start only Ray cluster
docker-compose up backend    # Start only backend API
docker-compose up frontend   # Start only frontend
```

## GPU Requirements

- NVIDIA GPU with CUDA 11.8 support
- At least 10GB shared memory (`shm_size: "10gb"`)
- NVIDIA Docker runtime configuration required

## Key Configuration

### Ray Integration
- Ray cluster accessible at `ray://ray:10001`
- Ray dashboard available at `localhost:8265`
- Ray remote functions require `@ray.remote(num_gpus=1)` decorator

### Redis Configuration
- Job data stored with JSON serialization
- Account-based job lists: `account:{account_id}:jobs`
- Job status tracking: PENDING → RUNNING → COMPLETED/FAILED

### Frontend Proxy Setup
Vite dev server proxies API routes to backend:
- `/generate` → `http://localhost:8000`
- `/status` → `http://localhost:8000` 
- `/download` → `http://localhost:8000`

## Video Generation Pipeline

1. **Input**: Text prompt and account ID
2. **Processing**: 84-frame video generation at 30fps
3. **Model Settings**: CUDA + bfloat16 precision with VAE tiling
4. **Output**: MP4 file stored in `/data/videos/{job_id}.mp4`

## API Endpoints

- `POST /generate`: Submit video generation job
- `GET /status/{job_id}`: Check job status
- `GET /download/{job_id}`: Download completed video
- `GET /jobs/{account_id}`: List jobs for account