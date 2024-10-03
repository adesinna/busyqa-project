#!/bin/bash

# Deploy EBS CSI Driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# Verify ebs-csi pods running
kubectl get pods -n kube-system

# Install Helm
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify Helm installation
echo "Verifying Helm installation..."
helm version

# Add the 5-ingress-nginx repository
echo "Adding ingress-nginx repository..."
helm repo add 5-ingress-nginx https://kubernetes.github.io/ingress-nginx

# Search for available versions
echo "Searching for available versions of the ingress-nginx controller..."
helm search repo 5-ingress-nginx --versions


kubectl create ns 5-ingress-nginx

# Set environment variables for versions
CHART_VERSION="4.11.2"
APP_VERSION="1.11.2"

# Create a manifest directory
mkdir -p ./manifest

# Generate the NGINX Ingress Controller manifest
echo "Generating NGINX Ingress Controller manifest..."
helm template 5-ingress-nginx 5-ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --version ${CHART_VERSION} \
    --namespace 5-ingress-nginx \
    > ./manifest/nginx-5-ingress.${APP_VERSION}.yaml

# Apply the generated manifest
echo "Applying the NGINX Ingress Controller manifest..."
kubectl apply -f ./manifest/nginx-5-ingress.${APP_VERSION}.yaml

echo "Installing Cert-Manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml


# install metric-server
echo "Installing metric-server.."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml


echo "All done"
