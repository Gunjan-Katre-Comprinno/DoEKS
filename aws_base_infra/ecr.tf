
//=======================================================================================================
//                                 AWS Elastic Container Repository/es
//=======================================================================================================
module "ecr" {
  count               = (var.create.ecr == true) ? 1 : 0 // Conditional creation based on var.create.ecr
  source              = "../modules/ecr"                 // Path to the ECR module
  region              = var.region                       // AWS region  
  environment         = var.environment                  // Deployment environment
  ecr_repository_conf = var.ecr_repository_conf          // Configuration settings for ECR repositories
}
