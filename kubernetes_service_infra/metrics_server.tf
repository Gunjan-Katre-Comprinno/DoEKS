
//======================================================================================================
//                                 Metrics Server
//======================================================================================================
// Deploys the Metrics Server module
module "metrics_server" {
  count               = (var.create.metrics_server == true) ? 1 : 0      // Conditional creation based on var.create.metrics_server
  source              = "../modules/kubernetes/metrics_server"           // Path to the Metrics Server module
  metrics_server_conf = var.eks_conf.kubernetes_conf.metrics_server_conf // Configuration settings for Metrics Server
}
