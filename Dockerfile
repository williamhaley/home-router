FROM alpine AS extracted

ADD https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-rpi-3.21.3-aarch64.tar.gz /scratch/

RUN mkdir /alpine && tar -xzvf /scratch/alpine-rpi-3.21.3-aarch64.tar.gz -C /alpine

###############################################################################
#                                                                             #
# packages                                                                    #
#                                                                             #
###############################################################################

FROM alpine AS packages

RUN apk add bash abuild

WORKDIR /apks

# Is it a good idea to smash our downloaded packages in with the ones from upstream?
COPY --from=extracted /alpine/apks/aarch64/ ./

ADD ./abuild.rsa /
ADD ./abuild.rsa.pub /

ADD ./packages.list .

RUN bash <<'EOF'
set -ex

version=latest-stable
arch=aarch64

read -ra packages < <(xargs < "./packages.list")

apk fetch \
    --allow-untrusted \
    --no-cache \
    --repository "https://dl-cdn.alpinelinux.org/alpine/${version}/main" \
    --repository "https://dl-cdn.alpinelinux.org/alpine/${version}/community" \
    --arch ${arch} \
    --recursive \
    --output . \
    "${packages[@]}"
EOF

RUN apk index --allow-untrusted --verbose --arch aarch64 --rewrite-arch=aarch64 --update-cache --output "./APKINDEX.tar.gz" ./*.apk
RUN abuild-sign -k /abuild.rsa -p /abuild.rsa.pub ./APKINDEX.tar.gz

###############################################################################
#                                                                             #
# initramfs                                                                   #
#                                                                             #
###############################################################################

FROM alpine AS initramfs

RUN apk add gzip cpio

COPY --from=extracted /alpine/boot/initramfs-rpi /initramfs

WORKDIR /scratch

RUN gzip --to-stdout --decompress /initramfs | cpio --extract --make-directories --preserve-modification-time --verbose

# Add host system public key to the initramfs. This is how packages can be trusted and installed at boot time.
COPY ./abuild.rsa.pub ./etc/apk/keys/

RUN find . -print0 | cpio --null -ov --format=newc > /initramfs-rpi
RUN gzip /initramfs-rpi

RUN mv /initramfs-rpi.gz /initramfs-rpi

###############################################################################
#                                                                             #
# application                                                                 #
#                                                                             #
###############################################################################

FROM golang:1.24 AS application

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY ./cmd ./cmd
COPY ./ui ./ui

RUN GOOS=linux GOARCH=arm64 go build -o /usr/local/bin/configure ./cmd/cli/configure.go
RUN GOOS=linux GOARCH=arm64 go build -o /usr/local/bin/admin-ui ./cmd/main.go

###############################################################################
#                                                                             #
# additional files                                                            #
#                                                                             #
###############################################################################

FROM alpine AS additions

RUN apk add tar

WORKDIR /headless

ADD ./headless .

# Services that must run early before networking and other services are available.
RUN mkdir -p ./etc/runlevels/sysinit
# Running local at sysinit seems irregular, but I'd rather do that for one-shot boot setup scripts than hack at inittab.
# Alternatively, maybe it's better to just write a custom init script for these unorthodox boot steps until a better entrypoint is found?
RUN ln -s /etc/init.d/local ./etc/runlevels/sysinit/

COPY --from=application /usr/local/bin/configure ./usr/local/bin/
COPY --from=application /usr/local/bin/admin-ui ./usr/local/bin/

RUN tar --owner=0 --group=0 --create --file="/headless.apkovl.tar" ./*

RUN gzip /headless.apkovl.tar

###############################################################################
#                                                                             #
# publish                                                                     #
#                                                                             #
###############################################################################

FROM alpine AS publish

RUN apk add bash tar

ADD ./packages.list /

COPY --from=extracted /alpine /alpine
COPY --from=packages /apks/ /alpine/apks/aarch64/
COPY --from=initramfs /initramfs-rpi /alpine/boot/initramfs-rpi
COPY --from=additions /headless.apkovl.tar.gz /alpine/

RUN bash <<'EOF'
set -e

packages="$(xargs < "/packages.list" | tr ' ' ',')"

sh -c "echo modules=loop,squashfs,sd-mod,usb-storage quiet console=tty1 pkgs=${packages}" > /alpine/cmdline.txt
EOF

COPY <<EOF /alpine/boot/firmware/config.txt
dtparam=ant2
EOF

WORKDIR /alpine

RUN tar --owner=0 --group=0 --create --file="/home-router.tar" ./*
