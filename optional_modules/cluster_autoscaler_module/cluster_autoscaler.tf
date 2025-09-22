
//======================================================================================================
//                                   Auto-scaler
//======================================================================================================
// Deploys the Auto-scaler module
module "cluster_autoscaler" {
  count                   = (var.create.cluster_autoscaler == true) ? 1 : 0      // Conditional creation based on var.create.cluster_autoscaler
  source                  = "../modules/kubernetes/cluster_autoscaler"           // Path to the cluster autoscaler module
  cluster_name            = local.cluster_name                                   // Name of the EKS cluster
  cluster_autoscaler_conf = var.eks_conf.kubernetes_conf.cluster_autoscaler_conf // Configuration settings for cluster autoscaler
}

