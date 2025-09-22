//======================================================================================================
//                                         ArgoCD
//======================================================================================================
// Deploys the ArgoCD module
module "argocd" {
  depends_on          = [module.aws_loadbalancer_controller]
  count               = (var.create.argocd == true) ? 1 : 0      // Conditional creation based on var.create.argocd
  source              = "../modules/kubernetes/argocd"           // Path to the ArgoCD module
  argocd_conf         = var.eks_conf.kubernetes_conf.argocd_conf // Configuration settings for ArgoCD
  cluster_name        = local.cluster_name                       // Name of the EKS cluster
  elb_certificate_arn = var.elb_certificate_arn                  // ARN of the ELB certificate
}
