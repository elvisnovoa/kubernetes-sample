resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.role_eks_cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.sg_eks_cluster.id}"]
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

resource "aws_launch_configuration" "launch_configuration" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks_worker_node_instance_profile.name}"
  image_id                    = "ami-0abcb9f9190e867ab"
  instance_type               = "t3.medium"
  name_prefix                 = "eks-worker-node"
  security_groups             = ["${aws_security_group.sg_worker_node.id}"]
  user_data_base64            = "${base64encode(local.eks_cluster_node_userdata)}"
  key_name = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.launch_configuration.id}"
  max_size             = 2
  min_size             = 1
  name                 = "eks-worker-node"
  vpc_zone_identifier  = ["${aws_subnet.public.*.id}"]

  tag {
    key                 = "Name"
    value               = "eks-worker-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}