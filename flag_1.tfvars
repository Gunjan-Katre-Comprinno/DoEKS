create = {
  # aws_base_infra flags
  vpc             = true
  eks_cluster     = true
  parameter_store = true
  ecr             = true
  codepipeline    = false
  efs             = true

  # kubernetes_service_infra flags
  service_account             = false
  cluster_autoscaler          = false
  aws_loadbalancer_controller = false
  metrics_server              = true
  ebs_csi                     = true
  efs_csi                     = true
  prometheus                  = false
  grafana                     = false
  fluentbit                   = false
  argocd                      = false

  # Optional flags
  karpenter            = false
  container_insight    = false
  jaeger               = false
  calico               = false
  cni_metrics_helper   = false
  kubernetes_dashboard = false
  container_insight    = false
}
