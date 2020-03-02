# Boilerplate stuff
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = "us-east-1"
  version = ">= 1.42"
}

# Ask AWS for the available AZs
data "aws_availability_zones" "available" {
}

# search for most recent version of Amazon Linux AMI
data "aws_ami" "aws_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-20*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Create a new vpc with the 192.168.0.0/16 ip address range
resource "aws_vpc" "example" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "dev"
    Environment = var.environment
  }
}

# Create empty route tables for public and private subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name        = "dev-public"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name        = "dev-private"
    Environment = var.environment
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.example.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "dev-public"
    Environment = var.environment
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.example.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "dev-private"
    Environment = var.environment
  }
}

# Associate public subnet to public route table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

# Associate private subnet to private route table
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id
}

# Create Internet Gateway and add route to allow internet traffic from public subnets
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name        = "dev-igw"
    Environment = var.environment
  }
}

resource "aws_route" "route_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

# Allocate ellastic IP for NAT gateway, create NAT gateway on public subnets and add route to allow internet traffic from private subnets
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "dev-natgw"
  }
}

resource "aws_nat_gateway" "nat" {
  depends_on = [aws_internet_gateway.internet_gw]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # normally, we'd want to have one NAT gateway and private route table per AZ, but I'm cheap so we'll just use one

  tags = {
    Name        = "dev-natgw"
    Environment = var.environment
  }
}

resource "aws_route" "route_natgw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

