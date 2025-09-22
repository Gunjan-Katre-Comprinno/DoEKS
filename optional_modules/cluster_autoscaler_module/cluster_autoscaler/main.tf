# /**********************************************************************************
#  * Copyright 2023 Comprinno Technologies Pvt. Ltd.
#  *
#  * Comprinno Technologies Pvt. Ltd. owns all intellectual property rights in the software and associated
#  * documentation files (the "Software"). Permission is hereby granted, to any person
#  * obtaining a copy of this software, to use the Software only for internal use by
#  * the licensee. Transfer, distribution, and sale of copies of the Software or any
#  * derivative works based on the Software, are not permitted.
#  *
#  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#  * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#  * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#  **********************************************************************************/

resource "kubernetes_namespace" "cluster_autoscaler_namespace" {
  count = (var.cluster_autoscaler_conf.namespace != "kube-system" &&
  var.cluster_autoscaler_conf.namespace != "default") ? 1 : 0
  metadata {
    name = var.cluster_autoscaler_conf.namespace
    labels = {
      "name" = var.cluster_autoscaler_conf.namespace
    }
  }
}

resource "kubernetes_service_account" "autoscaler_account" {
  depends_on = [kubernetes_namespace.cluster_autoscaler_namespace[0]]
  metadata {
    name      = "cluster-autoscaler"
    namespace = var.cluster_autoscaler_conf.namespace
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app"   = "cluster-autoscaler"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler_role.arn
    }
  }
}

resource "kubernetes_cluster_role" "autoscaler_cluster_role" {
  depends_on = [kubernetes_service_account.autoscaler_account]
  metadata {
    name = "cluster-autoscaler"
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app"   = "cluster-autoscaler"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["events", "endpoints"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups     = [""]
    resources      = ["endpoints"]
    resource_names = ["cluster-autoscaler"]
    verbs          = ["get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list", "get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "services", "replicationcontrollers", "persistentvolumeclaims", "persistentvolumes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "replicasets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes", "csistoragecapacities", "csidrivers", "volumeattachments"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "patch"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }
  rule {
    api_groups     = ["coordination.k8s.io"]
    resource_names = ["cluster-autoscaler"]
    resources      = ["leases"]
    verbs          = ["get", "update"]
  }
}

resource "kubernetes_role" "autoscaler_role" {
  depends_on = [kubernetes_cluster_role.autoscaler_cluster_role]
  metadata {
    name      = "cluster-autoscaler"
    namespace = var.cluster_autoscaler_conf.namespace
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app"   = "cluster-autoscaler"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "list", "watch"]
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    verbs          = ["delete", "get", "update", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "autoscaler_cluster_role_binding" {
  depends_on = [kubernetes_role.autoscaler_role]
  metadata {
    name = "cluster-autoscaler"
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app"   = "cluster-autoscaler"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = var.cluster_autoscaler_conf.namespace
  }
}

resource "kubernetes_role_binding" "autoscaler_role_binding" {
  depends_on = [kubernetes_cluster_role_binding.autoscaler_cluster_role_binding]
  metadata {
    name      = "cluster-autoscaler"
    namespace = var.cluster_autoscaler_conf.namespace
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app"   = "cluster-autoscaler"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = var.cluster_autoscaler_conf.namespace
  }
}

resource "kubernetes_deployment" "autoscaler_deployment" {
  depends_on = [kubernetes_role_binding.autoscaler_role_binding]
  metadata {
    name      = "cluster-autoscaler"
    namespace = var.cluster_autoscaler_conf.namespace
    labels = {
      "app" = "cluster-autoscaler"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "cluster-autoscaler"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "cluster-autoscaler"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "8085"
        }
      }
      spec {
        priority_class_name  = "system-cluster-critical"
        service_account_name = "cluster-autoscaler"
        security_context {
          run_as_non_root = true
          run_as_user     = 65534
          fs_group        = 65534
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
        container {
          image = "registry.k8s.io/autoscaling/cluster-autoscaler:v1.32.1"
          name  = "cluster-autoscaler"
          env {
            name  = "AWS_STS_REGIONAL_ENDPOINTS"
            value = "regional"
          }
          image_pull_policy = "Always"
          resources {
            limits = {
              "cpu"    = "100m"
              "memory" = "600Mi"
            }
            requests = {
              "cpu"    = "100m"
              "memory" = "600Mi"
            }
          }
          command = [
            "./cluster-autoscaler",
            "--v=4", "--stderrthreshold=info",
            "--cloud-provider=aws",
            "--skip-nodes-with-local-storage=false",
            "--aws-use-static-instance-list=true",
            "--expander=least-waste",
            "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.cluster_name}",
            "--balance-similar-node-groups",
            "--skip-nodes-with-system-pods=false"
          ]
          volume_mount {
            name       = "ssl-certs"
            mount_path = "/etc/ssl/certs/ca-certificates.crt"
            read_only  = true
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }
        }
        volume {
          name = "ssl-certs"
          host_path {
            path = "/etc/ssl/certs/ca-bundle.crt"
          }
        }
      }
    }
  }
}
