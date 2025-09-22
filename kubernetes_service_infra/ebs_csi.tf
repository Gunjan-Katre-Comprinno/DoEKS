
//======================================================================================================
//                                 EBS CSI controller
//======================================================================================================
// Deploys the EBS CSI controller module
module "ebs_csi" {
  count        = (var.create.ebs_csi == true) ? 1 : 0      // Conditional creation based on var.create.ebs_csi
  source       = "../modules/kubernetes/ebs_csi"           // Path to the EBS CSI controller module
  region       = var.region                                // AWS region
  environment  = var.environment                           // Deployment environment
  cluster_name = local.cluster_name                        // Name of the EKS cluster
  ebs_csi_conf = var.eks_conf.kubernetes_conf.ebs_csi_conf // Configuration settings for EBS CSI controller
}
