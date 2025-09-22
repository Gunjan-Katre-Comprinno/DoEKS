
//======================================================================================================
//                                  AWS Load Balancer Controller
//======================================================================================================
// Deploys the AWS Load Balancer Controller module
module "aws_loadbalancer_controller" {
  count                        = (var.create.aws_loadbalancer_controller == true) ? 1 : 0      // Conditional creation based on var.create.aws_loadbalancer_controller
  source                       = "../modules/kubernetes/aws_loadbalancer_controller"           // Path to the Load Balancer Controller module
  environment                  = var.environment                                               // Deployment environment
  cluster_name                 = local.cluster_name                                            // Name of the EKS cluster
  region                       = var.region                                                    // AWS region
  loadbalancer_controller_conf = var.eks_conf.kubernetes_conf.aws_loadbalancer_controller_conf // Configuration settings for Load Balancer Controller
}
