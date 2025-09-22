resource "random_integer" "random" {
  min = 1
  max = 50000
}

resource "aws_s3_bucket" "configurations_bucket" {
  bucket        = "${var.environment}-code-configurations-${random_integer.random.result}"
  force_destroy = true
  tags = merge(
    {
      Name        = "${var.environment}-code-configurations-${random_integer.random.result}"
      Environment = var.environment

    },
    try(var.code_pipeline_conf.additional_tags, {})
  )
}

resource "aws_s3_bucket_versioning" "configurations_versioning" {
  bucket = aws_s3_bucket.configurations_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}