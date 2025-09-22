output "yunikorn_namespace" {
  description = "YuniKorn namespace"
  value       = var.enable_yunikorn ? kubernetes_namespace.yunikorn_ns[0].metadata[0].name : null
}

output "yunikorn_service_url" {
  description = "YuniKorn scheduler service URL"
  value       = var.enable_yunikorn ? "http://yunikorn-service.${kubernetes_namespace.yunikorn_ns[0].metadata[0].name}.svc.cluster.local:9080" : null
}
