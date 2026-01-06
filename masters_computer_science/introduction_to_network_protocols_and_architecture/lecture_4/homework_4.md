# Homework 4: Network Protocols and Architecture

## Exercise 10

- Simulate network packet transmission using following protocols:

1. TCP
2. UDP
3. ICMP

- What do you see in specific protocol headers for each of the above protocols? Does the field value correspond to a specific octet in the header?

TCP Simulation: I opened the web-browser on PC0 and accessed a web page hosted on the server (PC3). The TCP protocol was used for this communication. In the TCP header, I observed fields such as Source Port, Destination Port, Sequence Number, Acknowledgment Number, Data Offset, Flags (SYN, ACK), Window Size, Checksum, and Urgent Pointer.[tcp_header_image](./tcp.png)


UDP Simulation: I opened the command prompt on PC0 and used the command "ipconfig /renew" to renew the DHCP lease, which uses the UDP protocol. In the UDP header, I observed fields such as Source Port, Destination Port, Length, and Checksum. The absence of fields related to connection management (like Sequence Number and Acknowledgment Number) indicates that UDP is a connectionless protocol that does not guarantee reliable delivery.[udp_header_image](./udp.png)

ICMP Simulation: I opened the command prompt on PC0 and used the "ping" command to send ICMP Echo Request messages to PC3. In the ICMP header, I observed fields such as Type, Code, Checksum, Identifier, and Sequence Number. The Type field indicates whether the message is an Echo Request or Echo Reply. The presence of these fields indicates that ICMP is used for diagnostic and control purposes in the network.[icmp_header_image](./icmp.png)

The field values in each protocol header correspond to specific octets in the header structure defined by their respective protocols. For example, in the TCP header, the Source Port and Destination Port fields occupy the first 4 bytes (2 bytes each), while in the UDP header, these fields also occupy the first 4 bytes. In the ICMP header, the Type and Code fields occupy the first 2 bytes. Each protocol has its own defined structure that dictates how data is organized within the packet headers.
