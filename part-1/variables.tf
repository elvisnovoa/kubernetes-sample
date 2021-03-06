variable "environment" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["192.168.0.0/24", "192.168.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["192.168.1.0/24", "192.168.3.0/24"]
}

variable "key_name" {
  default = ""
}

