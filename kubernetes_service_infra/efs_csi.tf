
//======================================================================================================
//                                 EFS CSI controller
//======================================================================================================
// Deploys the EFS CSI controller module
module "efs_csi" {
  count        = (var.create.efs == true && var.create.efs_csi == true) ? 1 : 0 // Conditionally create the module based on configuration
  source       = "../modules/kubernetes/efs_csi"                                // Path to the EFS CSI controller module
  region       = var.region                                                     // AWS region where the resources will be deployed
  environment  = var.environment                                                // Deployment environment
  cluster_name = local.cluster_name                                             // Name of the EKS cluster
  efs_csi_conf = var.eks_conf.kubernetes_conf.efs_csi_conf                      // Configuration settings for the EFS CSI controller
  efs_conf     = var.efs_conf                                                   // Configuration settings for EFS
}
