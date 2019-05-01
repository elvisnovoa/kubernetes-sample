resource "aws_vpc" "eks_vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"

  tags = "${map("Name", "${var.cluster_name}-vpc", "kubernetes.io/cluster/${var.cluster_name}", "shared")}" // Tag this vpc so k8s can discover it
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.eks_vpc.id}"
  tags = "${map("Name", "${var.cluster_name}-igw")}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.eks_vpc.id}"
  tags = "${map("Name", "${var.cluster_name}-public")}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "public" {
  count = "${length(var.subnets)}"
  vpc_id = "${aws_vpc.eks_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block = "${var.subnets[count.index]}"
  map_public_ip_on_launch = "true"

  tags = "${map("Name", "${var.cluster_name}-public-${count.index}", "kubernetes.io/cluster/${var.cluster_name}", "shared")}" // Tag these subnets so k8s can discover them
}

resource "aws_route_table_association" "public" {
  count = "${length(var.subnets)}"
  subnet_id = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}