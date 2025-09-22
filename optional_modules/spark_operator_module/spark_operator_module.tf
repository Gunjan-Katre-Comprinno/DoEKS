//======================================================================================================
//                                         Spark Operator Module
//======================================================================================================

module "spark_operator" {
  count                = var.create.spark_operator ? 1 : 0
  source               = "./optional_modules/spark_operator_module/spark_operator"
  region                  = var.region
  cluster_name          = local.cluster_name
  enable_spark_operator = var.create.spark_operator
  spark_operator_conf      = var.eks_conf.kubernetes_conf.spark_operator_conf
}
