variable "cluster_name" {
  type        = string
}

variable "region" {
  type        = string
}

variable "enable_spark_operator" {
  type        = bool
}

variable "spark_operator_conf" {
  type = object({
    image_repository = string
    image_tag        = string
  })
}
