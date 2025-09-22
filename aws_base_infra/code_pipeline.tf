
//=======================================================================================================
//                                 AWS Codepipeline
//=======================================================================================================
module "codepipeline" {
  count              = (var.create.codepipeline == true) ? 1 : 0 // Conditional creation based on var.create.codepipeline
  source             = "../modules/code_pipeline"                // Path to the CodePipeline module
  environment        = var.environment                           // Deployment environment
  region             = var.region                                // AWS region
  code_pipeline_conf = var.code_pipeline_conf                    // Configuration settings for CodePipeline
  vpc_id             = local.vpc_id                              // ID of the VPC
  subnets            = local.private_app_subnets                 // Subnets for CodePipeline
  aws_s3_kms_key     = module.common_kms.s3_cmk_arn              // ARN of the KMS key used for S3 encryption
}
