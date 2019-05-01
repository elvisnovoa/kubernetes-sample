# Prerequisites

- Java 1.8
- Maven
- MongoDB (only required for running locally)
- Docker
- Terraform
- An AWS account and valid secret key and access key

# Backend Service

## Sample Data
Sample data is inserted to MongoDB at startup with Mongeez.

## REST API 
Start the app and POST to the following endpoint for login
```commandline
$ curl -i -X POST -H "Content-Type:application/json" -d "{  \"username\" : \"ironman\",  \"password\" : \"endgame\" }" http://localhost:8080/login

HTTP/1.1 200 
Content-Type: application/json;charset=UTF-8
Transfer-Encoding: chunked
Date: Tue, 19 Feb 2019 03:20:04 GMT

{"id":"5c6b6f7da1be94f4f5ee2e64","username":"ironman","password":"endgame","firstName":"Tony","lastName":"Stark"}
```

## Docker build
```
$ mvn install dockerfile:build
```

## Docker run
```
$ docker run -d -e "spring.data.mongodb.host=host.docker.internal" -p 8080:8080 everis/sample-service:latest 
```

## Docker Compose
``` 
$ docker-compose pull
$ docker-compose build
$ docker-compose up
```

# Infrastructure

## Terraform

Terraform scripts to build a VPC based on [this cloud formation template](https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-vpc-sample.yaml).

``` 
$ terraform init
$ terraform plan -out terraform.tfplan
$ terraform apply terraform.tfplan
```

## Kubectl

Update the ARN of the Node instance role (not instance profile) with the output from terraform on aws-auth-cm.yml

### AWS EKS
``` 
$ aws eks --region us-east-1 update-kubeconfig --name my-eks-demo
$ kubectl get svc
$ kubectl apply -f aws-auth-cm.yaml
$ kubectl apply -f rbac-config.yaml
$ helm init --service-account tiller
$ kubectl get pods --namespace kube-system | grep tiller
$ helm create mychart
$ helm install mychart
```

### Docker/k8s

Enable Kubernetes on Docker. If you are using multiple contexts, use `kubectl config use-context docker-for-desktop
` to switch to docker.

### Deploy the app

``` 
$ kubectl apply -f mongo-deployment.yaml
$ kubectl apply -f mongo-service.yaml
$ kubectl apply -f api-deployment.yaml
$ kubectl apply -f api-service.yaml
```

### Cleanup

``` 
$ kubectl delete -f api-service.yaml
$ kubectl delete -f api-deployment.yaml
$ kubectl delete -f mongo-service.yaml
$ kubectl delete -f mongo-deployment.yml
```