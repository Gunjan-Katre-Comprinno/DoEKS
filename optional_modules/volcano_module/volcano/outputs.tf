output "volcano_namespace" {
  description = "Volcano namespace"
  value       = var.enable_volcano ? kubernetes_namespace.volcano_ns[0].metadata[0].name : null
}

output "volcano_scheduler_name" {
  description = "Volcano scheduler name"
  value       = var.enable_volcano ? "volcano" : null
}

output "volcano_webhook_service" {
  description = "Volcano admission webhook service"
  value       = var.enable_volcano ? "volcano-admission-service.${kubernetes_namespace.volcano_ns[0].metadata[0].name}.svc.cluster.local" : null
}
