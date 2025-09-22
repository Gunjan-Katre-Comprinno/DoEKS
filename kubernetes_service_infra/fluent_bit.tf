
//======================================================================================================
//                                 Fluentbit
//======================================================================================================
// Deploys Fluentbit for log collection in the Kubernetes cluster
module "fluentbit" {
  count          = (var.create.fluentbit == true) ? 1 : 0      // Conditional creation based on var.create.fluentbit
  source         = "../modules/kubernetes/fluentbit"           // Path to the Fluentbit module
  fluentbit_conf = var.eks_conf.kubernetes_conf.fluentbit_conf // Configuration settings for Fluentbit
  region         = var.region                                  // AWS region
  cluster_name   = local.cluster_name                          // Name of the Kubernetes cluster
}
