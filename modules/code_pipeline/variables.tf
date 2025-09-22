variable "region" {
  description = "AWS region to deploy the resources in"
}

variable "environment" {
  description = "Environment tag to be used. Ex: dev/qa/production"
}

variable "vpc_id" {
  description = "ID of the VPC in which AWS Code build will be created"

}

variable "subnets" {
  description = "Aws subnets in which build is created"
}

variable "aws_s3_kms_key" {
  description = "Kms key used for s3 data encryption"
}

variable "code_pipeline_conf" {
  description = "All pipeline related configuration"
}