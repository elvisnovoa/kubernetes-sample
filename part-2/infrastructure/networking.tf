resource "aws_vpc" "eks_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    "Name"                                      = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  } // Tag this vpc so k8s can discover it
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    "Name" = "${var.cluster_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    "Name" = "${var.cluster_name}-public"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.eks_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = "true"

  tags = {
    "Name"                                      = "${var.cluster_name}-public-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  } // Tag these subnets so k8s can discover them
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = element(aws_route_table.public.*.id, count.index)
}


## private subnets for Fargate
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "dev-natgw"
  }
}

resource "aws_nat_gateway" "default" {
  depends_on = [aws_internet_gateway.default]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "dev-natgw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    "Name" = "${var.cluster_name}-private"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default.id
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.eks_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = "false"

  tags = {
    "Name"                                      = "${var.cluster_name}-private-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  } // Tag these subnets so k8s can discover them
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
