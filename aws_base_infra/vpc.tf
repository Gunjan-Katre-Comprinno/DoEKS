
//=======================================================================================================
//                                   VPC and related resources
//=======================================================================================================
module "vpc" {
  count        = (var.create.vpc == true) ? 1 : 0  // Conditional creation based on var.create.vpc
  source       = "../modules/vpc"                  // Path to the VPC module
  region       = var.region                        // AWS region
  environment  = var.environment                   // Deployment environment
  vpc_conf     = var.vpc_conf                      // VPC configuration
  cluster_name = var.eks_conf.cluster.cluster_name // Name of the EKS cluster
}

//=======================================================================================================
//                                  Existing VPC and related resources
//=======================================================================================================
module "vpc_existing" {
  count        = (var.create.vpc == false) ? 1 : 0 // Conditional creation based on var.create.vpc
  source       = "../modules/vpc_existing"         // Path to the existing VPC module
  vpc_conf     = var.vpc_conf                      // VPC configuration
  cluster_name = var.eks_conf.cluster.cluster_name // Name of the EKS cluster
  environment  = var.environment                   // Deployment environment
}
