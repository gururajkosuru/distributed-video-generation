# Gubernates - Kubernetes Deployment for Mochi Video Generation

This directory contains Kubernetes manifests for deploying the Mochi video generation system at scale.

## Directory Structure

```
gubernates/
├── base/              # Namespace, RBAC, base configurations
├── storage/           # StorageClasses, PVs, PVCs
├── services/          # Service definitions
├── deployments/       # Deployment and StatefulSet manifests
├── ingress/           # Ingress controllers and routing
├── monitoring/        # Monitoring, logging, and observability
├── scripts/           # Deployment and management scripts
└── README.md          # This file
```

## Prerequisites

- Kubernetes cluster with GPU nodes
- NVIDIA device plugin installed
- NVMe storage configured on nodes
- Minimum 2 nodes with 4+ GPUs each

## Deployment Order

1. **Base Resources**: Namespace, RBAC, configs
2. **Storage**: StorageClasses and persistent volumes
3. **Infrastructure**: Redis, Ray cluster
4. **Applications**: Backend API, Frontend
5. **Ingress**: Load balancer and routing
6. **Monitoring**: Observability stack

## Quick Start

```bash
# Deploy all components
./scripts/deploy-all.sh

# Or deploy individually
kubectl apply -f base/
kubectl apply -f storage/
kubectl apply -f services/
kubectl apply -f deployments/
kubectl apply -f ingress/
```

## Resource Requirements

- **Ray Workers**: 2 replicas × 2 GPUs × 32GB RAM each
- **Storage**: 18TB NVMe for videos, models, cache
- **Total GPUs**: Minimum 4 GPUs across cluster

## Scaling

- Backend: Auto-scales 2-10 replicas based on load
- Ray Workers: Manual scaling based on GPU availability
- Storage: Expandable PVCs for videos and models