variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "my-eks-demo"
}

variable "key_name" {
  default = ""
}

variable "subnets" {
  type = "list"
  default = ["192.168.64.0/18", "192.168.128.0/18", "192.168.192.0/18"]
}

variable "eks_policies" {
  type = "list"
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

//variable "eks_admin_role_arn" {
//  type = "string"
//}
