create = {
  # aws_base_infra flags
  vpc             = true
  eks_cluster     = true
  parameter_store = false
  ecr             = false
  codepipeline    = false
  efs             = false

  # kubernetes_service_infra flags
  service_account             = true
  cluster_autoscaler          = true
  aws_loadbalancer_controller = true
  metrics_server              = true
  ebs_csi                     = true
  efs_csi                     = false
  prometheus                  = false
  grafana                     = false
  fluentbit                   = false
  argocd                      = false

  # Optional flags
  karpenter            = false
  container_insight    = false
  jaeger               = false
  calico               = true
  cni_metrics_helper   = false
  kubernetes_dashboard = false
  container_insight    = false
}
