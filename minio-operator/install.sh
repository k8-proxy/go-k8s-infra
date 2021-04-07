#!/bin/bash

# Create namespaces
kubectl create ns minio-operator
kubectl create ns minio

# Install minio operator
helm repo add minio https://operator.min.io/
helm install --namespace minio-operator --create-namespace --generate-name minio/minio-operator