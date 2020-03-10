##################################################
# Based on the following CloudFormation templates from https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html
#
# https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-vpc-sample.yaml
# https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-nodegroup.yaml
#
##################################################

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    region  = "us-east-1"
    bucket  = "com.elvisnovoa.demo.tf.state"
    key     = "terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region  = var.aws_region
  version = ">= 1.42"
}

data "aws_caller_identity" "current" {
}

data "aws_availability_zones" "available" {
}

