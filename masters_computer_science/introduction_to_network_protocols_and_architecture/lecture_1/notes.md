## Lecture 1: Introduction to Network Protocols and Architecture
-> matthew.davis1@fulltiltcyber.com



## SUBNET MASK
A subnet mask is a 32-bit number that divides an IP address into network and host portions. It helps determine which part of the IP address refers to the network and which part refers to the device (host) on that network.
For example, in the IP address
192.168.1.100 with a subnet mask of 255.255.255.0, the first three octets (192.168.1) represent the network portion, and the last octet (100) represents the host portion.
Subnet masks are typically expressed in two formats:
1. Dotted Decimal Notation: e.g., 255.255.255.0
2. Binary Notation: e.g., 11111111.11111111.11111111.00000000
The dotted decimal notation is more commonly used in everyday networking.
Subnet masks are crucial for routing traffic within and between networks, as they help routers determine the best path for data packets.
### CIDR Notation
CIDR (Classless Inter-Domain Routing) notation is a compact representation of an IP address and its associated subnet mask. It is written as the IP address followed by a slash (/) and the number of bits in the subnet mask.
For example, the CIDR notation 192.168.1.0/24 represents the IP address 192.168.1.0 with a subnet mask of 255.255.255.0.
In this case, the "/24" indicates that the first 24 bits of the subnet mask are set to 1 (i.e., 11111111.11111111.11111111.00000000).
CIDR notation is widely used in modern networking because it allows for more flexible allocation of IP addresses compared to traditional classful addressing.
### Subnetting
Subnetting is the process of dividing a larger network into smaller, more manageable sub-networks (subnets). This is done by borrowing bits from the host portion of the IP address to create additional network bits.
For example, if you have a network with the IP address 192.168.1.0 and a subnet mask of 255.255.255.0 (/24), you can subnet it into smaller networks by changing the subnet mask to 255.255.255.128 (/25). This creates two subnets:
1. 192.168.1.0/25 (hosts range: 1 to 126)
2. 192.168.1.128/25 (hosts range: 128 to 254)
Subnetting helps improve network performance, enhances security, and allows for better management of IP address allocation. It is commonly used in both enterprise and service provider networks.
### VLSM (Variable Length Subnet Mask)
VLSM (Variable Length Subnet Mask) is a technique that allows for the use of different subnet masks within the same network. This enables more efficient use of IP address space by allowing subnets of varying sizes to be created based on the specific needs of different segments of the network.
For example, in a network with the IP address range 192.168.1.0/24, you could create:
1. A subnet for a small office with 30 hosts using a subnet mask of 255.255.255.128 (/25).
2. A subnet for a larger department with 100 hosts using a subnet mask of 255.255.255.192 (/26).
3. A subnet for a server farm with 200 hosts using a subnet mask of 255.255.255.224 (/27).
VLSM is particularly useful in scenarios where different parts of the network have varying requirements for the number of hosts. It helps conserve IP address space and allows for more granular control over network design.
VLSM is commonly used in conjunction with CIDR (Classless Inter-Domain Routing) to optimize IP address allocation and improve overall network efficiency.
### Summary
- A subnet mask divides an IP address into network and host portions.
- CIDR notation provides a compact way to represent IP addresses and subnet masks.
- Subnetting allows for the creation of smaller sub-networks within a larger network.
- VLSM enables the use of different subnet masks within the same network for more efficient IP address allocation.
Understanding these concepts is essential for effective network design and management.
### IP Address Classes
IP addresses are traditionally divided into five classes (A, B, C, D, and E) based on their leading bits and intended use. The most commonly used classes for general networking are Class A, B, and C.
1. Class A:
   - Range: 1.0.0.0 to 126.255.255.255
    - Default Subnet Mask: 255.0.0.0 (/8)
   - Leading Bits: 0
   - Used for very large networks with a small number of networks and a large number of hosts.
2. Class B:
   - Range: 128.0.0.0 to 191.255.255.255
    - Default Subnet Mask: 255.128.0.0 (/9)
   - Leading Bits: 10
   - Used for medium-sized networks with a moderate number of networks and hosts.
3. Class C:
   - Range: 208.0.0.0 to 239.255.255.255
    - Default Subnet Mask: 255.255.0.0 (/16)
   - Leading Bits: 110
   - Used for smaller networks with a large number of networks and hosts.
