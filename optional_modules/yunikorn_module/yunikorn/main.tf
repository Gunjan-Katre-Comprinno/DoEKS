resource "kubernetes_namespace" "yunikorn_ns" {
  count = var.enable_yunikorn ? 1 : 0
  metadata {
    name = "yunikorn-system"
  }
}

resource "helm_release" "yunikorn" {
  count      = var.enable_yunikorn ? 1 : 0
  name       = "yunikorn"
  repository = "https://apache.github.io/yunikorn-release"
  chart      = "yunikorn"
  version    = "1.7.0"
  namespace  = kubernetes_namespace.yunikorn_ns[0].metadata[0].name

  values = [
    yamlencode({
      yunikornDefaults = {
        "service.volumeBindTimeout" = "60s"
        "service.placeholderImage" = "registry.k8s.io/pause:3.7"
        "service.operatorPlugins" = "general,spark-k8s-operator"
        "admissionController.filtering.bypassNamespaces" = "^kube-system$"
      }
    })
  ]

  depends_on = [kubernetes_namespace.yunikorn_ns]
}
