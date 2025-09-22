#!/bin/bash

# Spark Job Submission Script for CI/CD
# Usage: ./submit-spark-job.sh <job-yaml-file> [namespace]

set -e

JOB_FILE=${1:-""}
NAMESPACE=${2:-"spark-operator"}

if [ -z "$JOB_FILE" ]; then
    echo "Usage: $0 <job-yaml-file> [namespace]"
    echo "Example: $0 examples/spark-jobs/pyspark-example.yaml"
    exit 1
fi

if [ ! -f "$JOB_FILE" ]; then
    echo "Error: Job file '$JOB_FILE' not found"
    exit 1
fi

echo "Submitting Spark job from: $JOB_FILE"
echo "Namespace: $NAMESPACE"

# Apply the job
kubectl apply -f "$JOB_FILE" -n "$NAMESPACE"

# Get job name from the YAML file
JOB_NAME=$(grep "name:" "$JOB_FILE" | head -1 | awk '{print $2}')

echo "Job '$JOB_NAME' submitted successfully"
echo "Monitor with: kubectl get sparkapplication $JOB_NAME -n $NAMESPACE -w"
echo "Logs: kubectl logs -f spark-$JOB_NAME-driver -n $NAMESPACE"
