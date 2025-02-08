#!/bin/bash
## Extract container definition and build args from containers/ci_container.yml,
## given the image repo.
##
## Example input:
##   xgb-ci.clang_tidy
## Example output:
##   CONTAINER_DEF='clang_tidy' BUILD_ARGS='--build-arg CUDA_VERSION_ARG=12.4.1'

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [image_repo]"
    exit 1
fi

IMAGE_REPO="$1"
CONTAINER_DEF=$(
  yq -o json containers/ci_container.yml |
  jq -r --arg image_repo "${IMAGE_REPO}" '.[$image_repo].container_def'
)
BUILD_ARGS=$(
  yq -o json containers/ci_container.yml |
  jq -r --arg image_repo "${IMAGE_REPO}" \
  'include "containers/extract_build_args";
    compute_build_args(.; $image_repo)'
)
echo "CONTAINER_DEF='${CONTAINER_DEF}' BUILD_ARGS='${BUILD_ARGS}'"
