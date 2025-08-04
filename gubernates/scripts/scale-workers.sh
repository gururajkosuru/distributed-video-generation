#!/bin/bash

# Scale Ray workers based on available GPU resources
# Usage: ./scale-workers.sh [replicas]

set -e

REPLICAS=${1:-2}

echo "🔧 Scaling Ray workers to $REPLICAS replicas..."

# Check GPU availability
GPU_NODES=$(kubectl get nodes -l accelerator=nvidia-gpu --no-headers 2>/dev/null | wc -l || echo "0")
TOTAL_GPUS=$(kubectl describe nodes -l accelerator=nvidia-gpu 2>/dev/null | grep -c "nvidia.com/gpu:" || echo "0")

echo "Available GPU nodes: $GPU_NODES"
echo "Total GPUs: $TOTAL_GPUS"

# Calculate maximum possible replicas (2 GPUs per replica)
MAX_REPLICAS=$((TOTAL_GPUS / 2))

if [ "$REPLICAS" -gt "$MAX_REPLICAS" ]; then
    echo "⚠️  Warning: Requested $REPLICAS replicas but only $MAX_REPLICAS possible with available GPUs"
    echo "   Setting replicas to $MAX_REPLICAS"
    REPLICAS=$MAX_REPLICAS
fi

if [ "$REPLICAS" -lt 1 ]; then
    echo "❌ Error: Cannot scale to less than 1 replica"
    exit 1
fi

# Scale the deployment
kubectl scale deployment ray-worker -n mochi-video-gen --replicas=$REPLICAS

echo "✅ Ray workers scaled to $REPLICAS replicas"
echo "📊 Monitoring status:"
kubectl get pods -n mochi-video-gen -l app.kubernetes.io/name=ray-worker