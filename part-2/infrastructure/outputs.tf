output "subnets" {
  value = aws_subnet.public.*.id
}

output "vpc" {
  value = aws_vpc.eks_vpc.id
}

output "endpoint" {
  value = aws_eks_cluster.example.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.example.certificate_authority.0.data
}