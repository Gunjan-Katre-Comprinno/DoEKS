resource "kubernetes_namespace" "volcano_ns" {
  count = var.enable_volcano ? 1 : 0
  metadata {
    name = "volcano-system"
  }
}

resource "helm_release" "volcano" {
  count      = var.enable_volcano ? 1 : 0
  name       = "volcano"
  repository = "https://volcano-sh.github.io/helm-charts"
  chart      = "volcano"
  version    = "1.12.2"
  namespace  = kubernetes_namespace.volcano_ns[0].metadata[0].name

  values = [
    yamlencode({
      basic = {
        image_tag_version = "v1.12.2"
        scheduler_config_file = "config/volcano-scheduler.conf"
      }
      custom = {
        scheduler_config = templatefile("${path.module}/scheduler-config.yaml", var.volcano_conf)
        metrics_enable = true
        admission_enable = true
      }
      scheduler = {
        image = {
          repository = "volcanosh/vc-scheduler"
          tag = "v1.9.0"
        }
        replicas = 1
        resources = {
          limits = {
            cpu = "200m"
            memory = "200Mi"
          }
          requests = {
            cpu = "100m"
            memory = "100Mi"
          }
        }
      }
      controller = {
        image = {
          repository = "volcanosh/vc-controller-manager"
          tag = "v1.9.0"
        }
        replicas = 1
      }
      admission = {
        image = {
          repository = "volcanosh/vc-webhook-manager"
          tag = "v1.9.0"
        }
        replicas = 1
      }
    })
  ]

  depends_on = [kubernetes_namespace.volcano_ns]
}
