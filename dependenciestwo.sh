#!/bin/bash

exec > /var/log/scripttwo.log 2>&1

sudo apt install nfs-common -y

# Unmask the nvidia-fabricmanager service
sudo systemctl unmask nvidia-fabricmanager

# Restart the nvidia-fabricmanager service
sudo systemctl restart nvidia-fabricmanager

# Ensure the nvidia-fabricmanager service is enabled to start on boot
sudo systemctl enable nvidia-fabricmanager

sudo apt update

mkdir -p /opt/install/vast
cd /opt/install/vast
curl -sSf https://vast-nfs.s3.amazonaws.com/download.sh -o download.sh
bash download.sh
file=$(ls -ltr vastnfs-*.tar.xz | awk {'print $9'} | tail -1)
tar -xvf /opt/install/vast/${file} -C /opt/install/vast
dir=$(ls -d */ | sed 's/\///')
cd /opt/install/vast/${dir}
while pgrep apt > /dev/null; do   sleep 1 ; done
./build.sh bin
vastnfs_deb=$(ls -1 /opt/install/vast/${dir}/dist/vastnfs-dkms*_all.deb)
chmod 755 $vastnfs_deb
dpkg -i $vastnfs_deb
update-initramfs -u -k $(uname -r)
# echo 'reboot' > /run/cloud-init/instance-data.result
# echo "Reboot signal sent to cloud-init."

# Update package list and install required packages
apt-get update
apt-get install -y git make openmpi-bin openmpi-common

# Clone the repository to /opt/nccl-tests
git clone https://github.com/NVIDIA/nccl-tests.git /opt/nccl-tests

# Change directory to the cloned repo and checkout the master branch
cd /opt/nccl-tests && sudo git checkout master

# Build the nccl tests with the provided options
sudo make MPI=1 MPI_HOME=/usr/lib/x86_64-linux-gnu/openmpi CUDA_HOME=/usr/local/cuda NCCL_HOME=/usr

sudo sed -i 's/--no-persistence-mode//' /lib/systemd/system/nvidia-persistenced.service
sudo systemctl daemon-reload
sudo systemctl restart nvidia-persistenced.service

# here we raise mtu up to 9000
sed -i.bak 's/1500/9000/g' /etc/netplan/50-cloud-init.yaml
sudo netplan apply

#next we make changes to sysctl.conf
sudo tee -a /etc/sysctl.conf << 'EOF'

# allow TCP with buffers up to 2GB (Max allowed in Linux is 2GB-1)
net.core.rmem_max=2147483647
net.core.wmem_max=2147483647
# increase TCP autotuning buffer limits.
net.ipv4.tcp_rmem=4096 131072 1073741824
net.ipv4.tcp_wmem=4096 16384 1073741824
# recommended for hosts with jumbo frames enabled
net.ipv4.tcp_mtu_probing=1
# don't cache TCP metrics from previous connection
net.ipv4.tcp_no_metrics_save = 1

EOF

echo "We did it!" > /home/ubuntu/done.txt

sudo reboot
