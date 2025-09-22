//======================================================================================================
//                                              Jaeger
//======================================================================================================
// Deploys the Jaeger module
module "jaeger" {
  count               = (var.create.jaeger == true) ? 1 : 0      // Conditional creation based on var.create.jaeger
  source              = "../modules/kubernetes/jaeger"           // Path to the Jaeger module
  jaeger_conf         = var.eks_conf.kubernetes_conf.jaeger_conf // Configuration settings for Jaeger
  cluster_name        = local.cluster_name                       // Name of the EKS cluster
  elb_certificate_arn = var.elb_certificate_arn                  // ARN of the ELB certificate
}