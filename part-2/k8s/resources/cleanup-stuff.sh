#!/usr/bin/env bash
DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< $DOWNLOAD_URL)

helm uninstall sample-chart
helm uninstall scdf
kubectl delete -f job.yaml
kubectl delete -f deployment.yaml
kubectl delete -f eks-admin-service-account.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
kubectl delete -f metrics-server-$DOWNLOAD_VERSION/deploy/1.8+/
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/my-eks-demo/;s/{{region_name}}/us-east-1/" | kubectl delete -f -