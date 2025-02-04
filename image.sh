#!/usr/bin/env bash

set -e

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -b "${1}" ]
then
	echo "'${1}' is not a block device"
	exit 1
fi

sudo umount "${1}1" || true
sudo umount "${1}2" || true

sudo fdisk "${1}" << EOF
o
n
p
1

+1G
t
06
a
n
p
2


t
2
b
w
EOF

sudo umount "${1}1" || true
sudo mkdosfs -F 16 "${1}1"
sudo umount "${1}1" || true

sudo umount "${1}2" || true
# see boot.start
sudo mkfs.vfat -F 32 -n HRCONFBD "${1}2"
sudo umount "${1}2" || true

boot="$(mktemp -d)"
config="$(mktemp -d)"
scratch=$(mktemp -d)
initramfs=$(mktemp -d)

echo "boot: '${boot}'"
echo "config: '${boot}'"
echo "scratch: '${scratch}'"

sudo mount "${1}1" "${boot}"
sudo mount "${1}2" "${config}"

sudo tar -xz --no-same-owner --no-same-permissions --file="${script_dir}/alpine-rpi-3.21.2-aarch64.tar.gz" --directory="${boot}"

mkdir -p "${scratch}/usr/local/bin"
GOOS=linux GOARCH=arm64 go build -o "${scratch}/usr/local/bin/configure" "${script_dir}/cmd/cli/configure.go"
GOOS=linux GOARCH=arm64 go build -o "${scratch}/usr/local/bin/admin-ui" "${script_dir}/cmd/main.go"

# Services that must run early before networking and other services are available.
mkdir -p "${scratch}/etc/runlevels/sysinit"
# Running local at sysinit seems irregular, but I'd rather do that for one-shot boot setup scripts than hack at inittab.
# Alternatively, maybe it's better to just write a custom init script for these unorthodox boot steps until a better entrypoint is found?
ln -s /etc/init.d/local "${scratch}/etc/runlevels/sysinit/"

pushd "${script_dir}/headless"
	sudo tar --owner=0 --group=0 --create --file="${boot}/headless.apkovl.tar" ./*
popd

pushd "${scratch}"
	sudo tar --owner=0 --group=0 --append --file="${boot}/headless.apkovl.tar" ./*
popd
pushd "${boot}"
	sudo gzip headless.apkovl.tar
popd

pushd "${initramfs}"
	gzip --to-stdout --decompress "${boot}/boot/initramfs-rpi" | cpio --extract --make-directories --preserve-modification-time --verbose
	cp "${HOME}/.abuild/abuild.rsa.pub" ./etc/apk/keys/
	find . -print0 | sudo cpio --null -ov --format=newc > "${boot}/boot/initramfs-rpi.uncompressed"
popd
pushd "${boot}/boot"
	sudo gzip initramfs-rpi.uncompressed
	sudo mv initramfs-rpi.uncompressed.gz initramfs-rpi
popd

sudo cp "${script_dir}/apks/latest-stable/aarch64"/* "${boot}/apks/aarch64/"
sudo rm -f "${boot}/apks/aarch64/APKINDEX.tar.gz"
sudo apk index --allow-untrusted --verbose --arch aarch64 --rewrite-arch=aarch64 --update-cache --output "${boot}/apks/aarch64/APKINDEX.tar.gz" ${boot}/apks/aarch64/*.apk
sudo abuild-sign -k "${HOME}/.abuild/abuild.rsa" -p "${HOME}/.abuild/abuild.rsa.pub" "${boot}/apks/aarch64/APKINDEX.tar.gz"

sudo cp "${script_dir}/home-router.yaml" "${config}/"
sudo cp "${HOME}/.ssh/router.pub" "${config}/admin_ssh_key"

packages="$(xargs < "${script_dir}/packages.list" | tr ' ' ',')"

sudo sh -c "echo modules=loop,squashfs,sd-mod,usb-storage quiet console=tty1 pkgs=${packages} > ${boot}/cmdline.txt"

sudo sync

rm -rf "${scratch}"
rm -rf "${initramfs}"
