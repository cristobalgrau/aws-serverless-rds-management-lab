# ==== VPC SECTION ====

# Local variable to define AZ used
locals {
  az = data.aws_availability_zones.available.names
}

# Define VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.vpc-name}-vpc"
  }
}

# Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private-subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc-cidr, 4, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name = "${var.vpc-name}-${each.key}-${local.az[each.value]}"
  }
}

# Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each          = var.public-subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc-cidr, 4, each.value + 10)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name = "${var.vpc-name}-${each.key}-${local.az[each.value]}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc-name}-igw"
  }
}

# Create route tables for private subnets
resource "aws_route_table" "private-route-table" {
  for_each = var.private-subnets
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc-name}-rtb-private${each.value}-${local.az[each.value]}"
  }
}

# Create route tables for public subnets
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name = "${var.vpc-name}-rtb-public"
  }
}

#Create route table associations
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private_subnets
  route_table_id = aws_route_table.private-route-table[each.key].id
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public-route-table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

# Created VPC Security group
resource "aws_security_group" "allow-all-traffic" {
  name        = "allow-all-traffic"
  description = "Allow all IPv4 inbound traffic"
  vpc_id      = aws_vpc.vpc.id
}

# Created ingress rule for all IPv4 traffic
resource "aws_vpc_security_group_ingress_rule" "allow-all-traffic-ipv4" {
  security_group_id = aws_security_group.allow-all-traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
