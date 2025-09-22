
//======================================================================================================
//                                         Prometheus
//======================================================================================================
// Deploys the Prometheus module
module "prometheus" {
  depends_on          = [module.ebs_csi, module.aws_loadbalancer_controller, module.metrics_server]
  count               = (var.create.prometheus == true) ? 1 : 0      // Conditional creation based on var.create.prometheus
  source              = "../modules/kubernetes/prometheus"           // Path to the Prometheus module
  prometheus_conf     = var.eks_conf.kubernetes_conf.prometheus_conf // Configuration settings for Prometheus
  cluster_name        = local.cluster_name                           // Name of the EKS cluster
  elb_certificate_arn = var.elb_certificate_arn                      // ARN of the ELB certificate
}
