# Data Engineering VPC Foundation

This document describes the core network architecture deployed via Terraform, providing a secure and scalable foundation for all data engineering workloads (ETL, streaming, storage).

## 1. Architecture Overview (Dual-Tier, Multi-AZ)

We have deployed a foundational Virtual Private Cloud (VPC) following a secure, two-tier architecture distributed across two Availability Zones (AZs). This ensures high availability and redundancy.


| Component                    |   Quantity   |                                                                                                                                                         Purpose |
|:-----------------------------|:------------:|----------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| VPC (10.0.0.0/16)            |      1       |                                                                                                    The logical isolation boundary for our entire cloud network. |
| Public Subnets               | 2 (1 per AZ) |                                                            Hosts network access points (NAT Gateways, Internet Gateway). Never deploy application servers here. |
| Private Subnets              | 2 (1 per AZ) |                                                                             Hosts all core data resources (EC2, RDS, Redshift, etc.). Ensures maximum security. |
| Internet Gateway (IGW)       |      1       |                                                                                                       Allows traffic into the Public Subnets from the internet. |
| NAT Gateway (NAT GW)         |      1       |Allows resources in Private Subnets to connect out to the internet (for patching, API calls, dependency downloads) without being exposed to incoming connections. |

## 2. Key AWS Services and Their Roles

This architecture uses the following core AWS networking services:

**AWS VPC (Virtual Private Cloud)**

* What it is: Your own isolated, virtual network in the AWS cloud.

* Why we use it: It provides network isolation, allowing us to define our own IP range (10.0.0.0/16) and configure our own security rules, ensuring our data resources are completely walled off from the public internet by default.

**Subnets (Public vs. Private)**

* What they are: Sub-divisions of the VPC's IP range, mapped to a single Availability Zone (AZ) for fault tolerance.

* Why we use them:

  * Security: By placing sensitive resources (databases, processing clusters) in Private Subnets, we prevent any unsolicited inbound traffic from the internet.

  * Resilience: Spreading resources across multiple AZs (Subnet 1 in AZ-A, Subnet 2 in AZ-B) ensures that if one data center fails, the application remains running.

**Internet Gateway (IGW) and NAT Gateway (NAT GW)**

* IGW: Serves as the direct router for public internet access.

* NAT Gateway: A highly available service deployed in a Public Subnet that serves as a proxy.

* Why we use them: The NAT GW allows our servers in the Private Subnets to download software updates or make outbound API calls to external services, but crucially, it does not allow anyone from the internet to connect back into those private servers. This is the most secure way for data workloads to access the outside world.

## 3. How to Utilize this VPC

This VPC is ready for deploying your data processing and storage infrastructure.

➡️ Deploying a Secure EC2 Instance or Data Cluster

When you provision any new resource (like an EC2 instance, an EMR cluster, or an RDS database), always place it in the Private Subnets.

Select the VPC: When configuring the resource, select the VPC named data-eng-vpc.

Select the Subnet: Choose one of the Private Subnets (e.g., Private-Subnet-1 or Private-Subnet-2). Never use the Public Subnets for application resources.

Assign Security Group: Ensure the instance is launched with a proper Security Group (which we will define in the next steps!) that controls inbound access (usually only from other internal resources).

🌐 Outbound Connectivity for Private Resources

Any resource launched into the Private Subnets will automatically use the Private Route Table, which directs all outbound traffic to the NAT Gateway. This gives the resource internet access for:

Downloading dependencies (pip install, apt update).

Fetching data from external APIs.

Sending logs or metrics to cloud providers.

🔑 Key VPC IDs for Future Deployments

For easy reference in subsequent Terraform modules or manual console deployment, the following resources are key:

| Resource Type          |                                Terraform Output Variable Name                                 |
|:-----------------------|:---------------------------------------------------------------------------------------------:|
| VPC ID                 |                                            vpc_id                                             |
| Public Subnet IDs      |                                       public_subnet_ids                                       |
| Private Subnet IDs     |                                      private_subnet_ids                                       |
| Private Route Table ID | (Not explicitly exported, but the aws_route_table.private.id should be referenced internally) |
