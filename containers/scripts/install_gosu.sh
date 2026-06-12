#!/usr/bin/env sh
set -eu

if [ -z "${GOSU_VERSION:-}" ]; then
  echo "GOSU_VERSION must be set" >&2
  exit 1
fi

arch="${1:-${GOSU_ARCH:-${ARCH:-$(uname -m)}}}"
case "${arch}" in
  x86_64 | amd64)
    gosu_arch="amd64"
    ;;
  aarch64 | arm64)
    gosu_arch="arm64"
    ;;
  i386 | i686)
    gosu_arch="i386"
    ;;
  *)
    echo "Unsupported gosu architecture: ${arch}" >&2
    exit 1
    ;;
esac

gosu_url="https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${gosu_arch}"

case "${GOSU_VERSION}:${gosu_arch}" in
  1.10:amd64)
    gosu_sha256="5b3b03713a888cee84ecbf4582b21ac9fd46c3d935ff2d7ea25dd5055d302d3c"
    ;;
  1.10:arm64)
    gosu_sha256="3ebbff47692c3d9f0c3b6500727e277cb23d621feebcac0cc3d9e382d62d1acb"
    ;;
  1.10:i386)
    gosu_sha256="2dfac0dd8830ebccea486d90472b48e68de5a543d9fb50bea933bbe6a9c8d610"
    ;;
  *)
    echo "Unsupported gosu version/architecture for checksum verification: ${GOSU_VERSION}/${gosu_arch}" >&2
    exit 1
    ;;
esac

if command -v wget >/dev/null 2>&1; then
  wget -nv -O /usr/local/bin/gosu "${gosu_url}"
elif command -v curl >/dev/null 2>&1; then
  curl -fsSL -o /usr/local/bin/gosu "${gosu_url}"
else
  echo "Either wget or curl is required to install gosu" >&2
  exit 1
fi

printf '%s  %s\n' "${gosu_sha256}" /usr/local/bin/gosu | sha256sum -c -
chmod +x /usr/local/bin/gosu
gosu nobody true
