#!/bin/bash

# part 1: create local dev environment on minikube

kubectl config use-context minikube

# namespace
kubectl apply -f ./resources/namespace-dev.yaml
# kubectl describe namespace dev

# ingress
kubectl apply -f ./resources/ingress-dev.yaml
# kubectl get ingresses -n dev
