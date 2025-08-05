#!/bin/bash

exec > /var/log/scriptone.log 2>&1

sudo apt-get update && sudo apt-get install -y build-essential fakeroot devscripts autotools-dev debhelper git

curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub | sudo apt-key add -

echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" | sudo tee /etc/apt/sources.list.d/nvidia-cuda.list

sudo apt-get update


#add the following to /etc/apt/preferences.d/nvidia-560
sudo mkdir -p /etc/apt/preferences.d

# Create the file with the specified content
sudo tee /etc/apt/preferences.d/nvidia-560 > /dev/null << 'EOF'
Package: nvidia-driver-560
Pin: version 560.35.03-0ubuntu1
Pin-Priority: 1001

Package: nvidia-dkms-560-open
Pin: version 560.35.03-0ubuntu1
Pin-Priority: 1001

Package: nvidia-utils-560
Pin: version 560.35.03-0ubuntu1
Pin-Priority: 1001

Package: libnvidia-cfg1-560
Pin: version 560.35.03-0ubuntu1
Pin-Priority: 1001

Package: nvidia-kernel-common-560
Pin: version 560.35.03-0ubuntu1
Pin-Priority: 1001

Package: nvidia-fabricmanager-560
Pin: version 560.35.03-1
Pin-Priority: 1001
EOF

echo "File /etc/apt/preferences.d/nvidia-560 has been created."

#And then update cache
sudo apt-get update

# Install all NVIDIA packages explicitly with the given version numbers
sudo apt-get install -y --allow-downgrades     nvidia-dkms-560-open=560.35.03-0ubuntu1     nvidia-utils-560=560.35.03-0ubuntu1     libnvidia-cfg1-560=560.35.03-0ubuntu1     nvidia-driver-560-open=560.35.03-0ubuntu1     nvidia-kernel-source-560-open=560.35.03-0ubuntu1     nvidia-kernel-common-560=560.35.03-0ubuntu1     libnvidia-compute-560=560.35.03-0ubuntu1     libnvidia-extra-560=560.35.03-0ubuntu1     nvidia-compute-utils-560=560.35.03-0ubuntu1     libnvidia-decode-560=560.35.03-0ubuntu1     libnvidia-encode-560=560.35.03-0ubuntu1     xserver-xorg-video-nvidia-560=560.35.03-0ubuntu1     libnvidia-fbc1-560=560.35.03-0ubuntu1     libnvidia-gl-560=560.35.03-0ubuntu1     nvidia-fabricmanager-560=560.35.03-1

# Install all CUDA packages explicitly with the given version numbers
sudo apt-get install -y --allow-downgrades     cuda-toolkit-12-6=12.6.2-1     cuda-nsight-compute-12-6=12.6.2-1     cuda-nsight-systems-12-6=12.6.2-1     cuda-tools-12-6=12.6.2-1     cuda-visual-tools-12-6=12.6.2-1     libcub-dev=1.15.0-3

# Install all cuDNN packages explicitly with the given version numbers
sudo apt-get install -y --allow-downgrades     libcudnn9-cuda-12=9.4.0.58-1     cudnn=9.4.0-1     cudnn9=9.4.0-1     cudnn9-cuda-12=9.4.0.58-1     cudnn9-cuda-12-6=9.4.0.58-1     libcudnn9-dev-cuda-12=9.4.0.58-1     libcudnn9-static-cuda-12=9.4.0.58-1


# Install NCCL packages explicitly with the given version numbers
sudo apt-get install -y --allow-downgrades     libnccl-dev=2.23.4-1+cuda12.6     libnccl2=2.23.4-1+cuda12.6


# Install NVIDIA profiling tools
sudo apt-get install -y     nvidia-cuda-gdb     nvidia-profiler     nvidia-visual-profiler

#peer mem nonsense
sudo modprobe -v nvidia_peermem


sudo wget -O "/opt/MLNX_OFED_LINUX-24.07-0.6.1.0-ubuntu22.04-x86_64.tgz" https://www.mellanox.com/downloads/ofed/MLNX_OFED-24.07-0.6.1.0/MLNX_OFED_LINUX-24.07-0.6.1.0-ubuntu22.04-x86_64.tgz

sudo chmod 0644 "/opt/MLNX_OFED_LINUX-24.07-0.6.1.0-ubuntu22.04-x86_64.tgz"

sudo mkdir -p "/tmp/mlnx"

sudo tar --strip-components=1 -xzf "/opt/MLNX_OFED_LINUX-24.07-0.6.1.0-ubuntu22.04-x86_64.tgz" -C "/tmp/mlnx"

sudo chown -R ubuntu:ubuntu "/tmp/mlnx"

sudo chmod -R 0755 "/tmp/mlnx"

yes | sudo "/tmp/mlnx/MLNX_OFED_LINUX-24.07-0.6.1.0-ubuntu22.04-x86_64/mlnxofedinstall" --force


sudo apt-get install -y     openmpi-bin     openmpi-common     libopenmpi-dev     libgtk2.0-dev     infiniband-diags     ibverbs-utils     libibverbs-dev     libfabric1     libfabric-dev     libpsm2-dev     librdmacm-dev     libnvvm4

sudo reboot
