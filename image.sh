#!/usr/bin/env bash

set -e

[ $EUID -eq 0 ] && echo "do not run as root" >&2 && exit 1

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -b "${1}" ]
then
	echo "'${1}' is not a block device"
	exit 1
fi

sudo umount "${1}1" || true

sudo fdisk "${1}" << EOF
o
n
p
1


t
b
a
w
EOF

sudo umount "${1}1" || true
# see boot.start
sudo mkfs.vfat -F 32 -n HRCONFBD "${1}1"
sudo umount "${1}1" || true

boot="$(mktemp -d)"

echo "boot: '${boot}'"

sudo mount "${1}1" "${boot}"

sudo tar -x --no-same-owner --no-same-permissions --file="${script_dir}/home-router.tar" --directory="${boot}"

sudo cp "${script_dir}/home-router.yaml" "${boot}/"
sudo cp "${script_dir}/router.pub" "${boot}/admin_ssh_key"

sudo sync
