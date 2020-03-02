# Part 2: Kubernetes

The `infrastructure` directory includes the terraform resources needed to create an EKS cluster on AWS. 
- A VPC with public and private subnets
- Internet and NAT gateways
- An EKS cluster
- Security Groups and IAM roles
- A managed node group for EKS
- A Fargate profile for EKS 

## Requirements 
- terraform v0.12
- an AWS account and a valid access key / secret key
- kubectl 
- helm v3

After building the cluster, run the following command to configure `kubectl`.
```
$ aws eks --region us-east-1 update-kubeconfig --name my-eks-demo
```

## Usage
### Deploy infrastructure
```
terraform plan -out terraform.tfplan
terraform apply terraform.tfplan
```

After building the cluster, run the following command to configure `kubectl`.
```
$ aws eks --region us-east-1 update-kubeconfig --name my-eks-demo
```
#### Admin stuff
Under part-2/k8s/resources, run the `install-stuff.sh` script to install the Admin Dashboard and Fluentd for cloudwatch logs

To access the Dashboard, run the following command to get a token.
`kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')`

Then run `kubectl proxy` to access the dashboard locally and go to the following url
`http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login`

#### The hard way
Deploy an nginx server to the managed nodes
`kubectl apply -f deployment.yaml`
Deploy a job to Fargate
`kubectl apply -f job.yaml`

#### The Helm way
Deploy a custom app
`helm install sample-chart sample-chart`

Deploy a third-party chart
`helm install scdf stable/spring-cloud-data-flow`

### Destroy infrastructure
```
./cleanup-stuff.sh
terraform destroy
```