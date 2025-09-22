#!/bin/bash

# Fix Spark Operator RBAC Issues
# This script addresses RBAC problems in existing deployments

echo "=== Fixing Spark Operator RBAC Issues ==="

# 1. Update ClusterRole with Spark CRDs permissions
echo "1. Updating ClusterRole permissions..."
kubectl patch clusterrole spark-operator-controller --type='json' -p='[
  {
    "op": "add",
    "path": "/rules/-",
    "value": {
      "apiGroups": ["sparkoperator.k8s.io"],
      "resources": ["sparkapplications", "scheduledsparkapplications"],
      "verbs": ["create", "get", "list", "watch", "update", "patch", "delete"]
    }
  }
]' 2>/dev/null || echo "ClusterRole already has Spark permissions"

# 2. Create Role in spark-operator namespace
echo "2. Creating namespace Role..."
kubectl create role spark-operator-controller-role -n spark-operator \
  --verb=get,list,watch,create,update,patch,delete \
  --resource=pods,sparkapplications,scheduledsparkapplications,events,services,configmaps,secrets \
  2>/dev/null || echo "Role already exists"

# 3. Create RoleBinding
echo "3. Creating RoleBinding..."
kubectl create rolebinding spark-operator-controller-binding -n spark-operator \
  --role=spark-operator-controller-role \
  --serviceaccount=spark-operator:spark-operator-controller \
  2>/dev/null || echo "RoleBinding already exists"

# 4. Update controller to watch spark-operator namespace
echo "4. Updating controller namespace configuration..."
kubectl patch deployment spark-operator-controller -n spark-operator --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/args",
    "value": [
      "controller",
      "start",
      "--zap-log-level=info",
      "--zap-encoder=console",
      "--namespaces=spark-operator",
      "--controller-threads=10",
      "--enable-ui-service=true",
      "--enable-metrics=true",
      "--metrics-bind-address=:8080",
      "--leader-election=true",
      "--leader-election-lock-name=spark-operator-controller-lock",
      "--leader-election-lock-namespace=spark-operator"
    ]
  }
]'

# 5. Wait for deployment rollout
echo "5. Waiting for controller restart..."
kubectl rollout status deployment spark-operator-controller -n spark-operator

echo "=== RBAC Fix Complete ==="
echo "You can now submit Spark jobs to the spark-operator namespace"
echo "Test with: kubectl apply -f examples/spark-jobs/pyspark-example.yaml"
