
//====================================================================================================== 
//                                         Karpenter
//======================================================================================================
// Deploys the Karpenter module
module "karpenter" {
  count           = (var.create.karpenter == true) ? 1 : 0                        // Conditionally creates the module based on specified variables
  source          = "../modules/kubernetes/karpenter"                             // Path to the Karpenter module source code
  karpenter_conf  = var.eks_conf.kubernetes_conf.karpenter_conf                   // Configuration settings for Karpenter
  environment     = var.environment                                               // Deployment environment
  cluster_name    = local.cluster_name                                            // Name of the Kubernetes cluster
  region          = var.region                                                    // AWS region
  node_group_name = "${local.cluster_name}-${var.node_groups_conf.ondemand.name}" // Name of the node group
}