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
//                              Random String for Log Bucket Suffix
//=======================================================================================================
// This resource generates a random string to be used as part of the log bucket name suffix.
// - Generates a random string with specified length and minimum lower-case letters
// - Used for ensuring uniqueness in the log bucket name
resource "random_string" "random" {
  count     = var.vpc_conf.vpc.enable_s3_vpc_flow_logs ? 1 : 0
  length    = 5
  min_lower = 5
  special   = false
}


//=======================================================================================================
//                                  S3 Bucket for Logging
//=======================================================================================================
// This resource defines an S3 bucket to store VPC flow logs.
// - Creates an S3 bucket for storing VPC flow logs if enabled
// - Sets tags for identification and environment
resource "aws_s3_bucket" "flow_logs_bucket" {
  count = var.vpc_conf.vpc.enable_s3_vpc_flow_logs ? 1 : 0

  bucket = "${var.environment}-vpc-flow-logs-${random_string.random[0].result}"
  tags = merge({
    Name        = "${var.environment}-vpc-flow-logs-${random_string.random[0].result}"
    Environment = var.environment
  }, var.vpc_conf.vpc.additional_tags)
}


//=======================================================================================================
//                               Enable Versioning for Log Bucket
//=======================================================================================================
// This resource enables versioning for the log bucket to keep track of object versions.
// - Enables versioning for the log bucket if S3 flow logs are enabled
resource "aws_s3_bucket_versioning" "versioning_example" {
  count  = var.vpc_conf.vpc.enable_s3_vpc_flow_logs ? 1 : 0
  bucket = aws_s3_bucket.flow_logs_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}


//=======================================================================================================
//                                  VPC Flow Logs Configuration
//=======================================================================================================
// This resource configures VPC flow logs to send traffic data to a destination.
// - Configures VPC flow logs to send traffic data to either S3 bucket or CloudWatch Logs
// - Sets the IAM role and log destination based on configuration
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn         = var.vpc_conf.vpc.enable_s3_vpc_flow_logs ? null : aws_iam_role.vpc_flowlogs_role[0].arn
  log_destination      = var.vpc_conf.vpc.enable_s3_vpc_flow_logs ? aws_s3_bucket.flow_logs_bucket[0].arn : aws_cloudwatch_log_group.vpc_flowlogs_cw[0].arn
  log_destination_type = var.vpc_conf.vpc.enable_s3_vpc_flow_logs ? "s3" : "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id

  depends_on = [aws_vpc.vpc]
}


//=======================================================================================================
//                             CloudWatch Log Group for VPC Flow Logs
//=======================================================================================================
// This resource defines a CloudWatch log group to store VPC flow logs if S3 logging is not enabled.
// - Creates a CloudWatch log group for storing VPC flow logs if S3 logging is not enabled
// - Sets retention period and tags for identification and environment
resource "aws_cloudwatch_log_group" "vpc_flowlogs_cw" {
  count = var.vpc_conf.vpc.enable_s3_vpc_flow_logs ? 0 : 1

  name              = "/aws/${var.environment}-vpc/flowlogs"
  retention_in_days = 30
  skip_destroy      = false

  tags = merge({
    Name        = "/aws/${var.environment}-vpc/flowlogs"
    Environment = var.environment
  }, var.vpc_conf.vpc.additional_tags)
}



//=======================================================================================================
//                        IAM Policy Document for Assuming Role by VPC Flow Logs
//=======================================================================================================
// This data source defines an IAM policy document that allows VPC Flow Logs service to assume a role.
// - Allows the VPC Flow Logs service to assume a role for logging purposes
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

//=======================================================================================================
//                          IAM Role for VPC Flow Logs (if S3 logging is disabled)
//=======================================================================================================
// This resource defines an IAM role for VPC flow logs if S3 logging is disabled.
// - Creates an IAM role for VPC flow logs to grant permissions for logging to CloudWatch Logs
// - Sets tags for identification and environment
resource "aws_iam_role" "vpc_flowlogs_role" {
  count              = var.vpc_conf.vpc.enable_s3_vpc_flow_logs ? 0 : 1
  name               = "${var.environment}-vpc-flowlogs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge({
    Name        = "${var.environment}-vpc-flowlogs-role"
    Environment = var.environment
  }, var.vpc_conf.vpc.additional_tags)
}


//=======================================================================================================
//                       IAM Policy Document for VPC Flow Logs (if S3 logging is disabled)
//=======================================================================================================
// This data source defines an IAM policy document for VPC flow logs if S3 logging is disabled.
// - Defines permissions required for VPC flow logs to log to CloudWatch Logs
data "aws_iam_policy_document" "vpc_flowlogs_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["${aws_cloudwatch_log_group.vpc_flowlogs_cw[0].arn}:*"]
  }
}


//=======================================================================================================
//                        IAM Role Policy Attachment for VPC Flow Logs
//=======================================================================================================
// This resource attaches the IAM policy document to the IAM role for VPC flow logs.
// - Attaches the IAM policy document to the IAM role to grant required permissions
resource "aws_iam_role_policy" "vpc_flowlogs_policy_attachment" {
  name       = "${var.environment}-vpc-flowlogs-policy"
  role       = aws_iam_role.vpc_flowlogs_role[0].id
  policy     = data.aws_iam_policy_document.vpc_flowlogs_policy.json
  depends_on = [aws_iam_role.vpc_flowlogs_role, data.aws_iam_policy_document.vpc_flowlogs_policy]
}
