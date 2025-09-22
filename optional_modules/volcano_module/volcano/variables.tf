variable "enable_volcano" {
  description = "Enable Volcano scheduler deployment"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "volcano_conf" {
  description = "Volcano scheduler configuration"
  type = object({
    namespace = optional(string, "volcano-system")
    queues = optional(map(object({
      weight = optional(number, 1)
      capability = optional(object({
        cpu    = optional(string, "1000")
        memory = optional(string, "1000Gi")
      }), {})
      reclaimable = optional(bool, true)
    })), {})
    plugins = optional(list(string), ["gang", "priority", "conformance", "drf", "predicates", "proportion", "nodeorder"])
    actions = optional(list(string), ["enqueue", "allocate", "backfill"])
  })
  default = {
    namespace = "volcano-system"
    queues = {}
    plugins = ["gang", "priority", "conformance", "drf", "predicates", "proportion", "nodeorder"]
    actions = ["enqueue", "allocate", "backfill"]
  }
}
