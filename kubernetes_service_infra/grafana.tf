
//======================================================================================================
//                                 Grafana
//======================================================================================================
// Deploys Grafana for Kubernetes cluster monitoring
module "grafana" {
  depends_on           = [module.ebs_csi, module.aws_loadbalancer_controller, module.prometheus]
  count                = (var.create.grafana == true) ? 1 : 0                   // Conditional creation based on var.create.grafana
  source               = "../modules/kubernetes/grafana"                        // Path to the Grafana module
  grafana_conf         = var.eks_conf.kubernetes_conf.grafana_conf              // Configuration settings for Grafana
  cluster_name         = local.cluster_name                                     // Name of the EKS cluster
  elb_certificate_arn  = var.elb_certificate_arn                                // ARN of the ELB certificate
  prometheus_namespace = var.eks_conf.kubernetes_conf.prometheus_conf.namespace // Namespace for Prometheus
}
