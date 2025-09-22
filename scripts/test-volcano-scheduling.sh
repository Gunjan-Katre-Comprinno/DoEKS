#!/bin/bash

echo "=== Volcano Scheduler Testing Script ==="

# Check if Volcano is running
echo "1. Checking Volcano deployment status..."
kubectl get pods -n volcano-system

# Check Volcano queues
echo -e "\n2. Checking Volcano queues..."
kubectl get queues

# Submit ML training job
echo -e "\n3. Submitting ML training job to ml-training queue..."
kubectl apply -f examples/volcano-jobs/ml-training-job.yaml

# Submit HPC batch job
echo -e "\n4. Submitting HPC batch job to hpc-batch queue..."
kubectl apply -f examples/volcano-jobs/hpc-batch-job.yaml

# Submit Spark + Volcano job
echo -e "\n5. Submitting Spark job with Volcano scheduler..."
kubectl apply -f examples/volcano-jobs/spark-volcano-job.yaml

# Monitor job status
echo -e "\n6. Monitoring job status..."
sleep 10

echo "Volcano Jobs:"
kubectl get vcjobs

echo -e "\nSpark Applications:"
kubectl get sparkapplications

echo -e "\nPod status across all namespaces:"
kubectl get pods --all-namespaces | grep -E "(ml-training|hpc-batch|spark-volcano)"

echo -e "\n7. Queue resource allocation:"
kubectl describe queues

echo -e "\n=== Testing completed. Monitor jobs with: ==="
echo "kubectl get vcjobs -w"
echo "kubectl get sparkapplications -w"
echo "kubectl get pods -w"
