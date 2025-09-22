resource "aws_security_group" "project_security_group" {
  name        = "${var.environment}-${var.code_pipeline_conf.name}-project-security-group"
  description = "security group used for code build project ${var.environment}-${var.code_pipeline_conf.name}"
  vpc_id      = var.vpc_id

  # ingress rule is not required
  # Egress Rules
  egress {
    description = "all traffic"
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.code_pipeline_conf.name}-project-security-group"
      Environment = var.environment

    },
    try(var.code_pipeline_conf.additional_tags, {})
  )

}