4. Class D:
   - Range: 240.0.0.0 to 254.255.255.255
    - Default Subnet Mask: 255.255.255.0 (/24)
   - Leading Bits: 1110
   - Reserved for future use.
5. Class E:
   - Range: 255.0.0.0 to 255.255.255.255
    - Default Subnet Mask: 255.255.255.255 (/32)
   - Leading Bits: 1111
   - Reserved for the network research and experimental purposes.
### Summary of IP Address Classes
- Class A: Large networks, default subnet mask 255.0.0.0 (/8).
- Class B: Medium-sized networks, default subnet mask 255.128.0.0 (/9).
- Class C: Smaller networks, default subnet mask 255.255.0.0 (/16).
- Class D: Reserved for future use.
- Class E: Reserved for network research and experimental purposes.

### Private vs. Public IP Addresses
IP addresses can be categorized into private and public addresses based on their intended use and accessibility.
1. Private IP Addresses:
   - These addresses are reserved for use within private networks and are not routable on the public internet.
   - Common private IP address ranges include:
     - Class A: 10.0.0.0 to 10.255.255.255
     - Class B: 172.16.0.0 to 172.31.255.255
     - Class C: 192.168.0.0 to 192.168.255.255
    - Private IP addresses are commonly used in home, office, and enterprise networks to allow devices to communicate internally without consuming public IP address space.
2. Public IP Addresses:
   - These addresses are assigned by Internet Service Providers (ISPs) and are routable on the public internet.
   - Public IP addresses are unique across the entire internet, allowing devices to communicate globally.
   - Organizations and individuals use public IP addresses to host websites, services, and applications accessible from anywhere in the world.
### Summary of Private vs. Public IP Addresses
- Private IP Addresses: Used within private networks, not routable on the public internet (e.g., 192.168.x.x).
- Public IP Addresses: Routable on the public internet, assigned by ISPs, and unique globally.
Understanding the distinction between private and public IP addresses is essential for effective network design, security, and management.

### NAT (Network Address Translation)
Network Address Translation (NAT) is a technique used to modify IP address information in packet headers while in transit across a traffic routing device. NAT is commonly used to enable multiple devices on a local network to share a single public IP address for accessing the internet.
There are several types of NAT, including:
1. Static NAT: Maps a single private IP address to a single public IP address.
2. Dynamic NAT: Maps a private IP address to a public IP address from a pool of available public addresses.
3. PAT (Port Address Translation), also known as NAT overload: Maps multiple private IP addresses to a single public IP address by using different port numbers.
NAT provides several benefits, including:
- Conservation of public IP addresses.
- Enhanced security by hiding internal network structure.
- Simplified network management.
### Summary of NAT
- NAT modifies IP address information in packet headers for routing.
- Types of NAT include Static NAT, Dynamic NAT, and PAT (NAT overload).
- NAT conserves public IP addresses and enhances network security.

### DHCP (Dynamic Host Configuration Protocol)
Dynamic Host Configuration Protocol (DHCP) is a network management protocol used to automate the process of configuring devices on IP networks. DHCP allows devices to obtain IP addresses and other network configuration parameters automatically, reducing the need for manual configuration.
When a device connects to a network, it sends a DHCPDISCOVER message to request an IP address. The DHCP server responds with a DHCPOFFER message, providing an available IP address and other configuration details. The device then sends a DHCPREQUEST message to accept the offer, and the server responds with a DHCPACK message to finalize the assignment.
DHCP can also provide additional configuration information, such as:
- Subnet mask
- Default gateway
- DNS server addresses
- Lease duration for the assigned IP address
### Summary of DHCP
- DHCP automates the configuration of devices on IP networks.
- It assigns IP addresses and other network parameters dynamically.
- DHCP reduces the need for manual configuration and simplifies network management.

