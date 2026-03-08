## What is VPC
A VPC is a logically isolated network with its own IP address range. In VPC, we can decide who can enter, who can leave and who can talk to whom i.e. we can control the routing and access.

By default, nothing gets in. Nothing gets out.

### CIDR block

When we create a VPC, AWS asks for a CIDR block, like:
```
10.0.0.0/16
```

This simply means we are reserving a range of private IP addresses. All resources inside this VPC will get IPs from this range.

We cannot change this later without rebuilding the VPC.


### Public vs Private subnet

AWS does NOT have a checkbox that says “public subnet”. A subnet is called:

- **Public** if it can reach the internet

- **Private** if it cannot

It is decided by **Routing**.

If a subnet has a route to an Internet Gateway, it’s **public**. If it doesn’t, it’s **private**.

**Important:**
A public IP on a resource does NOT automatically mean internet connectivity. A resource (e.g. an ec2) can always have a public IP irrespective of the subnet type (public/private). To allow connections from the internet to that resource, there must be a route in the corresponding subnet's route table that points to an Internet Gateway. Otherwise, inbound traffic can't access it.

## Key Components of VPC

* **Subnets:** A subnet is a smaller slice of our VPC. These are divisions of the VPC’s IP address range assigned to specific applications or sub-projects.

  A subnet lives in exactly ONE Availability Zone. We place resources (EC2, RDS, etc.) inside subnets, not directly in the VPC.

* **Internet Gateway:** This acts as the "gate" to our VPC, allowing traffic from the public internet to enter our VPC. The public IP belongs to the resource (e.g. ec2), not the IGW. We should use a VPC endpoint to connect to AWS services privately, without the use of an internet gateway or NAT device.

* **Route Tables:** Each subnet is associated with one route table. They define where network traffic goes. This is how AWS knows whether traffic escapes or stays private.

* **Network Access Control List**: A Network Access Control List is a stateless firewall that controls inbound and outbound traffic at the subnet level. It operates at the IP address level and can allow or deny traffic based on rules that we define. NACLs provide an additional layer of network security for our VPC.

* **Security Groups**: A security group acts as a virtual firewall for instances (EC2 instances or other resources) within a VPC. It controls inbound and outbound traffic at the instance level. Security groups allow you to define rules that permit or restrict traffic based on protocols, ports, and IP addresses.

* **NAT Gateway**: A NAT gateway is a Network Address Translation (NAT) service. We can use a NAT gateway so that instances in a private subnet can connect to services outside your VPC but external services can't initiate a connection with those instances.

  A NAT Gateway exists for one job:

  Translate outbound traffic from private instances and allow return traffic for those same connections. 

  If someone tries to connect to NAT Public IP:
  - The traffic is dropped.
  - NAT Gateway does NOT accept unsolicited inbound connections.

  **Important**:  
  IGW is the only path between a VPC and the public internet. NAT Gateway does not talk to the internet directly, NAT Gateway must use an IGW.

## Fundamentals
- Inside a VPC, all subnets are part of the same private network.

  Subnets are just IP range partitions. Traffic between subnets is local traffic, not “internet traffic”. Every VPC route table contains the following route:

  ```
  VPC-CIDR → local
  ```
  This route allows any subnet to talk to any other subnet, unless blocked by Security Group or NACL.

- AWS knows which subnet the EC2 belongs to because the public IP is mapped to the EC2’s Elastic Network Interface (ENI), and the ENI is already attached to a specific subnet. AWS maintains a map to find the ENI from a public IP. AWS does not infer the subnet from the route table. 

### Scenario 1: Internet Gateway NAT (1:1 NAT) in practice

A **public-facing web application** that must be reachable from the internet.

For example:

* Company website
* Public REST API
* Bastion host
* Load balancer front end

All of these use **Internet Gateway NAT** under the hood.

#### Real-world example

We run an e-commerce site.

Requirements:

* Users on the internet must access our website
* HTTPS traffic must reach our application
* We control inbound access using Security Groups

#### Architecture (simplified)

* VPC with public subnets
* Internet Gateway attached to VPC
* EC2 instances or Application Load Balancer in public subnet
* Instances have public IPs (or ALB DNS)

Traffic flow:

* Internet → IGW → EC2 / ALB
* EC2 / ALB → IGW → Internet

Here, **Internet Gateway NAT (1:1)** is used.

Each instance:

* Has its own public IP
* Has a fixed mapping:

  ```
  private IP ↔ public IP
  ```

#### Why IGW NAT is correct here

Because:

* We WANT inbound connections
* The resource must be reachable
* We accept the exposure
* We rely on Security Groups to allow only safe traffic (443, 80)

This is **intentional exposure**, not a mistake.

### Scenario 2: NAT Gateway NAT (many:1 NAT) in practice

#### Use case

**Private backend systems** that must access the internet but must NEVER be accessed from the internet.

For example:

* Application servers
* Microservices
* Batch workers
* Internal tools
* Databases needing updates

All of these typically rely on **NAT Gateway NAT**.

#### Real-world example

Same e-commerce site, backend tier.

Requirements:

* App servers need to:

  * Call payment APIs
  * Download updates
  * Push logs to external services
  
* Internet must NOT initiate connections to these servers


#### Architecture (simplified)

* VPC with:
  * Public subnet
  * Private subnet(s)
  
* **Internet Gateway (IGW)** attached to the VPC

* **NAT Gateway** deployed in a **public subnet**

* Private EC2 instances with **no public IPs**

#### Route tables

**Private subnet route table**

```
VPC-CIDR → local
0.0.0.0/0 → NAT Gateway
```

**Public subnet route table (where NAT lives)**

```
VPC-CIDR → local
0.0.0.0/0 → Internet Gateway
```

#### Traffic flow

**Outbound traffic**

```
Private EC2
  → Private subnet route table
    → NAT Gateway (public subnet)
      → Public subnet route table
        → Internet Gateway
          → Internet
```

What happens here:

* Private EC2 initiates the connection
* NAT Gateway creates a stateful translation entry
* IGW provides the **only actual exit to the internet**
* Internet sees traffic coming from the NAT Gateway’s public IP


**Inbound traffic**

```
Internet
  → Internet Gateway
    → NAT Gateway
      → ❌ DROPPED (no existing outbound mapping)
```

What happens here:

* Traffic reaches the IGW successfully
* IGW forwards it toward the NAT Gateway
* NAT Gateway checks its connection state table
* No matching outbound connection exists
* Packet is silently dropped

No routing to private subnets occurs. Ever.


#### Why this design exists

* **IGW** is the only bridge between VPC and internet
* **NAT Gateway** enforces outbound-only initiation

* Private EC2 instances:
  * Have no public IPs
  * Are not routable from the internet
  * Cannot be exposed even by accident

## References
- Know more about [How Amazon VPC works](https://docs.aws.amazon.com/vpc/latest/userguide/how-it-works.html)
- [VPC with servers in private subnet](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-example-private-subnets-nat.html)