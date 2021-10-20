#!/bin/bash


echo " -- Install Argo Events --"
kubectl create namespace argo-events
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install-validating-webhook.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
kubectl apply -f argo-events/deployment/project.yaml -n argocd
kubectl apply -f argo-events/deployment/application.yaml -n argocd
echo ""
echo "-- Install Argo Worklows --"
kubectl create namespace argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/install.yaml
kubectl patch -n argo cm workflow-controller-configmap -p '{"data": {"containerRuntimeExecutor": "pns"}}'
kubectl apply -f argo-workflow/deployment/project.yaml -n argocd
kubectl apply -f argo-workflow/deployment/application.yaml -n argocd
echo ""
echo "-- Install Falco --"
kubectl create namespace falco
kubectl apply -f falco/deployment/project.yaml -n argocd
kubectl apply -f falco/deployment/application.yaml -n argocd
echo ""
echo "-- Wait until Pods are up & running --"
ARGOCD_SERVER=$(kubectl get pods -n argocd | grep argocd-server | cut -f1 -d" ")
ARGOWORKFLOW_SERVER=$(kubectl get pods -n argo | grep argo-server | cut -f1 -d" ")
kubectl -n argocd wait pod/${ARGOCD_SERVER} --for=condition=Ready --timeout=-1s
kubectl -n argo wait pod/${ARGOWORKFLOW_SERVER} --for=condition=Ready --timeout=-1s
echo "DONE"
