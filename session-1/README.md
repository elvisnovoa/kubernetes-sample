# Session 1: Working with VPCs and EC2

## Structure

The `initial` directory contains an incomplete starting point for a multi-tier application stack using an Apache HTTP server and an application server.

The `complete` directory includes the solution to the missing elements.

Inside each directory you'll find the following:
- `main.tf`: includes the network resources (vpc, subnets, route tables, etc)
- `security_groups.tf`: includes the instance-level firewalls to control access to the EC2 instances and load balancers
- `variables.tf`: well, variables.. shocking, right?
- `web_resources.tf`: resources for the Apache HTTP server (launch config, auto-scale group, load balancer, etc)
- `templates/`: initialization scripts to install apache and tomcat

## Objective

There are several `TODO` comments in the code. To go from `initial` to `complete`, those items must be resolved.

Additionally, there are no resources defined for an app server. We can create a new `app_resources.tf` file and add the necessary resources. We may use the `web_resources.tf` file as an example.

## Tips

- Create a `terraform.tfvars` file to override the default variables (ie. key_name).
- Run `terraform plan -out terraform.tfplan` to save the output to a file.
- Run `terraform apply terraform.tfplan` to apply a saved plan.
- Use `terraform console` to inspect the values of your resources.
- To enable terraform logging `export TF_LOG=DEBUG` and `export TF_LOG_PATH=terraform.log`.
- In order to access any ec2 instance, you need to open those ports with security groups.
- To access the internet, public subnets need a route to an internet gateway and private subnets need a route to a NAT gateway.
- You cannot SSH directly into instances on a private subnet (except when using a different kind of gateway). To access them, you need to jump through another instance, typically a bastion host.
- User data scripts write to `/var/log/cloud-init-output.log` on the EC2 instance.