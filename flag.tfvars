create = {
  # aws_base_infra flags
  vpc             = true
  eks_cluster     = true
  parameter_store = false
  ecr             = false
  codepipeline    = false
  efs             = true

  # kubernetes_service_infra flags
  service_account             = true
  cluster_autoscaler          = true
  aws_loadbalancer_controller = true
  metrics_server              = true
  ebs_csi                     = true
  efs_csi                     = true
  prometheus                  = true
  grafana                     = true
  fluentbit                   = true
  argocd                      = false

  # Optional flags
  karpenter            = true
  container_insight    = false
  jaeger               = false
  calico               = false
  cni_metrics_helper   = false
  kubernetes_dashboard = false
  spark_operator       = true
  yunikorn            = true
  volcano             = true
}
