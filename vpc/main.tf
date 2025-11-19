# vpc/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# --------------------------------------------------------
# Resources
# --------------------------------------------------------

# 1. Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "data-eng-vpc"
  }
}

# 2. Create the Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "data-eng-igw"
  }
}

# Fetch available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# 3. Create the Public Subnets
resource "aws_subnet" "public" {
  for_each                = toset(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[index(var.public_subnet_cidr, each.value)]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-${index(var.public_subnet_cidr, each.value) + 1}"
  }
}

# 4. Create the Private Subnets
resource "aws_subnet" "private" {
  for_each          = toset(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[index(var.private_subnet_cidr, each.value)]

  tags = {
    Name = "Private-Subnet-${index(var.private_subnet_cidr, each.value) + 1}"
  }
}

# 5. Create Public Route Table (for internet traffic)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public-RT"
  }
}

# 6. Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# 7. EIP for NAT Gateway (Note: this is an elastic IP, small charge may apply)
resource "aws_eip" "nat" {
  domain = "vpc"
  count  = 1
}

# 8. Create NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat" {
  count         = 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public["10.0.1.0/24"].id # Placed in public subnet 1

  tags = {
    Name = "data-eng-naat"
  }
}

# 9. Create Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id # Route all internet-bound traffic through
  }
  tags = {
    Name = "Private-RT"
  }
}

# 10. Association private subnets with private route table
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}












