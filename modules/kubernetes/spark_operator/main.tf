resource "kubernetes_namespace" "spark_operator_ns" {
  metadata {
    name = "spark-operator"
  }
}

resource "kubernetes_service_account" "spark_operator_sa" {
  metadata {
    name      = var.spark_operator_conf.serviceAccount.name
    namespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.spark_operator_role.arn
    }
  }
}

resource "helm_release" "spark_operator" {
  name       = "spark-operator"
  namespace  = kubernetes_namespace.spark_operator_ns.metadata[0].name

  repository = "https://kubeflow.github.io/spark-operator"
  chart      = "spark-operator"
  version    = "2.3.0"

  values = [
    yamlencode({
      image = {
        registry   = "docker.io"
        repository = "kubeflow/spark-operator"
        tag        = "2.1.1"
      }
      metrics = {
        enabled = true
      }
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.spark_operator_sa.metadata[0].name
      }
      controllerThreads = 10
      resyncInterval = 30
      sparkJobNamespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
      enableWebhook = true
      webhookPort = 9443
      leaderElection = {
        lockName = "spark-operator-controller-lock"
        lockNamespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
      }
      controller = {
        args = [
          "controller",
          "start",
          "--zap-log-level=info",
          "--zap-encoder=console",
          "--namespaces=${kubernetes_namespace.spark_operator_ns.metadata[0].name}",
          "--controller-threads=10",
          "--enable-ui-service=true",
          "--enable-metrics=true",
          "--metrics-bind-address=:8080",
          "--leader-election=true",
          "--leader-election-lock-name=spark-operator-controller-lock",
          "--leader-election-lock-namespace=${kubernetes_namespace.spark_operator_ns.metadata[0].name}"
        ]
      }
    })
  ]

  depends_on = [
    kubernetes_service_account.spark_operator_sa,
    kubernetes_cluster_role.spark_operator_controller,
    kubernetes_cluster_role_binding.spark_operator_controller,
    kubernetes_role.spark_operator_controller_role,
    kubernetes_role_binding.spark_operator_controller_binding
  ]
}
