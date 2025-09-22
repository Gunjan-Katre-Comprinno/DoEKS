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

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.environment}-${var.code_pipeline_conf.name}-pipeline-role"
  tags = merge(
    {
      Name        = "${var.environment}-${var.code_pipeline_conf.name}-pipeline-role"
      Environment = var.environment
    },
    try(var.code_pipeline_conf.additional_tags, {})
  )
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "codepipeline_service_policy_document" {
  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${var.artifacts_bucket}",
      "arn:aws:s3:::${var.artifacts_bucket}/*"
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.current.account_id}:project/*",
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = [
      data.aws_codestarconnections_connection.connection.arn
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]
    resources = [
      #var.parameter_store_cmk_arn
      var.aws_s3_kms_key
    ]
    effect = "Allow"
  }

}

## IAM Role Policy
resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.environment}-${var.code_pipeline_conf.name}-pipeline-policy"
  role   = aws_iam_role.codepipeline_role.name
  policy = data.aws_iam_policy_document.codepipeline_service_policy_document.json
}