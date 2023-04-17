#!/usr/bin/env bash

set -e

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

version=latest-stable
arch=aarch64
destination="${script_dir}/apks/${version}/${arch}"

mkdir -p "${destination}"

read -ra packages < <(xargs < "${script_dir}/packages.list")

apk fetch \
    --allow-untrusted \
    --no-cache \
    --repository "https://dl-cdn.alpinelinux.org/alpine/${version}/main" \
    --repository "https://dl-cdn.alpinelinux.org/alpine/${version}/community" \
    --arch ${arch} \
    --recursive \
    --output "${destination}" \
    "${packages[@]}"
