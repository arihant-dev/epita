# Lecture 4 : Notes on Network Protocols and Architecture

## Transimission Control Protocol (TCP)

- TCP is a connection-oriented protocol that ensures reliable data transmission between devices.
- Reliable and the backbone of the internet.
- Connections are:
  - Full-duplex: Data can be sent and received simultaneously.
  - Stream-oriented: Data is transmitted as a continuous stream of bytes.
  - Connection-oriented: A connection is established before data transfer begins.
- Protocols that use TCP:
  - HTTP/HTTPS
  - FTP
  - SMTP
  - Telnet
  - POP3/IMAP

### TCP Header Structure

- Source Port (16 bits): Identifies the sending port.
- Destination Port (16 bits): Identifies the receiving port.
- Sequence Number (32 bits): Indicates the position of the first byte of data in the segment.
- Acknowledgment Number (32 bits): Indicates the next expected byte from the sender.
- Data Offset (4 bits): Specifies the size of the TCP header.
- Reserved (3 bits): Reserved for future use.
- Flags (9 bits): Control flags such as SYN, ACK, FIN, RST, PSH, URG.
- Window Size (16 bits): Specifies the size of the sender's receive window.
- Checksum (16 bits): Used for error-checking of the header and data.
- Urgent Pointer (16 bits): Indicates the end of urgent data.
- Options (variable length): Additional options for TCP.

0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3
+---------------------------------------------------------------+
|          Source Port          |       Destination Port        |
+---------------------------------------------------------------+
|                        Sequence Number                        |
+---------------------------------------------------------------+
|                    Acknowledgment Number                      |
+---------------------------------------------------------------+
| Data Offset | Reserved | Flags |        Window Size           |
+---------------------------------------------------------------+
|       Checksum        |     Urgent Pointer                    |
+---------------------------------------------------------------+
|                    Options (if any)                           |
+---------------------------------------------------------------+

### TCP Connection Establishment (Three-Way Handshake)

1. SYN: The client sends a SYN (synchronize) packet to the server to initiate a connection.
2. SYN-ACK: The server responds with a SYN-ACK (synchronize-acknowledge) packet to acknowledge the client's request.
3. ACK: The client sends an ACK (acknowledge) packet to the server, completing the connection establishment.

### TCP Connection Termination (Four-Way Handshake)

1. FIN: The client sends a FIN (finish) packet to the server to initiate connection termination.
2. ACK: The server acknowledges the FIN packet with an ACK packet.
3. FIN: The server sends a FIN packet to the client to indicate it is ready to close the connection.
4. ACK: The client acknowledges the server's FIN packet with an ACK packet, completing the connection termination.

## User Datagram Protocol (UDP)

- UDP is a connectionless protocol that provides a faster but less reliable data transmission.
- It does not guarantee delivery, order, or error-checking.
- Protocols that use UDP:
  - DNS
  - DHCP
  - TFTP
  - SNMP
  - VoIP
  - Online gaming

### UDP Header Structure

- Source Port (16 bits): Identifies the sending port.
- Destination Port (16 bits): Identifies the receiving port.
- Length (16 bits): Specifies the length of the UDP header and data.
- Checksum (16 bits): Used for error-checking of the header and data.

+---------------------------------------------------------------+
|          Source Port          |       Destination Port        |
+---------------------------------------------------------------+
|            Length             |          Checksum             |
+---------------------------------------------------------------+
|                          Data                                 |
+---------------------------------------------------------------+

- Checksum detects errors in the header and data, but it is optional in IPv4.

### Key Differences between TCP and UDP

| Feature               | TCP                                  | UDP                                 |
|-----------------------|--------------------------------------|-------------------------------------|
| Connection Type       | Connection-oriented                  | Connectionless                      |
| Reliability           | Reliable, guarantees delivery        | Unreliable, no delivery guarantee   |
| Data Transmission     | Stream-oriented                      | Message-oriented                    |
| Error Checking        | Yes                                  | Yes                                 |
| Flow Control          | Yes                                  | No                                  |
| Use Cases             | Web browsing, email, file transfer   | DNS, VoIP, online gaming            |

## ICMP (Internet Control Message Protocol)

- ICMP is used for network diagnostics and error reporting.
- It is primarily used by network devices to send error messages and operational information.
- Common ICMP messages:
  - Echo Request and Echo Reply (used by the ping command)
  - Destination Unreachable
  - Time Exceeded
  - Redirect
