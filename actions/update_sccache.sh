#!/bin/bash

set -euo pipefail

LATEST_SCCACHE_VERSION=$(
  gh release list \
    --repo rapidsai/sccache \
    --exclude-drafts \
    --limit 100 \
    --json tagName \
    --jq '[.[].tagName | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+-rapids\\.[0-9]+$"))][0]'
)

if [[ -z "${LATEST_SCCACHE_VERSION}" || "${LATEST_SCCACHE_VERSION}" == "null" ]]; then
  echo "Failed to find a rapidsai/sccache release tag." >&2
  exit 1
fi

echo "LATEST_SCCACHE_VERSION = ${LATEST_SCCACHE_VERSION}"

DIR_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
SCCACHE_ACTION="${DIR_PATH}/sccache/action.yml"

sed -i -E \
  "s/(default:[[:space:]]*)'v[0-9]+\.[0-9]+\.[0-9]+-rapids\.[0-9]+'/\1'${LATEST_SCCACHE_VERSION}'/" \
  "${SCCACHE_ACTION}"
