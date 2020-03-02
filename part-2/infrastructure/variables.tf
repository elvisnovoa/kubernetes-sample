variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "my-eks-demo"
}

variable "key_name" {
  default = ""
}

variable "public_subnets" {
  type    = list(string)
  default = ["192.168.0.0/24", "192.168.2.0/24", "192.168.4.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["192.168.1.0/24", "192.168.3.0/24", "192.168.5.0/24"]
}

variable "eks_policies" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

//variable "eks_admin_role_arn" {
//  type = "string"
//}
