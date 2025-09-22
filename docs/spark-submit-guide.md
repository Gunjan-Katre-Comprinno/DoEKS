# Spark Submit on EKS Guide

## Overview
This setup enables submitting Spark jobs to EKS using the Spark Operator with proper RBAC, service accounts, and S3 integration.

## Prerequisites
- EKS cluster with Spark Operator deployed
- RBAC configured for Spark jobs
- Service account with IRSA for S3 access

## Service Accounts & RBAC
- **spark-driver**: Service account for Spark driver pods with IRSA
- **spark-driver-role**: ClusterRole with necessary permissions
- **spark-driver-binding**: ClusterRoleBinding connecting SA to role

## Submitting Jobs

### 1. Using kubectl directly
```bash
kubectl apply -f examples/spark-jobs/pyspark-example.yaml
```

### 2. Using the submission script
```bash
./scripts/submit-spark-job.sh examples/spark-jobs/pyspark-example.yaml
```

### 3. Via CI/CD Pipeline
Push changes to `spark-jobs/` directory or trigger manually via GitHub Actions.

## Job Examples

### PySpark Job
```yaml
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: pyspark-pi
  namespace: spark-operator
spec:
  type: Python
  pythonVersion: "3"
  mode: cluster
  image: "public.ecr.aws/spark/spark:3.5.0"
  mainApplicationFile: local:///opt/spark/examples/src/main/python/pi.py
  driver:
    serviceAccount: spark-driver
  sparkConf:
    "spark.hadoop.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem"
    "spark.hadoop.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.WebIdentityTokenCredentialsProvider"
```

### Scala Job
```yaml
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: spark-pi-scala
spec:
  type: Scala
  mainClass: org.apache.spark.examples.SparkPi
  mainApplicationFile: "local:///opt/spark/examples/jars/spark-examples_2.12-3.5.0.jar"
  driver:
    serviceAccount: spark-driver
```

## S3 Integration
Jobs automatically have S3 access via IRSA. Use `s3a://` URLs:
```yaml
mainApplicationFile: "s3a://your-bucket/spark-jobs/app.py"
```

## Monitoring Jobs
```bash
# List all Spark applications
kubectl get sparkapplication -n spark-operator

# Get job details
kubectl describe sparkapplication <job-name> -n spark-operator

# View driver logs
kubectl logs -f spark-<job-name>-driver -n spark-operator

# View executor logs
kubectl logs -f spark-<job-name>-exec-1 -n spark-operator
```

## CI/CD Integration
The GitHub Actions workflow automatically:
1. Configures AWS credentials
2. Updates kubeconfig for EKS
3. Submits Spark jobs
4. Monitors job status

Trigger via:
- Push to `spark-jobs/` directory
- Manual workflow dispatch with job file parameter

## Troubleshooting
- Ensure service account has proper IRSA annotations
- Check RBAC permissions for spark-driver
- Verify S3 bucket access from IAM role
- Monitor pod events for image pull or scheduling issues
