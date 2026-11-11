#!/bin/bash
# Cache Docker layers in the AMI to avoid downloading/extracting them on every job.
# Remove this step if runners gain a persistent image cache or stop using xgb-ci.gpu.
set -euo pipefail

registry=492475357299.dkr.ecr.us-west-2.amazonaws.com
image="${registry}/xgb-ci.gpu:main"

# Use the builder's instance profile and an ephemeral Docker config so ECR tokens
# are not baked into the AMI. CI must still pull its requested tag to pick up updates.
docker_config=$(mktemp -d)
trap 'sudo rm -rf "$docker_config"' EXIT
sudo systemctl start docker
aws ecr get-login-password --region "$AWS_DEFAULT_REGION" |
  sudo docker --config "$docker_config" login --username AWS --password-stdin "$registry"
sudo docker --config "$docker_config" pull "$image"
sudo docker run --rm --pull=never --gpus all --entrypoint nvidia-smi "$image"
# Record the digest and size in the build log to identify what the snapshot contains.
sudo docker image inspect --format '{{json .RepoDigests}} {{.Size}}' "$image"

# Preserve the downloaded layers, but stop writes before Packer snapshots the disk.
sudo systemctl stop docker.service docker.socket containerd.service
sync