### DNS (Domain Name System)
The Domain Name System (DNS) is a hierarchical and decentralized naming system used to translate human-readable domain names (e.g., www.example.com) into IP addresses (e.g., 192.168.1.1). This translation is essential for routing traffic on the internet, as devices use IP addresses to communicate with each other.
When a user enters a domain name into a web browser, the browser sends a DNS query to a DNS server to resolve the domain name into an IP address. The DNS server responds with the corresponding IP address, allowing the browser to connect to the desired website.
DNS operates through a distributed network of DNS servers, including:
- Root DNS servers
- Top-Level Domain (TLD) servers
- Authoritative DNS servers
### Summary of DNS
- DNS translates domain names into IP addresses.
- It enables users to access websites using human-readable names.
- DNS operates through a distributed network of servers for efficient resolution.
### Subdomains
A subdomain is a subdivision of a larger domain name that helps organize and navigate different sections of a website or network. Subdomains are created by adding a prefix to the main domain name, separated by a dot. For example, in the domain name "blog.example.com," "blog" is the subdomain of the main domain "example.com."
Subdomains can be used for various purposes, such as:
- Organizing content (e.g., blog.example.com, shop.example.com)
- Hosting different services (e.g., mail.example.com for email services)
- Creating separate environments (e.g., dev.example.com for development)
### Summary of Subdomains
- Subdomains are subdivisions of a larger domain name.
- They help organize and navigate different sections of a website or network.
- Subdomains are created by adding a prefix to the main domain name.

### DHCP vs. DNS
- DHCP (Dynamic Host Configuration Protocol) is used to automatically assign IP addresses and network configuration parameters to devices on a network.
- DNS (Domain Name System) is used to translate human-readable domain names into IP addresses for routing traffic on the internet.
- DHCP focuses on device configuration, while DNS focuses on name resolution.
- Both protocols are essential for efficient network management and operation.

### OSI Model Overview
The OSI (Open Systems Interconnection) model is a conceptual framework used to understand and standardize the functions of a telecommunication or computing system without regard to its underlying internal structure and technology. The OSI model is divided into seven layers, each representing a specific function in the communication process:
1. Physical Layer: Responsible for the physical connection between devices, including cables, switches, and other hardware.
2. Data Link Layer: Manages the transfer of data between devices on the same network, including error detection and correction.
3. Network Layer: Handles the routing of data packets across different networks, including IP addressing and packet forwarding.
4. Transport Layer: Ensures reliable data transfer between devices, including error recovery and flow control.
5. Session Layer: Manages sessions or connections between applications, including establishing, maintaining, and terminating connections.
6. Presentation Layer: Translates data between the application layer and the network, including data encryption and compression.
7. Application Layer: Provides network services directly to end-users and applications, including email, file transfer, and web browsing.

### TCP/IP Model Overview
The TCP/IP (Transmission Control Protocol/Internet Protocol) model is a simplified framework used to understand and standardize the functions of a telecommunication or computing system. The TCP/IP model consists of four layers:
1. Network Interface Layer: Corresponds to the OSI model's Physical and Data Link layers, responsible for the physical connection and data transfer between devices on the same network.
2. Internet Layer: Corresponds to the OSI model's Network layer, handling the routing of data packets across different networks, including IP addressing and packet forwarding.
3. Transport Layer: Corresponds to the OSI model's Transport layer, ensuring reliable data transfer between devices, including error recovery and flow control.
4. Application Layer: Corresponds to the OSI model's Session and Presentation layers, providing network services directly to end-users and applications, including email, file transfer, and web browsing.
### Summary of OSI and TCP/IP Models
- The OSI model consists of seven layers, while the TCP/IP model consists of four layers.
- Both models provide a framework for understanding and standardizing network communication.
- The OSI model is more detailed, while the TCP/IP model is more practical and widely used in real-world networking.

### 5G, LTE, and Wi-Fi Overview
1. 5G (Fifth Generation):
   - The latest generation of mobile network technology, offering significantly higher speeds, lower latency, and greater capacity compared to previous generations.
   - Enables advanced applications such as augmented reality, virtual reality, and Internet of Things (IoT) devices.
2. LTE (Long-Term Evolution):
   - A standard for wireless broadband communication, often referred to as 4G LTE.
   - Provides high-speed data transfer and improved network efficiency compared to 3G networks.
   - Supports applications such as video streaming, online gaming, and mobile internet access.
3. Wi-Fi (Wireless Fidelity):
   - A wireless networking technology that allows devices to connect to a local area network (LAN) using radio waves.
   - Commonly used in homes, offices, and public spaces to provide internet access to devices such as smartphones, laptops, and tablets.
   - Operates on various frequency bands, including 2.4 GHz and 5 GHz, with newer standards supporting higher speeds and improved performance.
### Summary of 5G, LTE, and Wi-Fi
- 5G is the latest mobile network technology, offering high speeds and low latency.
- LTE is a 4G standard providing high-speed wireless broadband communication.
- Wi-Fi is a wireless networking technology for local area networks, enabling internet access for various devices.
