//======================================================================================================
//                                         Spark Operator Module
//======================================================================================================

module "spark_operator" {
  count               = var.create.spark_operator ? 1 : 0
  source              = "../modules/kubernetes/spark_operator"
  enable_spark_operator = var.create.spark_operator
  cluster_name        = var.eks_conf.cluster.cluster_name
  region              = var.region
  spark_operator_conf = var.eks_conf.kubernetes_conf.spark_operator_conf
  namespace          = var.eks_conf.kubernetes_conf.spark_operator_conf.sparkJobNamespace

}
