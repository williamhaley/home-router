#!/usr/bin/env bash

set -e

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -f "${script_dir}/abuild.rsa" ] || [ ! -f "${script_dir}/abuild.rsa.pub" ]
then
    openssl genrsa -out "${script_dir}/abuild.rsa" 2048
    openssl rsa -in "${script_dir}/abuild.rsa" -pubout -out "${script_dir}/abuild.rsa.pub"
fi

if [ ! -f "${script_dir}/router" ] || [ ! -f "${script_dir}/router.pub" ]
then
    ssh-keygen -f "${script_dir}/router"
fi

docker build -t home-router .
docker run --rm -it -v ./:/output home-router sh -c "cp /home-router.tar /output/"
