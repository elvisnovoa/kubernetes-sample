output "subnets" {
  value = "${aws_subnet.public.*.id}"
}

output "vpc" {
  value = "${aws_vpc.eks_vpc.id}"
}

output "node_role" {
  value = "${aws_iam_role.role_eks_worker_node.arn}"
}

output "eks_endpoint" {
  value = "${aws_eks_cluster.eks_cluster.endpoint}"
}