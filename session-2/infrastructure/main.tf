##################################################
# Based on the following CloudFormation templates from https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html
#
# https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-vpc-sample.yaml
# https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-nodegroup.yaml
#
##################################################

terraform {
  required_version = ">= 0.11.11"
}

provider "aws" {
  region = "${var.aws_region}"
  version = ">= 1.42"
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

locals {
  aws_auth_cm = <<CONFIGMAP

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.role_eks_worker_node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes

CONFIGMAP
}

resource "local_file" "aws_auth_cm" {
  content  = "${local.aws_auth_cm}"
  filename = "${path.cwd}/aws-auth-cm.yaml"
}