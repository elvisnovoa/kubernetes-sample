terraform {
  required_version = "0.11.11"
}

provider "aws" {
  region = "us-east-1"
  version = ">= 1.42"
}

//data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

##################################################
# Based on amazon-eks-vpc-sample
# https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-vpc-sample.yaml
##################################################

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = "${map("Name", "${var.project}-vpc")}"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.eks_vpc.id}"
  tags = "${map("Name", "${var.project}-igw")}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.eks_vpc.id}"
  tags = "${map("Name", "${var.project}-public")}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "public" {
  count                   = "${length(var.subnets)}"
  vpc_id                  = "${aws_vpc.eks_vpc.id}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "${var.subnets[count.index]}"
  map_public_ip_on_launch = "true"

  tags = "${map("Name", "${var.project}-public-${count.index}")}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.subnets)}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_security_group" "control_plane" {
  name        = "sg.${var.project}.control_plane"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.eks_vpc.id}"

  tags = "${map("Name", "${var.project}-control-plane")}"
}

##################################################
# End of amazon-eks-vpc-sample
##################################################