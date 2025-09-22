//======================================================================================================
//                                         CNI Metrics Helper
//======================================================================================================
// Deploys the CNI Metrics Helper module
module "cni_metrics_helper" {
  count                   = (var.create.cni_metrics_helper == true) ? 1 : 0      // Conditional creation based on var.create.cni_metrics_helper
  source                  = "../modules/kubernetes/cni_metrics_helper"           // Path to the CNI Metrics Helper module
  region                  = var.region                                           // AWS region
  cni_metrics_helper_conf = var.eks_conf.kubernetes_conf.cni_metrics_helper_conf // Configuration settings for CNI Metrics Helper
  cluster_name            = local.cluster_name                                   // Name of the EKS cluster
}