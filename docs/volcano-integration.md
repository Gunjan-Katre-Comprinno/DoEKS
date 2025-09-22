# Volcano Scheduler Integration

## Overview
Volcano is a Kubernetes-native batch scheduler designed for ML/AI and HPC workloads. It provides advanced scheduling capabilities including gang scheduling, fairness policies, and queue management.

## Features
- **Gang Scheduling**: All-or-nothing scheduling for distributed jobs
- **Queue Management**: Multi-tenant resource allocation with priorities
- **Fairness Policies**: DRF (Dominant Resource Fairness) scheduling
- **ML/AI Optimized**: Designed for distributed training workloads
- **HPC Support**: Batch job scheduling for scientific computing

## Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Spark Jobs    │    │   ML Training    │    │   HPC Batch     │
│                 │    │     Jobs         │    │     Jobs        │
└─────────┬───────┘    └────────┬─────────┘    └─────────┬───────┘
          │                     │                        │
          └─────────────────────┼────────────────────────┘
                                │
                    ┌───────────▼────────────┐
                    │   Volcano Scheduler    │
                    │   - Gang Scheduling    │
                    │   - Queue Management   │
                    │   - Fairness Policies  │
                    └───────────┬────────────┘
                                │
                    ┌───────────▼────────────┐
                    │   Kubernetes Cluster   │
                    └────────────────────────┘
```

## Queue Configuration
- **default**: General purpose queue (weight: 1)
- **ml-training**: High-priority ML workloads (weight: 3)
- **hpc-batch**: HPC batch processing (weight: 2)
- **dev**: Development workloads (weight: 1)

## Deployment

### Enable Volcano
```bash
# In flag.tfvars
create = {
  volcano = true
}

# Deploy
terraform apply -target=module.volcano
```

### Configuration
```hcl
volcano_conf = {
  namespace = "volcano-system"
  queues = {
    ml-training = {
      weight = 3
      capability = {
        cpu    = "2000"
        memory = "2000Gi"
      }
      reclaimable = true
    }
  }
  plugins = ["gang", "priority", "conformance", "drf"]
  actions = ["enqueue", "allocate", "backfill"]
}
```

## Usage Examples

### ML Training Job
```yaml
apiVersion: batch.volcano.sh/v1alpha1
kind: Job
metadata:
  name: ml-training-job
spec:
  schedulerName: volcano
  queue: ml-training
  minAvailable: 3  # Gang scheduling
  tasks:
    - replicas: 1
      name: master
    - replicas: 2
      name: worker
```

### Spark + Volcano Integration
```yaml
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: spark-volcano-job
spec:
  batchScheduler: "volcano"
  batchSchedulerOptions:
    queue: "ml-training"
    priorityClassName: "high-priority"
```

## Testing
```bash
# Run comprehensive tests
./scripts/test-volcano-scheduling.sh

# Monitor jobs
kubectl get vcjobs -w
kubectl get queues
kubectl describe queue ml-training
```

## Integration with Spark Operator
Volcano integrates seamlessly with Spark Operator for distributed Spark workloads:
- Gang scheduling ensures all Spark executors start together
- Queue-based resource allocation prevents resource starvation
- Priority scheduling for critical ML training jobs

## Monitoring
- Queue status: `kubectl get queues`
- Job status: `kubectl get vcjobs`
- Resource allocation: `kubectl describe queues`
- Pod scheduling: `kubectl get pods -o wide`

## Best Practices
1. Use gang scheduling for distributed jobs requiring all pods
2. Configure appropriate queue weights based on workload priorities
3. Set resource limits to prevent queue starvation
4. Monitor queue utilization and adjust weights as needed
5. Use priority classes for critical workloads
