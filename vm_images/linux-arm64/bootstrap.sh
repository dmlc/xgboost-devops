#!/bin/bash
set -euo pipefail

## Install basic tools
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt-get update
sudo apt-get install -y cmake git build-essential wget ca-certificates curl unzip

## Install Python3
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv
sudo pip3 install --break-system-packages 'pip>=23' 'wheel>=0.42' pydistcheck

## Install Docker
# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Allow users to use Docker without sudo
sudo usermod -aG docker ubuntu

# Start Docker daemon
sudo systemctl is-active --quiet docker.service || sudo systemctl start docker.service
sudo systemctl is-enabled --quiet docker.service || sudo systemctl enable docker.service
sleep 10  # Docker daemon takes time to come up after installing
sudo docker info
sudo systemctl stop docker

## Install AWS CLI v2
wget -nv https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -O awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf ./aws/ ./awscliv2.zip

## Install jq and yq
sudo apt update && sudo apt install jq
mkdir yq/
pushd yq/
wget -nv https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_arm64.tar.gz -O - | \
  tar xz && sudo mv ./yq_linux_arm64 /usr/bin/yq
popd
rm -rf yq/
