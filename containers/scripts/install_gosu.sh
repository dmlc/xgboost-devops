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

if command -v wget >/dev/null 2>&1; then
  wget -nv -O /usr/local/bin/gosu "${gosu_url}"
elif command -v curl >/dev/null 2>&1; then
  curl -fsSL -o /usr/local/bin/gosu "${gosu_url}"
else
  echo "Either wget or curl is required to install gosu" >&2
  exit 1
fi

chmod +x /usr/local/bin/gosu
gosu nobody true
