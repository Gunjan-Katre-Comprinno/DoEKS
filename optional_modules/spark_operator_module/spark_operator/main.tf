resource "kubernetes_namespace" "spark_operator_ns" {
  metadata {
    name = "spark-operator"
  }
}

resource "kubernetes_service_account" "spark_operator_sa" {
  metadata {
    name      = "spark-operator-sa"
    namespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.spark_operator_irsa.arn
    }
  }
}

resource "helm_release" "spark_operator" {
  name       = "spark-operator"
  namespace  = kubernetes_namespace.spark_operator_ns.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"  # Recommended for consistency
  chart      = "spark-operator"
  version    = "1.7.0"
  values     = [file("${path.module}/values.yaml")]
}

resource "kubernetes_manifest" "spark_crds" {
  manifest = yamldecode(file("${path.module}/crds.yaml"))
}
