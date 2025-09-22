variable "cluster_name" {
  type        = string
}

variable "region" {
  type        = string
}

variable "enable_spark_operator" {
  type        = bool
  default     = false
}

variable "spark_operator_conf" {
  description = "Spark Operator Helm chart configuration"
  type        = any
}

variable "namespace" {
  description = "Namespace where the spark operator will be installed"
  type        = string
  default     = "spark-operator"
}
