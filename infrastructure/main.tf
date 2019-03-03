terraform {
  required_version = "0.11.11"
}

provider "aws" {
  region = "${var.aws_region}"
  version = ">= 1.42"
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

##################################################
# Based on amazon-eks-vpc-sample
# https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-vpc-sample.yaml
##################################################

resource "aws_vpc" "eks_vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"

  tags = "${map("Name", "${var.cluster_name}-vpc")}"
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

  tags = "${map("Name", "${var.cluster_name}-public-${count.index}")}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.subnets)}"
  subnet_id = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_security_group" "control_plane" {
  name = "sg.${var.cluster_name}.control_plane"
  description = "Cluster communication with worker nodes"
  vpc_id = "${aws_vpc.eks_vpc.id}"

  tags = "${map("Name", "${var.cluster_name}-control-plane")}"
}

##################################################
# End of amazon-eks-vpc-sample
##################################################

resource "aws_eks_cluster" "my_cluster" {
  name = "${var.cluster_name}"
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksServiceRole"

  vpc_config {
    subnet_ids = [
      "${aws_subnet.public.*.id}"]
  }
}

##################################################
# Based on amazon-eks-nodegroup
# https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-nodegroup.yaml
##################################################

resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "node_instance_profile"
  role = "${aws_iam_role.node_instance_role.name}"
}

resource "aws_iam_role" "node_instance_role" {
  name = "node_instance_role"
  path = "/"
  force_detach_policies = true

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = "${map("Name", "${var.cluster_name}-node-instance-role")}"
}

resource "aws_iam_role_policy_attachment" "node_instance_role" {
  role = "${aws_iam_role.node_instance_role.name}"
  count = "${length(var.eks_policies)}"
  policy_arn = "${var.eks_policies[count.index]}"
}

resource "aws_security_group" "node_security_group" {
  name = "sg.${var.cluster_name}.eks_nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id = "${aws_vpc.eks_vpc.id}"

  tags = "${map("Name", "${var.cluster_name}-nodes", "kubernetes.io/cluster/", "owned")}"
}

resource "aws_security_group_rule" "node_ssh_ingress" {
  security_group_id = "${aws_security_group.node_security_group.id}"

  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
//  source_security_group_id = "${aws_security_group.node_security_group.id}"
  cidr_blocks = ["108.85.37.143/32"]
  description = "Allow ssh from everywhere"
}

resource "aws_security_group_rule" "node_egress_everywhere" {
  security_group_id = "${aws_security_group.node_security_group.id}"

  type = "egress"
  protocol = "tcp"
  from_port = 0
  to_port = 65535
  //  source_security_group_id = "${aws_security_group.node_security_group.id}"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "node_sg_ingress" {
  security_group_id = "${aws_security_group.node_security_group.id}"

  type = "ingress"
  protocol = "-1"
  from_port = 0
  to_port = 65535
  source_security_group_id = "${aws_security_group.node_security_group.id}"
  description = "Allow node to communicate with each other"
}

resource "aws_security_group_rule" "nodes_ingress_from_control_plane" {
  security_group_id = "${aws_security_group.node_security_group.id}"

  type = "ingress"
  protocol = "tcp"
  from_port = 1025
  to_port = 65535
  source_security_group_id = "${aws_security_group.control_plane.id}"
  description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
}

resource "aws_security_group_rule" "control_plane_egress_to_nodes" {
  security_group_id = "${aws_security_group.control_plane.id}"

  type = "egress"
  protocol = "tcp"
  from_port = 1025
  to_port = 65535
  source_security_group_id = "${aws_security_group.node_security_group.id}"
  description = "Allow the cluster control plane to communicate with worker Kubelet and pods"
}

resource "aws_security_group_rule" "nodes_ingress_from_control_plane_https" {
  security_group_id = "${aws_security_group.node_security_group.id}"

  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  source_security_group_id = "${aws_security_group.control_plane.id}"
  description = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
}

resource "aws_security_group_rule" "control_plane_egress_to_nodes_https" {
  security_group_id = "${aws_security_group.control_plane.id}"

  type = "egress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  source_security_group_id = "${aws_security_group.node_security_group.id}"
  description = "Allow the cluster control plane to communicate with pods running extension API servers on port 443"
}

resource "aws_security_group_rule" "control_plane_ingress_to_nodes_https" {
  security_group_id = "${aws_security_group.control_plane.id}"

  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  source_security_group_id = "${aws_security_group.node_security_group.id}"
  description = "Allow pods to communicate with the cluster API Server"
}

resource "aws_launch_configuration" "node_launch_config" {
  image_id = "ami-0eeeef929db40543c"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.node_instance_profile.id}"

  associate_public_ip_address = true
  security_groups = [
    "${aws_security_group.node_security_group.id}"]
  key_name = "${var.key_name}"

  root_block_device {
    volume_size = "20"
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<EOF
#!/bin/bash

sudo yum -y update

set -o xtrace
sudo /etc/eks/bootstrap.sh ${aws_eks_cluster.my_cluster.name}

EOF
}

resource "aws_autoscaling_group" "node_asg" {
  desired_capacity = 3
  launch_configuration = "${aws_launch_configuration.node_launch_config.name}"
  min_size = 1
  max_size = 6
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
     "key" = "Name",
      value = "${var.cluster_name}-node",
      "propagate_at_launch" = true
    }, {
      "key" = "kubernetes.io/cluster/${var.cluster_name}",
      value = "owned",
      "propagate_at_launch" = true
    }

  ]
}
##################################################
# End of amazon-eks-vpc-sample
##################################################