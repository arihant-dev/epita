# Homework 2: Network Protocols and Architecture

## Excercise 4

Please see attached file labelled "Arihant_Jain_Ex-3-4.pkt" for the exercise details.

## Excercise 5

Subnet the given IP address: 165.132.9.0/24 as per the requirements below:

1. Room A(interface 1): 100 hosts
2. Room B(interface 2): 25 hosts
3. Room C & D(interface 3) - Hub - Room C: 25 hosts, Room D: 25 hosts
4. Ingress/Egress(interface 4) - 165.132.15.58 -> ISP Network

### Solution to Exercise 5

1. Room A (Largest: 100 hosts)
Needs: > 100 IPs. Nearest power of 2 is 128 (2^7).
New Mask: 32−7=/25 (which is 255.255.255.128).
Network: 165.132.9.0
Range: .0 to .127
Gateway IP (Router): 165.132.9.1

2. Room C&D (Middle: 50 hosts)
Since they share a Hub, they are in the same network. 25 + 25 = 50 hosts.
Needs: > 50 IPs. Nearest power of 2 is 64 (2^6).
New Mask: 32−6=/26 (which is 255.255.255.192).
Start Address: Start where Room A ended (.128).
Network: 165.132.9.128
Range: .128 to .191
Gateway IP (Router): 165.132.9.129

3. Room B (Smallest: 25 hosts)
Needs: > 25 IPs. Nearest power of 2 is 32 (2^5).
New Mask: 32−5=/27 (which is 255.255.255.224).
Start Address: Start where Room C/D ended (.192).
Network: 165.132.9.192
Range: .192 to .223
Gateway IP (Router): 165.132.9.193

Please see attached file labelled "Arihant_Jain_Ex-3-5.pkt" for the exercise details.

## Excercise 6

Initiate PING from PC1 to PC3 to set-up the ARP – and simulate the ARP connection

### Solution to Exercise 6

- Image attached for the `arp` command output. [ARP Command Output](/arp.png)

Please see attached file labelled "Arihant_Jain_Ex-3-6.pkt" for the exercise details.