- ICMP is an integral part of the IP protocol suite and operates at the Network Layer.

### ICMP Header Structure

- Type (8 bits): Indicates the type of ICMP message.
- Code (8 bits): Provides additional information about the message type.
- Checksum (16 bits): Used for error-checking of the ICMP message.

+---------------------------------------------------------------+
|      Type      |      Code      |         Checksum            |
+---------------------------------------------------------------+
|    Identifier                |     Sequence Number            |
+---------------------------------------------------------------+
|                          Data                                 |
+---------------------------------------------------------------+

### Common ICMP Message Types

| Type | Code | Description                     |
|------|------|---------------------------------|
| 0    | 0    | Echo Reply                      |
| 3    | 0-15 | Destination Unreachable         |
| 8    | 0    | Echo Request                    |
| 11   | 0    | Time Exceeded                   |
| 5    | 0-3  | Redirect                        |

link iana.org/assignments/icmp-parameters/icmp-parameters.xhtml

### Detecting excessively long routes

- ICMP Time Exceeded messages are used to indicate that a packet has been discarded because it has exceeded the maximum number of hops (TTL - Time to Live).
- This is commonly used in traceroute operations to map the path packets take to reach a destination.
- Each router that forwards the packet decrements the TTL by 1. When the TTL reaches zero, the router discards the packet and sends an ICMP Time Exceeded message back to the sender.
- This helps in identifying routing loops and excessively long routes in the network.

## Optical Network(ON)

- An Optical Network (ON) uses light to transmit data over optical fibers.
- It offers high bandwidth, low latency, and long-distance communication capabilities.
- Components of an Optical Network:
  - Optical Fiber: The medium through which light signals are transmitted.
  - Optical Transmitter: Converts electrical signals into optical signals.
    - Optical Receiver: Converts optical signals back into electrical signals.
    - Optical Amplifier: Boosts the strength of optical signals for long-distance transmission.
    - Optical Switch: Directs optical signals to different paths in the network.
- Types of Optical Networks:
  - Passive Optical Network (PON): Uses passive components like splitters to distribute signals.
  - Active Optical Network (AON): Uses active components like switches and routers to manage signals.
- Applications of Optical Networks:
  - Internet backbone
  - Data centers
  - Telecommunications
  - Cable TV distribution

## How Optical Networks Work (MUX/DEMUX)

- Multiplexer (MUX): Combines multiple optical signals into a single signal for transmission over a single fiber.
- Demultiplexer (DEMUX): Separates a single optical signal into multiple signals at the receiving end.
- Wavelength Division Multiplexing (WDM): A technique used in optical networks to combine multiple wavelengths (channels) of light onto a single fiber.
  - Dense Wavelength Division Multiplexing (DWDM): Allows for a higher number of channels by using closely spaced wavelengths.
  - Coarse Wavelength Division Multiplexing (CWDM): Uses wider spacing between wavelengths, allowing for fewer channels but lower cost.
- Optical networks use MUX/DEMUX to efficiently utilize the bandwidth of optical fibers, enabling high-capacity data transmission over long distances.

+---------------------------------------------------------------+
|                        Optical Signals                        |
+---------------------------------------------------------------+
|   Wavelength 1   |   Wavelength 2   |   Wavelength 3   |  ...  |
+---------------------------------------------------------------+
|                          MUX/DEMUX                            |
+---------------------------------------------------------------+
|                     Single Optical Fiber                      |
+---------------------------------------------------------------+
|                          MUX/DEMUX                            |
+---------------------------------------------------------------+
|   Wavelength 1   |   Wavelength 2   |   Wavelength 3   |  ...  |
+---------------------------------------------------------------+

## KA band Communication and KB band Communication

- KA Band Communication:
  - Frequency Range: 26.5 GHz to 40 GHz
  - Used for high-capacity satellite communications, including broadband internet and high-definition television.
  - Advantages: Higher bandwidth, smaller antennas, and better resistance to interference.
  - Disadvantages: More susceptible to rain fade and atmospheric attenuation.
- KB Band Communication:
  - Frequency Range: 18 GHz to 26.5 GHz
  - Used for satellite communications, including military and commercial applications.
  - Advantages: Better penetration through atmospheric conditions compared to KA band.
  - Disadvantages: Lower bandwidth compared to KA band.
- Both KA and KB bands are part of the microwave spectrum and are used for various communication applications, including satellite links, radar systems, and point-to-point communication.
