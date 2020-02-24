Quagga (OSPF, BGP, ...) in Docker
==================================

This container is based on [arbiza/quagga-docker](https://bitbucket.org/arbiza/quagga-docker) container.

My ImprovementsDifferences to arbiza/quagga-docker container:
- Based at Debian:stable
- S6-Overlay
- Autobuild



## Telnetports
- Zebra: 2601
- OSPFd: 2604
- BGP: 2605
- OSPF6d: 2606

### Examples:
telnet 172.17.0.10 2601  ## Zebra daemon
telnet 172.17.0.10 2604  ## OSPF daemon
telnet 172.17.0.10 2605  ## BGP daemon
telnet 172.17.0.10 2606  ## OSPFv3 daemon (IPv6)



## Exmple configurations

### BGP

### OSPF
```
!
hostname <HOSTNAME>
!log file /var/log/quagga-ospfd.log
log file /dev/stdout
!
interface eth0
 ip ospf authentication message-digest
 ip ospf message-digest-key 2 md5 <KEY>
!
router ospf
 ospf router-id ID
 passive-interface default
 no passive-interface eth0
 network 10.0.0.0/27 area 0.0.0.0
 network 10.0.0.254/32 area 0.0.0.0
!
access-list localhost permit 127.0.0.1/32
access-list localhost deny any
!
line vty
 access-class localhost
!

```

### Zebra