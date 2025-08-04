#!/bin/bash
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml
export PATH=$PATH:/usr/local/bin
# Deploy all Mochi Video Generation components to Kubernetes
# Usage: ./deploy-all.sh

set -e

echo "🚀 Deploying Mochi Video Generation System to Kubernetes..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml is available
if ! command -v kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml &> /dev/null; then
    print_error "kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml is not installed or not in PATH"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

cd "$BASE_DIR"

# Phase 1: Base Resources
print_status "Phase 1: Deploying base resources..."
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f base/namespace.yaml
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f base/rbac.yaml
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f base/configmap.yaml
print_success "Base resources deployed"

# Phase 2: Storage
print_status "Phase 2: Deploying storage resources..."
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f storage/storageclass.yaml

# Update PV node affinity with actual node name
NODE_NAME=$(kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get nodes -l accelerator=nvidia-gpu -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get nodes -o jsonpath='{.items[0].metadata.name}')
if [ -n "$NODE_NAME" ]; then
    print_status "Using node: $NODE_NAME for storage"
    sed "s/REPLACE_WITH_NODE_NAME/$NODE_NAME/g" storage/persistent-volumes.yaml | kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f -
else
    print_warning "No GPU node found, using default node for storage"
    kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f storage/persistent-volumes.yaml
fi

kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f storage/persistent-volume-claims.yaml
print_success "Storage resources deployed"

# Wait for PVCs to be bound
print_status "Waiting for PVCs to be bound..."
# kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml wait --for=condition=Bound pvc --all -n mochi-video-gen --timeout=300s

# Phase 3: Services
print_status "Phase 3: Deploying services..."
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f services/
print_success "Services deployed"

# Phase 4: Infrastructure (Redis, Ray)
print_status "Phase 4: Deploying infrastructure..."
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f deployments/redis-statefulset.yaml
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f deployments/ray-head-deployment.yaml

# Wait for Ray head to be ready
print_status "Waiting for Ray head to be ready..."
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml wait --for=condition=available deployment/ray-head -n mochi-video-gen --timeout=300s

# Deploy Ray workers
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f deployments/ray-worker-deployment.yaml
print_success "Infrastructure deployed"

# Phase 5: Applications
print_status "Phase 5: Deploying applications..."

# Build and deploy backend (if Docker is available)
# if command -v docker &> /dev/null; then
#     print_status "Building backend image..."
#     docker build -t mochi-backend:latest -f deployments/backend-dockerfile ../backend/
#     print_status "Building frontend image..."
#     docker build -t mochi-frontend:latest -f deployments/frontend-dockerfile ../frontend/
# else
#     print_warning "Docker not available, assuming images are pre-built"
# fi

kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f deployments/backend-deployment.yaml
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f deployments/frontend-deployment.yaml
print_success "Applications deployed"

# Phase 6: Ingress
print_status "Phase 6: Deploying ingress..."
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f ingress/
print_success "Ingress deployed"

# Phase 7: Monitoring
print_status "Phase 7: Deploying monitoring..."
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml apply --validate=false -f monitoring/
print_success "Monitoring deployed"

# Wait for all deployments to be ready
print_status "Waiting for all deployments to be ready..."
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml wait --for=condition=available deployment --all -n mochi-video-gen --timeout=600s

# Display status
print_success "🎉 Deployment completed successfully!"
echo ""
print_status "Deployment Status:"
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get pods -n mochi-video-gen
echo ""
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get services -n mochi-video-gen
echo ""
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get ingress -n mochi-video-gen

# Display access information
echo ""
print_status "Access Information:"
echo "  • Frontend: https://mochi.yourdomain.com (replace with your domain)"
echo "  • Ray Dashboard: https://ray.yourdomain.com (replace with your domain)"
echo "  • API: https://api.yourdomain.com (replace with your domain)"
echo ""
print_status "To access locally:"
echo "  kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml port-forward -n mochi-video-gen service/frontend-service 3000:80"
echo "  kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml port-forward -n mochi-video-gen service/backend-service 8000:8000"
echo "  kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml port-forward -n mochi-video-gen service/ray-dashboard-service 8265:8265"

print_success "Setup complete! 🚀"
