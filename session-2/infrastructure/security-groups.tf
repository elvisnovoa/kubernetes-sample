
resource "aws_security_group" "sg_control_plane" {
  name = "sg.${var.cluster_name}.control_plane"
  description = "Cluster communication with worker nodes"
  vpc_id = "${aws_vpc.eks_vpc.id}"

  tags = "${map("Name", "${var.cluster_name}-control-plane")}"
}

# Control Plane SG rules. Declared separately to avoid precedence circularity
resource "aws_security_group_rule" "sgr_control_plane_egress_workers" {
  security_group_id = "${aws_security_group.sg_control_plane.id}"

  from_port = 1025
  protocol = "TCP"
  to_port = 65535
  type = "egress"
  description = "Allow the cluster control plane to communicate with worker Kubelet and pods"
  source_security_group_id = "${aws_security_group.sg_nodes.id}"
}

resource "aws_security_group_rule" "sgr_control_plane_egress_https" {
  security_group_id = "${aws_security_group.sg_control_plane.id}"

  from_port = 443
  protocol = "TCP"
  to_port = 443
  type = "egress"
  description = "Allow the cluster control plane to communicate with pods running extension API servers on port 443"
  source_security_group_id = "${aws_security_group.sg_nodes.id}"
}

resource "aws_security_group_rule" "sgr_control_plane_ingress_https" {
  security_group_id = "${aws_security_group.sg_control_plane.id}"

  from_port = 443
  protocol = "TCP"
  to_port = 443
  type = "ingress"
  description = "Allow pods to communicate with the cluster API Server"
  source_security_group_id = "${aws_security_group.sg_nodes.id}"
}

resource "aws_security_group" "sg_nodes" {
  name = "sg.${var.cluster_name}.eks_nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id = "${aws_vpc.eks_vpc.id}"

  tags = "${map("Name", "${var.cluster_name}-nodes", "kubernetes.io/cluster/${var.cluster_name}", "owned")}"

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outbound traffic"
  }

  ingress {
    from_port = 1025
    protocol = "TCP"
    to_port = 65535
    security_groups = ["${aws_security_group.sg_control_plane.id}"]
    description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  }

  ingress {
    from_port = 443
    protocol = "TCP"
    to_port = 443
    security_groups = ["${aws_security_group.sg_control_plane.id}"]
    description = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
  }

  ingress {
    from_port = 22
    protocol = "TCP"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from everywhere (never do this!)"
  }
}

# Declared separately to avoid self-reference error
resource "aws_security_group_rule" "sgr_node_ingress" {
  security_group_id = "${aws_security_group.sg_nodes.id}"

  type = "ingress"
  protocol = "-1"
  from_port = 0
  to_port = 0
  source_security_group_id = "${aws_security_group.sg_nodes.id}"
  description = "Allow nodes to communicate with each other"
}
