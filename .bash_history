vim ~/.ssh/authorized_keys 
exit 
ls
cat dependenciesone.sh
df -h
kubectl
kubectl cluster-info
kubectl cluster-info dump
kubectl cluster-info
hostname
clear
df -h
ps
clear
exit
cat /proc/cpuinfo 
sudo lshw -C display
cuda help
uname -m
exit
ls
vim ~/.ssh/authorized_keys 
git status
exit 
docker images ls 
ls
containerd 
containerd  image ls 
exit 
docker 
containerd 
ls 
ls -al 
exit 
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
pwd
export KUBECONFIG=./guru-kubeconfig.yml 
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
curl -X POST "http://localhost:8000/generate" -H "Content-Type: application/json"   -d '{"prompt": "anime girl with red hair wearing school uniform"}'
ls
vim main.py 
python main.py 
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install diffusers transformers accelerate fastapi uvicorn imageio sentencepiece
uvicorn main:app --host 0.0.0.0 --port 8000
which uvicorn
python3 -m site --user-base
export PATH=$PATH:~/.local/bin
uvicorn main:app --host 0.0.0.0 --port 8000
vim main.py 
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
vim main.py 
uvicorn main:app --host 0.0.0.0 --port 8000
vim main.py 
uvicorn main:app --host 0.0.0.0 --port 8000
RUN apt-get update && apt-get install -y ffmpeg
pip install imageio-ffmpeg
uvicorn main:app --host 0.0.0.0 --port 8000
ls -lrth
vim done.txt 
vim dependenciesone.sh 
vim dependenciestwo.sh 
vim main.py
vim Dockerfile
docker build -t youruser/mochi:latest .
docker push youruser/mochi:latest
sudo apt-get update
sudo apt-get install -y     ca-certificates     curl     gnupg     lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |     sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker build -t mochi-fastapi:latest .
sudo docker build -t mochi-fastapi:latest .
vim Dockerfile 
sudo docker build -t mochi-fastapi:latest .
vim Dockerfile 
sudo docker build -t mochi-fastapi:latest .
docker login
docker login -u glususer
# Tag your image properly
docker tag mochi-fastapi:latest glususer/mochi-1-preview:latest
# Push it to Docker Hub
docker push glususer/mochi-1-preview:latest
sudo docker tag mochi-fastapi:latest glususer/mochi-1-preview:latest
sudo docker push glususer/mochi-1-preview:latest
sudo docker login
sudo docker login -u glususer
sudo docker push glususer/mochi-1-preview:latest
vim deployment.yaml
vim service.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
echo $KUBECONFIG
ls -lrth
export KUBECONFIG=./guru-kubeconfig.yml 
echo $KUBECONFIG
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get pods
kubectl get pods -A
kubectl get pods 
kubectl describe pod mochi-app-d4b66c878-4brxk
kubectl get nodes -o wide
sudo systemctl restart kubelet
sudo systemctl status kubelet
kubectl get nodes
kubectl get nodes -o wide
ssh ubuntu@10.15.38.25
hostname
sudo systemctl restart kubelet
sudo systemctl status kubelet
journalctl -u kubelet -xe | tail -n 50
sudo apt purge -y containerd
sudo apt update
sudo apt install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo nano /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl restart kubelet
sudo systemctl status containerd
sudo systemctl status kubelet
kubectl get nodes
sudo systemctl status kubelet
kubectl get nodes
kubectl get pods
kubectl delete pod mochi-app-d4b66c878-4brxk
kubectl get pods
kubectl logs deployment/mochi-app
kubectl get pod mochi-app-d4b66c878-gx5w5 -o wide
kubectl get nodes
kubectl describe node g370 | grep nvidia.com/gpu
kubectl get pods -n kube-nvidia -o wide | grep g370
vim deployment.yaml 
kubectl exec -it deployment/mochi-app -- bash
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
sudo docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
sudo systemctl start docker
sudo systemctl unmask docker
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
sudo apt-get purge -y docker.io docker docker-engine docker-ce docker-ce-cli
sudo rm -rf /var/lib/docker /var/lib/containerd
sudo apt-get update
sudo apt-get install -y     ca-certificates     curl     gnupg     lsb-release
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |     sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
sudo systemctl status containerd
qqq
sudo systemctl status containerd
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list |      sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
sudo docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
sudo docker run --rm -it --gpus all -p 8000:8000   -v $(pwd)/videos:/data/videos   glususer/mochi-1-preview:latest
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "anime girl with red hair wearing school uniform"}'
vim main.py 
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "anime girl with red hair wearing school uniform"}'
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "anime girl with red hair wearing school uniform"}'
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
vim main.py 
uvicorn main:app --host 0.0.0.0 --port 8000
vim main.py 
uvicorn main:app --host 0.0.0.0 --port 8000
vim main.py
mv main.py main2.py
vim main.py
uvicorn main:app --host 0.0.0.0 --port 8000
nvidia-smi
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "anime girl with red hair wearing school uniform"}'
curl http://localhost:8000/status/24438a44-43be-47c2-995d-683d4bca9dac
curl -O http://localhost:8000/download/8893ed90-3857-4b0a-a4c0-c1fd6064a81f
ls -lrtg
file /data/videos/8893ed90-3857-4b0a-a4c0-c1fd6064a81f
cat /data/videos/8893ed90-3857-4b0a-a4c0-c1fd6064a81f
ls /data/videos/
ls /data/videos/24438a44-43be-47c2-995d-683d4bca9dac.mp4 
ls /data/videos/
ls -lrth /data/videos/
vim main.py 
curl -O http://localhost:8000/result/8893ed90-3857-4b0a-a4c0-c1fd6064a81f
vim main.py 
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "indian flag on siachen glacier"}'
curl -O http://localhost:8000/result/b364bde1-caec-4949-a07d-e4ea2b948277
ls -lrth /data/videos/
date
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "unicorn flag on siachen glacier with baby mermaids watching flying walruses"}'
ls -lrth /data/videos/
sudo mkdir -p /data/videos
sudo chmod 777 /data/videos  # quick test
uvicorn main:app --host 0.0.0.0 --port 8000
sudo lsof -i :8000
kill -9 3233580
uvicorn main:app --host 0.0.0.0 --port 8000
vim main.py 
uvicorn main:app --host 0.0.0.0 --port 8000
ps aux | grep python
pkill -9 -f main.py
pkill -9 -f uvicorn
pip install "ray[default]"  # includes Ray Core + Dashboard
pip install redis psycopg2-binary
vim main.py
uvicorn main:app --host 0.0.0.0 --port 8000
vim main.py
uvicorn main:app --host 0.0.0.0 --port 8000
ulimit -n
ulimit -n 65535
uvicorn main:app --host 0.0.0.0 --port 8000
sudo systemctl status redis
sudo journalctl -u redis --no-pager --since "10 minutes ago"
sudo journalctl -u redis --no-pager --since "30 minutes ago"
sudo journalctl -u redis --no-pager --since "50 minutes ago"
sudo journalctl -u redis --no-pager --since "500 minutes ago"
sudo redis-server /etc/redis/redis.conf --test-memory 2048
sudo nano /etc/redis/redis.conf
sudo vim /etc/redis/redis.conf
sudo redis-server /etc/redis/redis.conf
journalctl -u redis -n 50 --no-pager
redis-cli ping
sudo fuser -k 6379/tcp
sudo redis-server /etc/redis/redis.conf
sudo vim /etc/redis/redis.conf
sudo redis-server /etc/redis/redis.conf
sudo strace -f -o redis.log redis-server /etc/redis/redis.conf
tail -n 50 redis.log 
vim redis.log 
redis-cli ping
uvicorn main:app --host 0.0.0.0 --port 8000
vim main.py 
uvicorn main:app --host 0.0.0.0 --port 8000
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "unicorn flag on siachen glacier with baby mermaids watching flying walruses"}'
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "unicorn flag on siachen glacier with baby mermaids watching flying walruses", "accountId":"guru"}'
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "unicorn flag on siachen glacier with baby mermaids watching flying walruses", "account_id":"guru"}'
ray start --head
ps aux | grep ray
lsof -i :6379
ulimit -n
ulimit -n 65536
vim /etc/security/limits.conf 
sudo vim /etc/security/limits.conf 
ulimit -n
vim /tmp/ray/session_latest/logs/raylet.out 
ray status
vim /tmp/ray/session_latest/logs/raylet.out 
ray stop --force
pkill -f ray
ps aux | grep ray
rm -rf /tmp/ray
ray start --head --port=6379 --dashboard-host 0.0.0.0
ray status
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two people racing 100m in olympics"}'
vim main.py
ls -lrth /data/videos/
ls -lrth
ray status
vim main.py
cat main
cat main.py 
vim main.py
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two people racing 100m in olympics"}'
vim main.py
ls -lrth /data/videos/
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two people racing 100m in olympics"}'
curl http://localhost:8000/result/13b22119-336d-40ba-a0a6-87495b25406e
ls -lrth /data/videos/
sudo apt update
sudo apt install redis-server
vim main.py
uvicorn main:app --host 0.0.0.0 --port 8000
sudo lsof -i :6379
cat redis.log 
redis-cli ping
ray status
ray stop
ray start --head --port=6380
kubectl get pods -n kube-nvidia -o wide | grep g370
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two elephants jumping"}'
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two elephants jumping", "account_id":"guru"}'
vim main.py 
ls -lrth /data/videos/
date
ls -lrth /data/videos/
ls -lrth
vim Dockerfile 
mv Dockerfile Dockerfile_0801
vim Dockerfile
# Tag the image
docker tag mochi-app:latest glususer/mochi-app:latest
# Push to Docker Hub (make sure you're logged in)
docker push glususer/mochi-app:latest
sudo docker login -u glususer
docker push glususer/mochi-app:latest
docker build -t mochi-app:latest .
sudo docker build -t mochi-app:latest .
docker push glususer/mochi-app:latest
sudo docker push glususer/mochi-app:latest
sudo docker push glususer/mochi-1-preview:latest
cd frontend
ls -lrtg
mkdir backend
mkdir frontend
mv Dockerfile main.py backend/
ls -lrtgh
cd frontend/
vim Dockerfile
cd ..
vim docker-compose.yaml
cd frontend/
npm create vite@latest .
sudo apt install npm
npm install
vim index.html
vim package.json
vim vite.config.ts
vim src/App.tsx
mkdir src
vim src/App.tsx
vim src/main.tsx
npm install
vim Dockerfile 
cd ..
vim docker-compose.yaml 
docker-compose up --build
sudo apt install docker-compose
docker-compose up --build
vim docker-compose.yaml 
docker-compose up --build
sudo docker-compose up --build
cd frontend/
vim package.json 
vim Dockerfile 
rm -rf node_modules package-lock.json
npm install
cd ..
docker-compose build --no-cache
docker-compose up
sudo docker-compose up
docker-compose build --no-cache
docker-compose up
sudo docker-compose build --no-cache
docker-compose build --no-cache
sudo docker-compose build --no-cache
docker-compose up
sudo docker-compose up
vim backend/Dockerfile 
vim docker-compose.yaml 
vim backend/main.py 
vim docker-compose.yaml 
docker-compose up
sudo docker-compose up
vim docker-compose.yaml 
sudo docker-compose up
vim docker-compose.yaml 
sudo docker-compose up
sudo docker-compose down
sudo docker container prune -f
sudo docker imag prune -f
sudo docker image prune -f
sudo docker volume prune -f
docker ps -a
sudo docker ps -a
docker-compose build --no-cache
sudo docker-compose build --no-cache
sudo docker-compose up
vim docker-compose.yaml 
vim backend/main.py 
sudo docker-compose build --no-cache
sudo docker-compose up
ray stop --force
docker-compose down
sudo docker-compose down
sudo docker volume prune -f
sudo docker container prune -f
sudo docker image prune -f
sudo docker-compose build --no-cache
sudo docker-compose up
ray status
sudo docker-compose down
vim docker-compose.yaml 
sudo docker-compose build --no-cache
sudo docker-compose up
vim docker-compose.yaml 
sudo docker-compose build --no-cache
sudo docker-compose up
sudo docker-compose down
sudo docker-compose up
sudo docker-compose down
vim docker-compose.yaml 
sudo docker-compose build --no-cache
sudo docker-compose up
sudo docker-compose down
vim docker-compose.yaml 
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two elephants jumping", "account_id":"guru"}'
curl http://localhost:8000/status/cb4d8875-5d34-47e4-873b-1de0b0905fb9
vim docker-compose.yaml 
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two elephants jumping", "account_id":"guru"}'
ls -lah /tmp/ray/
date
vim docker-compose.yaml 
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two elephants jumping", "account_id":"guru"}'
ls -lrth /tmp/ray/
darte
date
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two elephants jumping", "account_id":"guru"}'
sudo docker-compose down
ls -lrth
cd ray
cd ..
cd ray_tmp/
ls
cd ..
ls /tmp/
ls -lrth /tmp/
date
cd /tmp/ray/
ls
ls -lrth
rm -rf *
df -h
sudo rm -rf /tmp/ray/*
sudo rm -rf /tmp/session_*
sudo rm -rf /tmp/ray_tmp*
df -h
clear
cd ..
pwd
cd /home/ubuntu/
ls -lrth
vim docker-compose.yaml 
docker container prune -f
sudo docker container prune -f
docker image prune -a -f
sudo docker image prune -a -f
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two elephants jumping", "account_id":"guru"}'
curl http://localhost:8000/status/91b65148-1386-45a0-8519-2ce8d8c29fd8
vim backend/main.py 
ls
ls -lrth
cd gubernates/
la
cd services/
ls
vim frontend-service.yaml 
cd ..
ls
cd gubernates/
ls
ls scripts/
ls base/
ls storage/
cd ..
ls -lrth
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get pvc -n mochi-video-gen
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get pvc redis-pvc -n mochi-video-gen
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml delete pvc redis-pvc -n mochi-video-gen
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get pvc redis-pvc -n mochi-video-gen
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get mochi-video-gen
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get pods -n mochi-video-gen -w
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml port-forward -n mochi-video-gen service/frontend-service 3000:80
sudo docker-compose up
sudo docker-compose down
sudo docker-compose up
sudo docker-compose down
vim backend/main.py 
sudo docker-compose down
sudo docker-compose build --no-cache
sudo docker-compose up
vim backend/main.py 
sudo docker-compose down
sudo docker-compose build --no-cache
sudo docker-compose up
vim docker-compose.yaml 
vim backend/main.py 
sudo docker-compose build --no-cache
sudo docker-compose up
sudo docker-compose down
sudo docker-compose up
sudo docker-compose down
vim docker-compose.yaml 
vim backend/main.py 
sudo docker-compose build --no-cache
sudo docker-compose down
sudo docker-compose up
sudo docker-compose down
vim docker-compose.yaml 
sudo docker-compose build --no-cache
sudo docker-compose up
vim docker-compose.yaml 
sudo docker-compose down
sudo docker-compose build --no-cache
sudo docker-compose up
sudo docker-compose down
vim docker-compose.yaml 
vim backend/Dockerfile 
sudo docker-compose down
sudo docker-compose build --no-cache
sudo docker-compose down -v
sudo docker-compose build --no-cache
sudo docker-compose up
sudo docker-compose down -v
sudo docker-compose build --no-cache
sudo docker-compose up
sudo docker-compose down -v
sudo docker-compose build --no-cache
sudo docker-compose up
docker compose version
vim docker-compose.yaml 
sudo docker-compose down -v
vim docker-compose.yaml 
sudo docker-compose down -v
vim docker-compose.yaml 
sudo docker-compose down -v
sudo docker-compose build --no-cache
vim docker-compose.yaml 
docker compose down --volumes --remove-orphans
vim docker-compose.yaml 
docker compose version
docker info | grep -i nvidia
sudo docker info | grep -i nvidia
sudo vim /etc/docker/daemon.json
docker compose down --volumes --remove-orphans
sudo systemctl restart docker
docker info | grep -i runtime
sudo docker info | grep -i runtime
docker compose down --volumes --remove-orphans
vim docker-compose.yaml 
docker compose down --volumes --remove-orphans
sudo docker compose down --volumes --remove-orphans
sudo docker-compose build --no-cache
sudo docker-compose up
sudo docker compose down --volumes --remove-orphans
nvidia-smi
sudo docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
docker compose version
vim docker-compose.yaml 
sudo docker-compose build --no-cache
vim docker-compose.yaml 
sudo docker-compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker-compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker-compose up --build
vim docker-compose.yaml 
vim backend/Dockerfile 
sudo docker compose down --volumes --remove-orphans
sudo docker-compose up --build
vim backend/Dockerfile 
sudo docker-compose up --build
vim docker-compose.yaml 
sudo docker compose down --volumes --remove-orphans
vim docker-compose.yaml 
sudo docker-compose up --build
sudo docker compose down --volumes --remove-orphans
vim docker-compose.yaml 
vim backend/main.py 
vim docker-compose.yaml 
sudo docker compose down --volumes --remove-orphans
sudo docker-compose up --build
sudo lsof -i :6379
sudo systemctl stop redis
docker ps | grep 6379
sudo docker ps | grep 6379
sudo docker compose down --volumes --remove-orphans
sudo docker-compose up --build
sudo lsof -i :6379
sudo systemctl stop redis
sudo lsof -i :6379
sudo systemctl stop redis
sudo lsof -i :6379
ps aux | grep redis
killl -9 323260
kill -9 323260
ps aux | grep redis
kill -9 3491461
sudo kill -9 3491461
ps aux | grep redis
sudo docker-compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker-compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker-compose up --build
sudo docker compose down --volumes --remove-orphans
npm install -g @anthropic-ai/claude-code
sudo chown -R $(whoami) ~/.npm
npm install -g @anthropic-ai/claude-code
sudo chown -R $USER /usr/local/lib/node_modules
sudo mkdir /usr/local/lib/node_modules
sudo chown -R $USER /usr/local/lib/node_modules
npm install -g @anthropic-ai/claude-code
sudo docker-compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker-compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker-compose up --build
sudo docker compose up --build
sudo docker compose down --volumes --remove-orphans
sudo rm -rf ./ray_tmp
mkdir ./ray_tmp
sudo chmod 777 ./ray_tmp  # Make it writable for anyone (for now)
sudo docker compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker-compose build --no-cache
sudo docker compose build --no-cache
sudo docker compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker compose up --build
sudo docker compose build --no-cache
sudo docker compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker compose up --build
sudo docker compose down --volumes --remove-orphans
sudo docker compose up --build
sudo docker compose down --volumes --remove-orphans
docker tag glususer/mochi-backend:latest glususer/mochi-backend:v1.0.0
sudo docker login -u glususer
# Build backend service
./gubernates/scripts/deploy-all.sh 
vim gubernates/base/namespace.yaml 
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yaml
./gubernates/scripts/deploy-all.sh 
vim gubernates/scripts/deploy-all.sh 
sed -i '1i export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yaml' gubernates/deploy-all.sh
sed -i '1i export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yaml' gubernates/scripts/deploy-all.sh
vim gubernates/scripts/deploy-all.sh 
./gubernates/scripts/deploy-all.sh 
vim gubernates/scripts/deploy-all.sh 
./gubernates/scripts/deploy-all.sh 
sh ./gubernates/scripts/deploy-all.sh 
vim gubernates/scripts/deploy-all.sh 
sh ./gubernates/scripts/deploy-all.sh 
whereis kubectl
bash ./gubernates/scripts/deploy-all.sh 
sed -i 's/kubectl apply -f/kubectl apply --validate=false -f/g' gubernates/scripts/deploy-all.sh
bash ./gubernates/scripts/deploy-all.sh 
sed -i 's/kubectl /kubectl --kubeconfig=\/home\/ubuntu\/guru-kubeconfig.yaml /g' gubernates/scripts/deploy-all.sh
bash ./gubernates/scripts/deploy-all.sh 
ls
sed -i 's|guru-kubeconfig.yaml|guru-kubeconfig.yml|g' gubernates/scripts/deploy-all.sh
bash ./gubernates/scripts/deploy-all.sh 
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml delete pvc redis-pvc -n mochi-video-gen
bash ./gubernates/scripts/deploy-all.sh 
sed -i '73s/^/# /' gubernates/scripts/deploy-all.sh
bash ./gubernates/scripts/deploy-all.sh 
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml describe pod backend-7c7475f7f4-rnt7j -n mochi-video-gen
kubectl --kubeconfig=/home/ubuntu/guru-kubeconfig.yml get pods -n mochi-video-gen -w
sudo docker build -t glususer/mochi-backend:latest ./backend
sudo docker push glususer/mochi-backend:latest
ls
sudo docker build -t mochi-backend:latest -f gubernates/deployments/backend-dockerfile .
sudo docker tag mochi-backend:latest your-registry/mochi-backend:latest
sudo docker push your-registry/mochi-backend:latest
sudo docker login -u glususer
sudo docker push your-registry/mochi-backend:latest
sudo docker push glususer/mochi-backend:latest
sudo docker build -t mochi-backend:latest -f gubernates/deployments/backend-dockerfile .
sudo docker push glususer/mochi-backend:latest
sudo docker build -t mochi-backend:latest -f gubernates/deployments/backend-dockerfile .
sudo docker push glususer/mochi-backend:latest
sudo docker build -t mochi-backend:latest -f gubernates/deployments/backend-dockerfile .
vim backend/Dockerfile 
sudo docker push glususer/mochi-backend:latest
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two elephants jumping", "account_id":"guru"}'
sudo docker build -t glususer/mochi-backend:ray-client-fix /home/ubuntu/backend/
sudo docker push glususer/mochi-backend:ray-client-fix
sudo docker build -t glususer/mochi-backend:permissions-fix /home/ubuntu/backend/
ls /data/
ls -lrth /data/videos/
ls -lrth /data/
sudo docker build -t glususer/mochi-backend:no-mkdir /home/ubuntu/backend/
curl -X POST http://localhost:8001/generate -H "Content-Type: application/json" -d '{"prompt": "SUCCESS TEST", "account_id": "success"}'
curl http://localhost:8000/status/717face0-01ac-4cd4-b0e4-b2e76e331e57
curl http://localhost:8001/status/717face0-01ac-4cd4-b0e4-b2e76e331e57
curl -X POST http://localhost:8001/generate -H "Content-Type: application/json" -d '{"prompt": "SUCCESS TEST", "account_id": "success"}'
Bash(export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl get pods -n mochi-video-gen | grep ray)
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl get pods -n mochi-video-gen | grep ray)
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl get pods -n mochi-video-gen
curl -X POST http://localhost:8001/generate -H "Content-Type: application/json" -d '{"prompt": "SUCCESS TEST", "account_id": "success"}'
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl rollout restart deployment/backend -n mochi-video-gen
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl get pods -n mochi-video-gen
curl -X POST http://localhost:8001/generate -H "Content-Type: application/json" -d '{"prompt": "SUCCESS TEST", "account_id": "success"}'
curl -X POST http://localhost:8002/generate -H "Content-Type: application/json" -d '{"prompt": "SUCCESS TEST", "account_id": "success"}'
curl http://localhost:8002/status/e8c8ed78-0b5b-4d9f-b6a8-561454a6ee70
curl -X POST http://localhost:8002/generate -H "Content-Type: application/json" -d '{"prompt": "SUCCESS TEST", "account_id": "success"}'
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl get pods -n mochi-video-gen
curl -X POST http://localhost:8002/generate -H "Content-Type: application/json" -d '{"prompt": "SUCCESS TEST", "account_id": "success"}'
curl -X POST http://localhost:8003/generate -H "Content-Type: application/json" -d '{"prompt": "SUCCESS TEST", "account_id": "success"}'
curl -X POST http://localhost:8001/generate -H "Content-Type: application/json" -d '{"prompt": "SUCCESS TEST", "account_id": "success"}'
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "two elephants jumping", "account_id":"guru"}'
curl http://localhost:8000/status/f80586dc-860a-41f2-8116-cead1215ff8d
ls -lrth /data/
curl http://localhost:8000/status/f80586dc-860a-41f2-8116-cead1215ff8d
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-worker --tail=10
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-worker --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-head --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/backend --tail=100
curl http://localhost:8000/status/f80586dc-860a-41f2-8116-cead1215ff8d
ls -lrth /data/
curl http://localhost:8000/status/f80586dc-860a-41f2-8116-cead1215ff8d
vim gubernates/services/ray-services.yaml 
ls
cd ray
ls
vim Dockerfile 
cd ..
vim gubernates/deployments/ray-head-deployment.yaml 
cd /data/
ls -lrth
ls -lrth videos/
date
ls -lrth
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/backend --tail=20
ls -lrth
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/backend --tail=20
kubectl get pods -n mochi-video-gen -l app=backend -w
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml &&kubectl get pods -n mochi-video-gen -l app=backend -w
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl get pods -n mochi-video-gen -l app=backend -w
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/backend --tail=20
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/backend --tail=40
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/backend --tail=20
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/backend --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-worker --tail=100
kubectl get pods -n mochi-video-gen -l app=ray-head -o wide
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-worker --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-head --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-head-6466479dfb-f6zbf --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-head --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-worker --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-head --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-worker --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl logs -n mochi-video-gen deployment/ray-head --tail=100
export KUBECONFIG=/home/ubuntu/guru-kubeconfig.yml && kubectl port-forward -n mochi-video-gen svc/backend-service 8000:8000 &
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
docker-compose logs -f backend
sudo docker-compose logs -f backend
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
sudo docker-compose logs -f backend
sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker
docker run --gpus all nvidia/cuda:12.2.0-base-ubuntu20.04 nvidia-smi
sudo docker run --gpus all nvidia/cuda:12.2.0-base-ubuntu20.04 nvidia-smi
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
sudo docker-compose logs -f backend
docker exec -it ubuntu_backend_1 python -c "import torch; print(torch.cuda.is_available())"
sudo docker exec -it ubuntu_backend_1 python -c "import torch; print(torch.cuda.is_available())"
nvidia-smi
docker info | grep -i runtime
sudo docker info | grep -i runtime
vim docker-compose.yaml 
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
sudo vim /etc/docker/daemon.json
vim docker-compose.yaml 
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
sudo docker-compose logs -f backend
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
docker exec -it <backend_container_id> python -c "import torch; print(torch.cuda.is_available())"
sudo docker exec -it ubuntu_backend_1 python -c "import torch; print(torch.cuda.is_available())"
sudo docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
vim backend/main.py 
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
curl http://localhost:8000/status/ef215917-1eeb-49c2-b67a-9dabc349bd12
vim backend/main.py 
curl http://localhost:8000/status/ef215917-1eeb-49c2-b67a-9dabc349bd12
vim backend/main.py 
vim docker-compose.yaml 
sudo docker-compose down
sudo docker-compose build --no-cache
vim docker-compose.yaml 
curl http://localhost:8000/status/ef215917-1eeb-49c2-b67a-9dabc349bd12
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
pwd
ls
mkdir ray
cd ray
vim Dockerfile
cd ..
vim docker-compose.yaml 
# Install stable version (default)
curl -fsSL https://claude.ai/install.sh | bash
# Install latest version
curl -fsSL https://claude.ai/install.sh | bash -s latest
# Install specific version number
curl -fsSL https://claude.ai/install.sh | bash -s 1.0.58
curl -X POST http://localhost:8000/generate   -H "Content-Type: application/json"   -d '{"prompt": "futuristic dragon on a skyscraper", "account_id": "guru"}'
vim docker-compose.yaml 
sudo docker-compose down
claude
df -h
claude
vim .claude.json
claude
cd backend/
ls
claude
ssh-keygen -t ed25519 -C "gururaj.kosuru@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
cd /home/ubuntu/backend/
sudo docker build -t glususer/mochi-backend:warm-model -f Dockerfile .
sudo docker push glususer/mochi-backend:warm-model
