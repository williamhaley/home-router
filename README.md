# Home Router

An exercise in building a home router using Alpine Linux and a Raspberry Pi.

See [LICENSE](LICENSE). This software and information come with no warranties or guarantees, and are intended for educational uses only.

## Prerequisites

These steps assume a Raspberry Pi 4 or 5 with its default network hardware (`eth0`, `wlan0`) working properly. `eth0`, the stock ethernet interface on the Pi, should be connected to a working upstream modem or other network device that can provide an IP address via DHCP.

A wired USB ethernet adapter should also be connected to the Pi and may serve as a local LAN interface, to which a wired switch could potentially be connected.

A machine with at least `apk`, `fdisk`, `openssl`, `openssh`, and typical Linux tooling is required to run the steps below. Alpine's [apk](https://archlinux.org/packages/extra/x86_64/apk-tools/) tools are needed to run `./fetch-packages.sh` below. The [official Docker Alpine image](https://hub.docker.com/_/alpine/) can be used to run `fetch-packages.sh` instead if `apk` is not natively available.

## Build

Set up a config file and customize it as needed.

```
cp ./home-router.sample.yaml ./home-router.yaml
```

Generate a custom OS image that we will later use on a Raspberry Pi.

```
./build.sh
```

## Deploy

Write everything to the SD card that will be used by the Raspberry Pi.

```
./image.sh /dev/sdX
```

## Connect

SSH to the router. Until persistent host keys are working it may be cleanest to discard them for now by writing `UserKnownHostsFile` to `/dev/null`.

```
ssh -i ~/.ssh/router -o "UserKnownHostsFile=/dev/null" admin@router.local
```

Navigate to the router's web interface.

```
http://router.local
http://10.0.0.1
```

## Audit

Open ports can be scanned from within, or outside of, the router's LAN. Using a pre-existing LAN to discretely test the `eth0` (WAN) interface of the router could uncover potential security holes in the firewall.

```
sudo nmap --min-rate=5000 -sT -p- 10.0.0.1
sudo nmap --min-rate=5000 -sU -p- 10.0.0.1
```

# [Changelog](CHANGELOG.md)

# [License](LICENSE)
