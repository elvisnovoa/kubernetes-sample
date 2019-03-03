variable "project" {
  default = "eks-demo"
}

variable "subnets" {
  type = "list"
  default = ["192.168.64.0/18", "192.168.128.0/18", "192.168.192.0/18"]
}