//======================================================================================================
//                                 Calico
//======================================================================================================
// Deploys the Calico module for Kubernetes networking
module "calico" {
  count        = (var.create.calico == true) ? 1 : 0      // Conditional creation based on var.create.calico
  source       = "../modules/kubernetes/calico"           // Path to the Calico module
  calico_conf  = var.eks_conf.kubernetes_conf.calico_conf // Configuration settings for Calico
  region       = var.region                               // AWS region
  cluster_name = local.cluster_name                       // Name of the EKS cluster
}
