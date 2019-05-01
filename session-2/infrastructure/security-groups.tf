resource "aws_security_group" "sg_eks_cluster" {
  name        = "sg.eks-cluster"
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

resource "aws_security_group" "sg_worker_node" {
  name        = "sg.eks-worker-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.eks_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "sg.eks-worker-node"
    )
  }"
}

resource "aws_security_group_rule" "worker_node_ingress_self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.sg_worker_node.id}"
  source_security_group_id = "${aws_security_group.sg_worker_node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg_worker_node.id}"
  source_security_group_id = "${aws_security_group.sg_eks_cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_node_ingress_node_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg_eks_cluster.id}"
  source_security_group_id = "${aws_security_group.sg_worker_node.id}"
  to_port                  = 443
  type                     = "ingress"
}
resource "aws_security_group_rule" "worker_node_ingress_node_ssh" {
  description              = "Allow ssh from everywhere"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg_worker_node.id}"
  to_port                  = 22
  type                     = "ingress"
  cidr_blocks              = ["0.0.0.0/0"]
}