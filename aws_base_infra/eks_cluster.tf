
//=======================================================================================================
//                                 AWS EKS Cluster and Nodegroups
//=======================================================================================================
module "eks_cluster" {
  count            = (var.create.eks_cluster == true) ? 1 : 0 // Conditional creation based on var.create.eks
  source           = "../modules/eks"                         // Path to the EKS module
  region           = var.region                               // AWS region
  vpc_conf         = var.vpc_conf                             // VPC configuration
  eks_conf         = var.eks_conf                             // EKS cluster configuration
  create           = var.create                               // Flag to control creation
  environment      = var.environment                          // Deployment environment
  vpc_id           = local.vpc_id                             // ID of the VPC
  private_subnets  = local.private_app_subnets                // Private subnets for application servers
  node_groups_conf = var.node_groups_conf                     // Node groups configuration
}
