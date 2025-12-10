#!/bin/bash

set -euo pipefail

LATEST_RAPIDS_VERSION=$(gh api repos/rapidsai/cuml/releases/latest --jq '.name' | sed -e 's/^v\([[:digit:]]\+\.[[:digit:]]\+\).*/\1/')
echo "LATEST_RAPIDS_VERSION = $LATEST_RAPIDS_VERSION"

DIR_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
CONTAINER_YAML="$DIR_PATH/ci_container.yml"

sed -i "s/\&rapids_version \"[[:digit:]]\+\.[[:digit:]]\+\"/\&rapids_version \"${LATEST_RAPIDS_VERSION}\"/" \
  "$CONTAINER_YAML"
