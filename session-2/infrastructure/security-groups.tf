resource "aws_security_group" "eks_cluster_security_group" {
  name        = "eks-cluster-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.eks_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "eks-cluster"
  }
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "eks_cluster_security_group_ingress_workstation_https" {
  cidr_blocks       = ["172.31.0.0/16"]
  description       = "Allow bastion to communicate with the eks cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks_cluster_security_group.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "eks_cluster_node_security_group" {
  name        = "eks-cluster-node-security-group"
  description = "Security group for all nodes in the eks cluster"
  vpc_id      = "${aws_vpc.eks_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "eks-cluster-node-security-group"
    )
  }"
}

resource "aws_security_group_rule" "eks_cluster_node_ingress_self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks_cluster_node_security_group.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_node_security_group.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cluster_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_cluster_node_security_group.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_security_group.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cluster_node_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_cluster_security_group.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_node_security_group.id}"
  to_port                  = 443
  type                     = "ingress"
}