variable "enable_yunikorn" {
  description = "Enable YuniKorn scheduler"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "yunikorn_conf" {
  description = "YuniKorn configuration"
  type = object({
    namespace = string
    queues = object({
      root = object({
        submitacl = string
        queues = map(object({
          resources = object({
            guaranteed = map(string)
            max        = map(string)
          })
          submitacl = string
        }))
      })
    })
  })
}
