##################################################
# Based on the following CloudFormation templates from https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html
#
# https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-vpc-sample.yaml
# https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-nodegroup.yaml
#
##################################################

terraform {
  required_version = ">= 0.11.11"
}

provider "aws" {
  region = "${var.aws_region}"
  version = ">= 1.42"
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

# Create a simple VPC
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











# Roles for Cluster and Nodes
resource "aws_iam_role" "eks_cluster_iam_role" {
  name = "eks-cluster-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_cluster_iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_cluster_iam_role.name}"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_name}"
//  role_arn = "${aws_iam_role.eks_cluster_iam_role.arn}"
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksServiceRole"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks_cluster_security_group.id}"]
    subnet_ids         = ["${aws_subnet.public.*.id}"]
  }
}




# Worker Nodes
locals {
  eks_cluster_node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${var.cluster_name}
USERDATA
}

resource "aws_launch_configuration" "eks_cluster_node_launch_configuration" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks_cluster_node_instance_profile.name}"
  image_id                    = "ami-0abcb9f9190e867ab"
  instance_type               = "t3.medium"
  name_prefix                 = "eks-cluster-node"
  security_groups             = ["${aws_security_group.eks_cluster_node_security_group.id}"]
  user_data_base64            = "${base64encode(local.eks_cluster_node_userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks_cluster_autoscaling_group" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.eks_cluster_node_launch_configuration.id}"
  max_size             = 2
  min_size             = 1
  name                 = "eks-cluster-autoscaling-group"
  vpc_zone_identifier  = ["${aws_subnet.public.*.id}"]

  tag {
    key                 = "Name"
    value               = "eks-cluster-autoscaling-group"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

