
//======================================================================================================
//                                         Kubernetes Dashboard
//======================================================================================================
// Deploys the Kubernetes Dashboard module
module "kubernetes_dashboard" {
  depends_on                = [module.aws_loadbalancer_controller]
  count                     = (var.create.kubernetes_dashboard == true) ? 1 : 0      // Conditional creation based on var.create.kubernetes_dashboard
  source                    = "../modules/kubernetes/kubernetes_dashboard"           // Path to the Kubernetes Dashboard module
  kubernetes_dashboard_conf = var.eks_conf.kubernetes_conf.kubernetes_dashboard_conf // Configuration settings for Kubernetes Dashboard
  cluster_name              = local.cluster_name                                     // Name of the EKS cluster
  elb_certificate_arn       = var.elb_certificate_arn                                // ARN of the ELB certificate
}