#!/bin/bash

# Check if kind is installed
command -v kind >/dev/null 2>&1 || { 
    echo >&2 "Kind is necessary to run the setup script. Aborting environment setup"; exit 1; 
}

echo "Configure kind cluster"

# create kind cluster
kind create cluster --config environment/cluster-config.yaml --name TBRD

echo "Configure ingress services"
kubectl apply -f environment/mandatory.yaml
kubectl patch deployments -n ingress-nginx nginx-ingress-controller -p "$(cat environment/kind/nginx-kind-paths.json)"
kubectl apply -f kubernetes/nginx/nginx-ingress.yaml

# configure environment
# PersistentVolume
kubectl apply -f kubernetes/volume/pv.yaml
kubectl apply -f kubernetes/volume/pv-claim.yaml

# postgis
sleep 3 # fix looking up service account error
kubectl apply -f kubernetes/postgis/postgis-deployment.yaml
kubectl apply -f kubernetes/postgis/postgis-service.yaml

# geoserver
sleep 3 # fix looking up service account error
kubectl apply -f kubernetes/geoserver/geoserver-deployment.yaml
kubectl apply -f kubernetes/geoserver/geoserver-service.yaml

# owncloud
kubectl apply -f kubernetes/owncloud/owncloud-deployment.yaml
kubectl apply -f kubernetes/owncloud/owncloud-service.yaml

# geonetwork
kubectl apply -f kubernetes/geonetwork/geonetwork-deployment.yaml
kubectl apply -f kubernetes/geonetwork/geonetwork-service.yaml

# terrama2
kubernetes/terrama2/setup_configmap.sh

sleep 3
kubectl apply -f kubernetes/terrama2/alert-deployment.yaml
kubectl apply -f kubernetes/terrama2/analysis-deployment.yaml
kubectl apply -f kubernetes/terrama2/collector-deployment.yaml
kubectl apply -f kubernetes/terrama2/interpolator-deployment.yaml
kubectl apply -f kubernetes/terrama2/view-deployment.yaml
kubectl apply -f kubernetes/terrama2/webapp-deployment.yaml
kubectl apply -f kubernetes/terrama2/webmonitor-deployment.yaml
kubectl apply -f kubernetes/terrama2/webapp-service.yaml
kubectl apply -f kubernetes/terrama2/webmonitor-service.yaml