# Info: Creates vpc and related resources for networking.
#       This includes: internet gateway, elastic IP, NAT gateways,
#       public/private subnets and route tables and subnet associations.

## VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${local.prefix}-vpc"
  }
}

## Allocate Elastic IP (EIP) for NAT Gateway
resource "aws_eip" "natgw1" {
  domain = "vpc"

  tags = {
    Name = "${local.prefix}-eip-natgw-1"
  }
}

## Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-igw"
  }

  depends_on = [aws_vpc.main]
}

## NAT Gatway
resource "aws_nat_gateway" "natgw1" {
  allocation_id = aws_eip.natgw1.allocation_id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "${local.prefix}-natgw-1"
  }

  depends_on = [aws_eip.natgw1, aws_internet_gateway.main]
}

## Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = local.az1_name
  cidr_block        = var.private_subnet_1_cidr

  tags = {
    "Name"                                            = "${local.prefix}-private-subnet-1"
    "kubernetes.io/role/internal-elb"                 = "1"      # Allow LBs to be created in this subnet by Kubernetes
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared" # Options: owned | shared
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = local.az2_name
  cidr_block        = var.private_subnet_2_cidr

  tags = {
    "Name"                                            = "${local.prefix}-private-subnet-2"
    "kubernetes.io/role/internal-elb"                 = "1"      # Allow LBs to be created in this subnet by Kubernetes
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared" # Options: owned | shared
  }
}

## Private Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.az1_name
  cidr_block              = var.public_subnet_1_cidr
  map_public_ip_on_launch = true

  tags = {
    Name                                              = "${local.prefix}-public-subnet-1"
    "kubernetes.io/role/elb"                          = "1"      # Allow LBs to be created in this subnet by Kubernetes
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared" # Options: owned | shared
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.az2_name
  cidr_block              = var.public_subnet_2_cidr
  map_public_ip_on_launch = true

  tags = {
    Name                                              = "${local.prefix}-public-subnet-2"
    "kubernetes.io/role/elb"                          = "1"      # Allow LBs to be created in this subnet by Kubernetes
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared" # Options: owned | shared
  }
}

## Route Tables

# For private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw1.id # Route outbound traffic via NAT Gateway
  }

  tags = {
    Name = "${local.prefix}-private-rtb"
  }
}

# For public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id # Route outbound traffic via Internet Gateway
  }

  tags = {
    Name = "${local.prefix}-public-rtb"
  }
}

# Associate public subnets and public route table
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets and private route table
resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private.id
}

## OUTPUTS ##
output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}
