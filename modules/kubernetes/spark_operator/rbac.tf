resource "kubernetes_service_account" "spark_driver" {
  metadata {
    name      = "spark-driver"
    namespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.spark_operator_role.arn
    }
  }
}

resource "kubernetes_cluster_role" "spark_driver_role" {
  metadata {
    name = "spark-driver-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "persistentvolumeclaims"]
    verbs      = ["create", "get", "list", "watch", "delete", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["create", "get", "list", "watch", "delete", "patch", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "spark_driver_binding" {
  metadata {
    name = "spark-driver-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.spark_driver_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.spark_driver.metadata[0].name
    namespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
  }
}

# Spark Operator Controller RBAC
resource "kubernetes_cluster_role" "spark_operator_controller" {
  metadata {
    name = "spark-operator-controller"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets", "events"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources  = ["sparkapplications", "scheduledsparkapplications"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }
}

resource "kubernetes_cluster_role_binding" "spark_operator_controller" {
  metadata {
    name = "spark-operator-controller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.spark_operator_controller.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "spark-operator-controller"
    namespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
  }
}

# Role for namespace-specific permissions
resource "kubernetes_role" "spark_operator_controller_role" {
  metadata {
    name      = "spark-operator-controller-role"
    namespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets", "events"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources  = ["sparkapplications", "scheduledsparkapplications"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "spark_operator_controller_binding" {
  metadata {
    name      = "spark-operator-controller-binding"
    namespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.spark_operator_controller_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "spark-operator-controller"
    namespace = kubernetes_namespace.spark_operator_ns.metadata[0].name
  }
}
