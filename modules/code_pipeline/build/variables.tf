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
variable "region" {
  description = "AWS region to create CodeBuild project in"
}

variable "environment" {
  description = "Environment tag to be used. Ex: dev/qa/production"
}

variable "code_pipeline_conf" {
  description = "Configuration related to AWS code pipeline, output artifacts, source and build process realated variable details"
}

variable "vpc_id" {
  description = "VPC ID of the VPC where Codebuild instance will be deployed"
}

variable "subnets" {
  description = "List of Subnet IDs where Codebuild instance will be deployed"
}

variable "aws_s3_kms_key" {
  description = "CMK key arn used to encrypt the pipeline s3 bucket"
}

variable "configurations_bucket" {
  description = "configurations bucket id"
}