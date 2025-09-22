
//=======================================================================================================
//                                 AWS Elastic File System
//=======================================================================================================
module "efs" {
  depends_on  = [module.vpc]                     // Depend on the VPC module to ensure its resources are created first
  count       = (var.create.efs == true) ? 1 : 0 // Conditional creation based on var.create.efs
  source      = "../modules/efs"                 // Path to the EFS module
  region      = var.region                       // AWS region
  environment = var.environment                  // Deployment environment
  vpc_id      = local.vpc_id                     // ID of the VPC
  db_subnets  = local.private_db_subnets         // Private subnets for database servers
  efs_conf    = var.efs_conf                     // Configuration settings for AWS Elastic File System (EFS)
}
