resource "kubernetes_config_map" "spark_operator_config" {
  metadata {
    name      = "spark-operator-config"
    namespace = "spark-operator"
  }

  data = {
    "spark-conf.yaml" = <<EOF
    # Additional Spark Operator config if needed
    EOF
  }
}
