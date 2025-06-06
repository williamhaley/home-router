# Changelog

Release notes and changes for the home-router project.

# 2025-06-06

Some services were not running at the ideal runlevel. `ddclient`, `sshd`, and `ntpd` were modified.

# 2025-04-10

Over the past couple months I worked on and off to try and use Debian (with Raspberry Pi's firmware) as the base image for this project. Unfortunately, I found that process to be cumbersome and unreliable. I got a working pipeline and image, but with kernel panics, slower speed, and much more work required. I'm sure those issues could be resolved over time, but it was enough of a time sink that I am going to abandon it completely.

Instead, these changes pull in some maintainability best practices learned from the failed Debian refactor.

# 2025-02-07

A bug's become a greater nuisance. Port-forwarding, as it's often referred to on a consumer home router, is working. External requests are routed properly. However, internal requests to public DNS names (like `my-host.my-domain.net`) that resolve to a resource in the LAN are timing out. It seems related to my `prerouting` and `postrouting` rules in `port-forwarding.nft.template` for `nftables`. I want requests for resources within the LAN to resolve just like they would for external requests from the Internet.

I hadn't heard this term before, but a few articles I read referred to this issue in relation to "Hairpin NAT". That plus a `fib` rule in `nftables` allowed me to route traffic properly whether it's from an internal or external source.

* https://serverfault.com/a/1144851/373603
* https://www.reddit.com/r/linuxquestions/comments/sb86tk/cant_get_dnat_working_with_nftables_when_coming/
* https://serverfault.com/questions/205040/accessing-the-dnatted-webserver-from-inside-the-lan
* https://www.monotux.tech/posts/2024/04/hairpin-nat-nftables/

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
