#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${CUDA_VERSION:-}" ]]; then
  echo "CUDA_VERSION must be set" >&2
  exit 1
fi

if [[ -z "${CUDA_REPO_ARCH:-}" ]]; then
  case "${ARCH:-$(uname -m)}" in
    aarch64 | arm64)
      CUDA_REPO_ARCH="sbsa"
      ;;
    x86_64 | amd64)
      CUDA_REPO_ARCH="x86_64"
      ;;
    *)
      echo "Unsupported CUDA repository architecture: ${ARCH:-$(uname -m)}" >&2
      exit 1
      ;;
  esac
fi

curl -fsSL "https://developer.download.nvidia.com/compute/cuda/repos/rhel8/${CUDA_REPO_ARCH}/D42D0685.pub" \
  | sed '/^Version/d' > /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA

dnf -y install dnf-plugins-core python3-dnf-plugin-versionlock

CUDA_SHORT_DASHED=$(echo "${CUDA_VERSION}" | grep -o -E '[0-9]+\.[0-9]' | tr . -)
mapfile -t CUDA_LOCK_PACKAGES < <(rpm -qa --qf '%{NAME}\n' | sed -n "/-${CUDA_SHORT_DASHED}$/p")

if [[ ${#CUDA_LOCK_PACKAGES[@]} -eq 0 ]]; then
  echo "No installed CUDA packages matched CUDA_VERSION=${CUDA_VERSION}" >&2
  exit 1
fi

dnf versionlock add "${CUDA_LOCK_PACKAGES[@]}"
dnf -y update
dnf config-manager --set-enabled powertools
