# Changelog

Release notes and changes for the home-router project.

# 2025-02-04

This is something I've tinkered with since maybe 2010-ish, but formalized in early 2025. I thought back to my computer science courses and the various pieces of technology that we typically sum up as a "router" today.

* Gateway
* NAT
* DHCP server
* DNS server
* Firewall
* Access point
* Wired switch
* Web management UI
* etc...

As an experiment, I set up and used a Raspberry Pi to simulate each role of a typical home router. One Pi for a DHCP server, one for a DNS server, one for an access point, etc. Impractical, but educational.

I also wanted a more convenient way to establish persistent host/alias records for various machines on my LAN. While OpenWRT can handle much of what is in this project, I find it cumbersome and the UI complicated. I wanted something simple that I could build up myself.

Now this project is more of a pet for my home lab and a place to tinker with various networking services.

Like a typical consumer-grade home router this project builds on a wealth of existing open source technology and ideas provided freely on the Internet.

Most recently, thank you to the authors and contributors who granted me insight with their collective work in these articles.

* https://ubiq.co/tech-blog/how-to-whitelist-ip-in-nginx/
* https://pkgs.alpinelinux.org/package/edge/main/x86/dnsmasq-openrc
* https://github.com/macmpi/alpine-linux-headless-bootstrap
* https://wiki.alpinelinux.org/wiki/Manually_editing_a_existing_apkovl
* https://wiki.alpinelinux.org/wiki/Writing_Init_Scripts
* https://wiki.alpinelinux.org/wiki/Configure_Networking
* https://github.com/OpenRC/openrc/blob/master/user-guide.md
* https://medium.com/@renaudcerrato/how-to-build-your-own-wireless-router-from-scratch-part-2-494a24e44a1b
* https://serverfault.com/questions/1113385/what-is-the-iptables-equivalent-to-what-socat-does
* https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
* https://wiki.gentoo.org/wiki/Nftables
* https://www.erianna.com/creating-a-alpine-linux-repository/
* https://wiki.alpinelinux.org/wiki/Include:Abuild-keygen
* https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-configuring_port_forwarding_using_nftables#sec-Forwarding_incoming_packets_on_a_specific_local_port_to_a_different_host
* https://wiki.nftables.org/wiki-nftables/index.php/Simple_ruleset_for_a_home_router
* https://superuser.com/a/1522244/770509
* https://wiki.gentoo.org/wiki//etc/local.d
* https://irclogs.alpinelinux.org/%23alpine-linux-2022-08.log

This project is not intended for use by any audience in any reliable or meaningful way. This work is intended as educational material only, but perhaps my learnings, mistakes, and the insights I've gleaned can help guide others.
