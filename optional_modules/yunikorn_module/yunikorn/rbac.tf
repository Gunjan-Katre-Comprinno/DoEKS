resource "kubernetes_cluster_role" "yunikorn_scheduler" {
  metadata {
    name = "yunikorn-scheduler"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "pods", "persistentvolumes", "persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["scheduling.k8s.io"]
    resources  = ["priorityclasses"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["yunikorn.apache.org"]
    resources  = ["applications", "queues"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_cluster_role_binding" "yunikorn_scheduler" {
  metadata {
    name = "yunikorn-scheduler"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.yunikorn_scheduler.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "yunikorn-admin"
    namespace = kubernetes_namespace.yunikorn_ns[0].metadata[0].name
  }
}
