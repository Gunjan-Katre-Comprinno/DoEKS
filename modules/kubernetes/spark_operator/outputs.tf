output "spark_operator_sa_name" {
  value = kubernetes_service_account.spark_operator_sa.metadata[0].name
}

output "spark_operator_namespace" {
  value = kubernetes_namespace.spark_operator_ns.metadata[0].name
}
