//======================================================================================================
//                                         Volcano Scheduler Module
//======================================================================================================

module "volcano" {
  count         = var.create.volcano ? 1 : 0
  source        = "../modules/kubernetes/volcano"
  region        = var.region
  cluster_name  = local.cluster_name
  enable_volcano = var.create.volcano
  volcano_conf  = var.eks_conf.kubernetes_conf.volcano_conf
}
