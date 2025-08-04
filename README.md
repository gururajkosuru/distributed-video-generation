# Distributed Video Generation System

A scalable distributed video generation system using the Mochi AI model, built with Ray cluster computing, FastAPI, and React.

## 🎬 Features

- **Text-to-Video Generation**: Generate 84-frame videos from text prompts using the Mochi AI model
- **Distributed Computing**: Ray cluster with head and worker nodes for scalable video processing
- **GPU Acceleration**: H100 GPU support with CUDA optimization
- **Warm Model Preloading**: Ray workers preload models to eliminate loading delays
- **Job Queue Management**: Redis-backed job queuing with account-based isolation
- **Web Interface**: React frontend for easy video generation requests
- **Kubernetes Native**: Complete Kubernetes deployment configurations
- **Comprehensive Logging**: Detailed observability throughout the generation pipeline

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌───────────────────┐
│   React Frontend │────│   FastAPI Backend │────│   Ray Cluster     │
│   (Port 3000)    │    │   (Port 8000)     │    │   (Head + Workers)│
└─────────────────┘    └──────────────────┘    └───────────────────┘
                                 │                         │
                                 │                         │
                         ┌───────────────┐         ┌─────────────┐
                         │     Redis     │         │   H100 GPUs │
                         │  Job Queue    │         │   (2x per   │
                         │               │         │   worker)   │
                         └───────────────┘         └─────────────┘
```

### Core Components

- **Frontend** (`frontend/`): React + Vite application
- **Backend** (`backend/`): FastAPI with Ray integration  
- **Ray Cluster** (`ray/`): Distributed computing with GPU workers
- **Redis**: Job state management and queuing
- **Kubernetes** (`gubernates/`): Production deployment configs

## 🚀 Performance

- **With Warm Models**: ~5 minutes per video (model preloaded)
- **Cold Start**: ~10 minutes per video (includes 5min model loading)
- **50% Performance Improvement** through model preloading
- **Concurrent Processing**: Multiple videos can be generated simultaneously

## 🛠️ Development

### Prerequisites

- Docker & Docker Compose
- Kubernetes cluster with GPU nodes (H100 recommended)
- NVIDIA Docker runtime
- kubectl configured

### Local Development

```bash
# Start all services
docker-compose up --build

# Access frontend
http://localhost:3000

# Access backend API docs  
http://localhost:8000/docs
```

### Kubernetes Deployment

```bash
# Deploy all components
cd gubernates
./scripts/deploy-all.sh

# Scale Ray workers
./scripts/scale-workers.sh 4

# Port forward frontend
kubectl port-forward svc/frontend-service 3000:80 -n mochi-video-gen
```

## 📊 API Endpoints

- `POST /generate` - Submit video generation job
- `GET /status/{job_id}` - Check job status  
- `GET /download/{job_id}` - Download completed video
- `GET /jobs/{account_id}` - List jobs for account
- `GET /workers/status` - Check Ray worker status

## 🔧 Configuration

### Environment Variables

```bash
RAY_ADDRESS=ray://ray-head-service:10001
REDIS_HOST=redis-service
REDIS_PORT=6379
REDIS_DB=0
```

### GPU Requirements

- NVIDIA GPU with CUDA 11.8+ support
- At least 10GB shared memory (`shm_size: "10gb"`)
- H100 80GB recommended for optimal performance

## 📈 Monitoring

The system provides comprehensive logging at every stage:

- Ray worker execution with timing metrics
- Model loading and warmup status
- GPU utilization and memory usage
- Job progress through generation pipeline
- Error handling with full tracebacks

## 🏭 Production Considerations

- **Resource Management**: Configure appropriate GPU memory limits
- **Scaling**: Use HPA for automatic scaling based on queue depth
- **Monitoring**: Ray dashboard available on port 8265
- **Storage**: Persistent volumes for model cache and video output
- **Security**: Service accounts and RBAC properly configured

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes with descriptive messages
4. Push to your branch
5. Create a Pull Request

## 📝 License

This project is created for educational and research purposes.

---

🤖 *Generated with [Claude Code](https://claude.ai/code)*