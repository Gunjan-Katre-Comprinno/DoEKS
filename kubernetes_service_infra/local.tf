
//======================================================================================================
//                                         Cluster Name
//======================================================================================================
// Defines the cluster name using environment and EKS cluster name
locals {
  cluster_name = "${var.environment}-${var.eks_conf.cluster.cluster_name}" // Combines environment and EKS cluster name
}
