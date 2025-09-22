output "code_pipeline_artifacts_bucket" {
  value = aws_s3_bucket.codepipeline_bucket.id
}

output "code_pipeline_configurations_bucket" {
  value = aws_s3_bucket.configurations_bucket.id
}