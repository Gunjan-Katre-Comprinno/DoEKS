

//=======================================================================================================
//                                 AWS S3
//=======================================================================================================

module "s3" {
  source             = "./s3"
  environment        = var.environment
  aws_s3_kms_key     = var.aws_s3_kms_key
  code_pipeline_conf = var.code_pipeline_conf
}


//=======================================================================================================
//                                 AWS Codebuild
//=======================================================================================================

module "build" {
  for_each              = var.code_pipeline_conf.pipelines
  depends_on            = [module.s3]
  source                = "./build"
  environment           = var.environment
  region                = var.region
  code_pipeline_conf    = each.value
  vpc_id                = var.vpc_id
  subnets               = var.subnets
  aws_s3_kms_key        = var.aws_s3_kms_key
  configurations_bucket = module.s3.code_pipeline_configurations_bucket

}

//=======================================================================================================
//                                 AWS Codepipeline/s
//=======================================================================================================

module "pipeline" {
  for_each           = var.code_pipeline_conf.pipelines
  depends_on         = [module.build, module.s3]
  source             = "./pipeline"
  environment        = var.environment
  region             = var.region
  code_pipeline_conf = each.value
  project_name       = module.build[each.key].project_name
  aws_s3_kms_key     = var.aws_s3_kms_key
  artifacts_bucket   = module.s3.code_pipeline_artifacts_bucket
}
