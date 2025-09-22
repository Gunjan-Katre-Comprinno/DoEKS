#!/bin/bash

echo "=== EKS Cluster Debug Script ==="

# Test AWS credentials
echo "1. Testing AWS credentials..."
aws sts get-caller-identity

# Check EKS cluster status
echo -e "\n2. Checking EKS cluster status..."
aws eks describe-cluster --name testing-eks-cluster --region us-east-1

# Update kubeconfig
echo -e "\n3. Updating kubeconfig..."
aws eks update-kubeconfig --name testing-eks-cluster --region us-east-1

# Test kubectl access
echo -e "\n4. Testing kubectl access..."
kubectl get nodes
kubectl get pods --all-namespaces

# Check cluster health
echo -e "\n5. Checking cluster health..."
kubectl get componentstatuses
kubectl top nodes 2>/dev/null || echo "Metrics server may not be ready"

echo -e "\n=== Debug Complete ==="
