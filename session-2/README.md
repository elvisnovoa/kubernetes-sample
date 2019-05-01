# Session 1: Working with VPCs and EC2

## Structure

The `infrastructure` directory includes the resources needed to create an EKS cluster on AWS. After applying the changes, run the following commands to configure tools.

```
$ aws eks --region us-east-1 update-kubeconfig --name my-eks-demo
$ kubectl get svc
$ kubectl apply -f aws-auth-cm.yaml
$ kubectl apply -f rbac-config.yaml
$ helm init --service-account tiller
$ kubectl get pods --namespace kube-system | grep tiller
```

The `initial` directory contains an incomplete starting point for a spring application stack using an mongodb backend.

The `complete` directory includes the solution to the missing elements.

Inside the `initial` directory you'll find the following:
- `backend`: includes the source code for the spring boot application
- `kubernetes`: includes sample kubernetes files for the app and mongodb deployment and services

## Objective

The `backend` shows a basic spring boot application. In order to deploy this to a cloud-native runtime, we need to containerize it by following [this guide](https://spring.io/guides/gs/spring-boot-docker/).

Once the app is containerized, use the `docker-compose.yml` file to test the stack.

At this point you should have a Kubernetes cluster running on AWS. While we can use the provided files to deploy the stack using `kubectl apply -f`, it is preferable to create a Helm chart.

Run `helm create mychart` to create a chart and move the files inside the `templates` directory.

Run `helm install mychart` to deploy the stack to the kubernetes cluster.

NOTE: Remember to clean up by running `helm delete` to delete the chart, or `kubectl delete -f` on each file. 

## Tips

- Use `kubectl get svc` to see service deployments.
- Use `kubectl get pods` to see instances of deployed apps.
- Use `kubectl describe pod {pod}` to see general info for a deployed app.
- Use `kubectl logs -f {pod}` to see the application logs.