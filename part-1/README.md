# Part 1: Working with VPCs and EC2

This simple terraform project will create the following resources (among other things):

- a VPC
- two (2) public subnets
- two (2) private subnets
- an Internet Gateway and a NAT Gateway
- two (2) autoscaling EC2 instances with an Apache HTTP server on a public subnet
- two (2) autoscaling EC2 instances with a Tomcat instance on a private subnet
- Load balancers for each server

## Requirements 
- terraform v0.12
- an AWS account and a valid access key / secret key

## Usage
### Deploy infrastructure
```
terraform plan -out terraform.tfplan
terraform apply terraform.tfplan
```

### Destroy infrastructure
```
terraform destroy
```