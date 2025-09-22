/**********************************************************************************
 * Copyright 2023 Comprinno Technologies Pvt. Ltd.
 *
 * Comprinno Technologies Pvt. Ltd. owns all intellectual property rights in the software and associated
 * documentation files (the "Software"). Permission is hereby granted, to any person
 * obtaining a copy of this software, to use the Software only for internal use by
 * the licensee. Transfer, distribution, and sale of copies of the Software or any
 * derivative works based on the Software, are not permitted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **********************************************************************************/



resource "aws_codebuild_project" "project" {
  depends_on    = [aws_iam_role.codebuild_service_role, aws_security_group.project_security_group]
  name          = "${var.environment}-${var.code_pipeline_conf.name}-project"
  description   = "${var.environment}-${var.code_pipeline_conf.name}-project build app"
  build_timeout = try(var.code_pipeline_conf.build_timeout, "30")
  service_role  = aws_iam_role.codebuild_service_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = try(var.code_pipeline_conf.compute_type, "BUILD_GENERAL1_SMALL")
    image                       = try(var.code_pipeline_conf.image, "aws/codebuild/amazonlinux2-aarch64-standard:3.0")
    type                        = try(var.code_pipeline_conf.type, "ARM_CONTAINER")
    privileged_mode             = try(var.code_pipeline_conf.privileged_mode, true)
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "${var.environment}-${var.code_pipeline_conf.name}-project-logs"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.local_file.project.content
  }
  secondary_sources {
    source_identifier = "S3_CONFIGURATIONS"
    type              = "S3"
    location          = "${var.configurations_bucket}/"
  }

  vpc_config {
    vpc_id = var.vpc_id

    subnets = var.subnets

    security_group_ids = [aws_security_group.project_security_group.id]
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.code_pipeline_conf.name}-project"
      Environment = var.environment

    },
    try(var.code_pipeline_conf.additional_tags, {})
  )
}