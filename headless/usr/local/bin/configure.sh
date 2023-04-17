#!/bin/sh

log_file="/var/log/configuration.log"

echo "configure: start: $(date)" >> "${log_file}"

configure -t /etc/network/interfaces.template -o /etc/network/interfaces

configure -t /etc/nftables.nft.template -o /etc/nftables.nft
configure -t /etc/nftables.d/port-forwarding.nft.template -o /etc/nftables.d/port-forwarding.nft

configure -t /etc/dnsmasq.conf.template -o /etc/dnsmasq.conf
configure -t /etc/addn-hosts.template -o /etc/addn-hosts
configure -t /etc/dhcp-hostsfile.template -o /etc/dhcp-hostsfile

configure -t /etc/ddclient/ddclient.conf.template -o /etc/ddclient/ddclient.conf

configure -t /etc/hostapd/hostapd.ac.conf.template -o /etc/hostapd/hostapd.conf

echo "configure: done: $(date)" >> "${log_file}"
