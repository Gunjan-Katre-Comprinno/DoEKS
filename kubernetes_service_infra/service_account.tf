
//======================================================================================================
//                                         Service Account
//======================================================================================================
// Deploys the Kubernetes Service Account module
module "service_account" {
  count                = (var.create.service_account == true) ? 1 : 0      // Conditional creation based on var.create.service_account
  source               = "../modules/kubernetes/service_account"           // Path to the Service Account module
  cluster_name         = local.cluster_name                                // Name of the EKS cluster
  service_account_conf = var.eks_conf.kubernetes_conf.service_account_conf // Configuration settings for the Service Account
}
