# Lecture 5: Network Layers and Protocols

## IGP & EGP

- IGP (Interior Gateway Protocol) is used for routing within a single autonomous system (AS). Examples include OSPF and EIGRP.
- EGP (Exterior Gateway Protocol) is used for routing between different autonomous systems. The primary example is BGP (Border Gateway Protocol).

## Classful vs Classless Addressing

- Classful addressing divides the IP address space into fixed classes (A, B, C, D, E) with predefined subnet masks.
- Classless addressing (CIDR) allows for variable-length subnet masking, enabling more efficient use of IP addresses.

                      Interior Gateway Protocol (IGP)              Exterior Gateway Protocol (EGP)
            Distance Vector                 Link State                Path Vector
            Router Protocols                Router Protocols          Router Protocols
Classful          RIP                          OSPF                         BGP
Classless         RIP                          IS-IS                        EIGRP
IPv6                        OSPFv3                                      EIGRP for IPv6

graph TD
    subgraph IGP [Interior Gateway Protocol]
        DV[Distance Vector]
        LS[Link State]
    end
    subgraph EGP [Exterior Gateway Protocol]
        PV[Path Vector]
    end

    DV --> RIP_Classful[RIP (Classful)]
    DV --> RIP_Classless[RIP (Classless)]

    LS --> OSPF[OSPF (Classful)]
    LS --> ISIS[IS-IS (Classless)]
    LS --> OSPFv3[OSPFv3 (IPv6)]

    PV --> BGP[BGP (Classful)]
    PV --> EIGRP[EIGRP (Classless)]
    PV --> EIGRPv6[EIGRP for IPv6 (IPv6)]

## Autonomous Systems (AS)

- An Autonomous System is a collection of IP networks and routers under the control of a single organization that presents a common routing policy to the internet.
- ASes are identified by unique AS numbers (ASN) assigned by IANA.
- ASes use IGPs for internal routing and EGPs like BGP for external routing between ASes.

## Type of Autonomous Systems

- Stub AS: An AS that is connected to only one other AS.
- Multihomed AS: An AS that is connected to more than one AS but does not allow transit traffic.
- Transit AS: An AS that is connected to multiple ASes and allows transit traffic.

## BGP (Border Gateway Protocol)

- BGP is the protocol used to exchange routing information between different ASes on the internet.
- It is a path vector protocol that makes routing decisions based on paths, network policies, and rule-sets.
- BGP uses TCP as its transport protocol (port 179) to ensure reliable delivery of routing information.
- BGP supports Classless Inter-Domain Routing (CIDR) and is essential for maintaining a stable and efficient internet routing system.
- Internet uses BGP4 version of BGP.
  - eBGP: External BGP, used for routing between different ASes.
  - iBGP: Internal BGP, used for routing within the same AS.
- BGP Attributes:
  - AS-Path: List of ASes that a route has traversed.
  - Next-Hop: The IP address of the next hop router to reach a destination.
  - Local Preference: Indicates the preferred path for outbound traffic from an AS.
  - MED (Multi-Exit Discriminator): Suggests the preferred path into an AS for inbound traffic.
- BGP Route Selection Process:
  1. Highest Local Preference
  2. Shortest AS-Path
  3. Lowest Origin Type
  4. Lowest MED
  5. eBGP over iBGP
  6. Lowest IGP Metric to Next-Hop
  7. Oldest Route
  8. Lowest BGP Router ID

## BGP security concerns

- BGP Hijacking: Malicious actors can announce IP prefixes they do not own, redirecting traffic.
- Route Leaks: Misconfigured BGP routers can inadvertently announce routes to other ASes.
- Lack of Authentication: BGP does not have built-in mechanisms for authenticating routing updates.
- BGP denial-of-service (DoS) attacks targeting BGP routers.
- Mitigation Strategies:
  - Implementing RPKI (Resource Public Key Infrastructure) to validate route origins.
  - Using BGP prefix filtering to restrict the routes that can be advertised or accepted.
- Regularly monitoring BGP sessions and routing tables for anomalies.

## Router ACLs vs BGP Prefix Filtering

- Router ACLs (Access Control Lists) are used to filter traffic based on IP addresses, protocols, and ports at the router level. They can be applied to incoming or outgoing traffic on interfaces.
- BGP Prefix Filtering is specifically used to control the advertisement and acceptance of IP prefixes in BGP routing updates. It allows network administrators to specify which prefixes can be advertised to or accepted from BGP peers.
- While both techniques enhance network security, ACLs operate at the packet level, whereas BGP Prefix Filtering operates at the routing protocol level.

