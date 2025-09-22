//======================================================================================================
//                                         YuniKorn Scheduler Module
//======================================================================================================

module "yunikorn" {
  count         = var.create.yunikorn ? 1 : 0
  source        = "../modules/kubernetes/yunikorn"
  enable_yunikorn = var.create.yunikorn
  cluster_name  = var.eks_conf.cluster.cluster_name
  region        = var.region
  yunikorn_conf = var.eks_conf.kubernetes_conf.yunikorn_conf
}
