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

//=======================================================================================================
//                                 Codebuild Service IAM Role 
//=======================================================================================================
resource "aws_iam_role" "codebuild_service_role" {
  name = "${var.environment}-${var.code_pipeline_conf.name}-project-role"
  tags = merge(
    {
      Name        = "${var.environment}-${var.code_pipeline_conf.name}-project-role"
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
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "codebuild_service_policy_document" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*:*"
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "ec2:CreateNetworkInterfacePermission",
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values   = [for id in var.subnets : "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
    effect = "Allow"
  }
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.current.account_id}:report-group/*",
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.environment}-code-pipeline-artifacts",
      "arn:aws:s3:::${var.environment}-code-pipeline-artifacts/*",
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.codebuild_service_role.arn
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:GetParameter",
      "ssm:DescribeParameters"
    ]
    resources = [
      aws_iam_role.codebuild_service_role.arn
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
      var.aws_s3_kms_key
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
}

//=======================================================================================================
//                                 Codebuild Service IAM Policy
//=======================================================================================================
resource "aws_iam_role_policy" "codebuild_service_policy" {
  name   = "${var.environment}-${var.code_pipeline_conf.name}-project-service-policy"
  role   = aws_iam_role.codebuild_service_role.id
  policy = data.aws_iam_policy_document.codebuild_service_policy_document.json
}

resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}