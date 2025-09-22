data "local_file" "project" {
  filename = try("${path.module}/buildspec/${var.code_pipeline_conf.name}.yaml", "${path.module}/buildspec/default.yaml")
}

data "aws_codestarconnections_connection" "connection" {
  name = var.code_pipeline_conf.connection_name
}

data "aws_caller_identity" "current" {}
