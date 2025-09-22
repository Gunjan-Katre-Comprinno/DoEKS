
resource "aws_ssm_parameter" "parameters" {
  for_each    = var.parameters_conf
  name        = upper("/${var.environment}${each.value.name}")
  description = each.value.description
  type        = each.value.type #"String"
  value       = each.value.value
  tags = {
    Name        = upper("/${var.environment}${each.value.name}")
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}