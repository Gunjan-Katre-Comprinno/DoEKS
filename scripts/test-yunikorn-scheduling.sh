#!/bin/bash

# YuniKorn Scheduler Testing Script
# Tests scheduling fairness and resource allocation

set -e

echo "=== YuniKorn Scheduler Testing ==="

# Check YuniKorn deployment
echo "1. Checking YuniKorn deployment..."
kubectl get pods -n yunikorn-system

# Check queue configuration
echo "2. Checking queue configuration..."
kubectl get configmap yunikorn-configs -n yunikorn-system -o yaml

# Submit production job
echo "3. Submitting production queue job..."
kubectl apply -f examples/spark-jobs/yunikorn-spark-example.yaml

# Submit development job
echo "4. Submitting development queue job..."
kubectl apply -f examples/spark-jobs/yunikorn-dev-example.yaml

# Monitor scheduling
echo "5. Monitoring job scheduling..."
sleep 10

echo "Production job status:"
kubectl get sparkapplication yunikorn-spark-pi -n spark-operator

echo "Development job status:"
kubectl get sparkapplication yunikorn-dev-job -n spark-operator

# Check YuniKorn UI (if accessible)
echo "6. YuniKorn UI available at:"
echo "kubectl port-forward -n yunikorn-system svc/yunikorn-service 9080:9080"
echo "Then access: http://localhost:9080"

echo "=== Testing Complete ==="
