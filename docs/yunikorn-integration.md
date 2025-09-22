# YuniKorn Scheduler Integration

## Overview
YuniKorn is deployed as an alternative scheduler for batch and analytical jobs, providing advanced resource management and multi-tenant capabilities.

## Features
- **Multi-tenant queues**: Production, development, and user queues
- **Resource guarantees**: Guaranteed and maximum resource limits per queue
- **Fair scheduling**: Fair resource allocation within queues
- **Spark integration**: Native Spark Operator integration

## Queue Configuration

### Production Queue
- **Guaranteed**: 100Gi memory, 50 vCores
- **Maximum**: 200Gi memory, 100 vCores
- **Access**: `spark-production` users

### Development Queue
- **Guaranteed**: 50Gi memory, 25 vCores
- **Maximum**: 100Gi memory, 50 vCores
- **Access**: `spark-dev` users

### Default Queue
- **Guaranteed**: 20Gi memory, 10 vCores
- **Maximum**: 50Gi memory, 25 vCores
- **Access**: All users

## Using YuniKorn with Spark

### 1. Queue Annotation
Add to Spark job metadata:
```yaml
annotations:
  yunikorn.apache.org/queue: root.production
```

### 2. Scheduler Configuration
Add to Spark configuration:
```yaml
sparkConf:
  "spark.kubernetes.scheduler.name": "yunikorn"
```

### 3. Example Job Submission
```bash
kubectl apply -f examples/spark-jobs/yunikorn-spark-example.yaml
```

## Testing Scheduling Fairness
```bash
./scripts/test-yunikorn-scheduling.sh
```

## Monitoring
Access YuniKorn UI:
```bash
kubectl port-forward -n yunikorn-system svc/yunikorn-service 9080:9080
```
Then visit: http://localhost:9080

## Queue Management
Queues are configured via ConfigMap and can be updated:
```bash
kubectl edit configmap yunikorn-configs -n yunikorn-system
```
