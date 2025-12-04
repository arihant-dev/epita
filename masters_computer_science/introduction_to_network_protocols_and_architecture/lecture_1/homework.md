# Homework 1: Network Protocols and Architecture

## Exercise 1

1. Highlight each parameter of your TCP/IP connection configuration (IPv4)?
    • IP address - 192.168.0.47
    • Subnet mask - 255.255.255.0
    • Default gateway - 192.168.0.254
2. Does your device has multiple IP assignments? (if yes, then highlight them)
    • No, only one IP assignment.(192.168.0.47) - Macbook :(
3. DNS server:
    a. What is your DNS server?
        • 192.168.0.254(same as default gateway)
    b. Why is it preferable to protect DNS traffic?
        • To prevent DNS spoofing attacks(as DNS doesn't have built-in security - Encryption), ensure privacy, and maintain data integrity.
    c. Change your DNS server to other DNS server of your choice?
        • Check the attached screenshot at [change DNS server screenshot](/change_dns_server.png), I changed it to Google's Public DNS (8.8.8.8).
4. Which connection (physical) setup (e.g., DSL, Cable modem,...) are you directly connected to? ISP Physical Medium (Cable) -> Modem/Router -> Wi-Fi (Radio Waves) -> My Computer (192.168.0.47)
    a. Would you like to switch to a different connection setup? If yes then, why?
        • Yes, Fiber Optic connection because it offers higher speeds, better reliability, and lower latency compared to cable connections.

## Exercise 2

1. Which protocol are you using to connect to the internet?
    • IPv4 (Internet Protocol version 4) is being used to connect to the internet.
2. What is the most probable network topology of your connection?
    • The most probable network topology of my connection is a Star Topology, where all devices are connected to a central router/modem that manages the network traffic.
3. What is the logical network architecture of your connection? (in relation with your ISP)
    • The logical network architecture of my connection follows the Client-Server model, where my device (client) communicates with various servers on the internet through my ISP's infrastructure.

## Exercise 3

Use any FTP client to connect to FTP server of your choice (e.g., ftp.gnu.org) OR Use network simulator, and perform any (read/write) operation:

1. List down the actions
    • Created a topology in Cisco Packet Tracer with a PC, a Switch, and an Server.
    • Configured the PC to connect to the Switch and then to the Server.
    • Switched on the FTP on the Server and then configured the FTP with a username and password.
    • Configured the Server with an IP address (192.168.1.10).
    • Configured the PC with an IP address(192.168.1.11) in the same subnet as the Server.
    • Used the FTP client on the PC to connect to the FTP server using the Server's IP address, username, and password.
    • Performed read operation 'pwd' from the FTP server.
2. Visualize/Map each connection with the respective TCP/IP Layers
    • Application Layer: FTP Client on PC and FTP Server on Server.
    • Transport Layer: TCP protocol for reliable data transfer.
    • Network Layer: IP protocol for addressing and routing (192.168.1.10 and 192.168.1.11).
    • Data Link Layer: Ethernet protocol for local network communication.
    • Physical Layer: Physical connection (cables) between PC, Switch, and Server.
3. Screenshot of the operations performed
    • Check the attached screenshot at [Client Server Topology screenshot](/client_server_topology.png).
    • Check the attached screenshot at [FTP operation screenshot](/client_to_server_over_ftp.png) showing the successful connection and 'pwd' command output.
