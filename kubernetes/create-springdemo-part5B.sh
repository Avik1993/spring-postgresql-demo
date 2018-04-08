#!/bin/bash

# apply resources part 5B: v2 to uat

# *** change to your own gke cluster's ranges! ***
# gcloud container clusters describe election-nonprod-cluster \
#   --zone us-east1-b --project springdemo-199819 \
#   | egrep 'clusterIpv4Cidr|servicesIpv4Cidr'

export IP_RANGES="10.32.0.0/14,10.35.240.0/20"

# election v2 deployment with manual sidecar injection
istioctl kube-inject –kubeconfig "~/.kube/config" \
  -f ./services/election-deployment-v2-uat.yaml \
  --includeIPRanges=$IP_RANGES > \
  election-deployment-istio.yaml \
  && kubectl apply -f election-deployment-istio.yaml \
  && rm election-deployment-istio.yaml
# kubectl get deployments -n uat

# routing
kubectl apply -f ./other/routerule-election-v2-canary-uat.yaml
# kubectl describe routerule -n uat
