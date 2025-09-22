
//======================================================================================================
//                                         Container Insight
//======================================================================================================
// Deploys the Container Insight module
module "container_insight" {
  count                  = (var.create.container_insight == true) ? 1 : 0      // Conditional creation based on var.create.container_insight
  source                 = "../modules/kubernetes/container_insights"          // Path to the Container Insights module
  region                 = var.region                                          // AWS region
  cluster_name           = local.cluster_name                                  // Name of the EKS cluster
  container_insight_conf = var.eks_conf.kubernetes_conf.container_insight_conf // Configuration settings for Container Insight
}
