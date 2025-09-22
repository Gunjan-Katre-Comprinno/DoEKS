//=======================================================================================================
//                                  AWS KMS 
//=======================================================================================================
module "common_kms" {
  source      = "../modules/common_kms" // Path to the common KMS module
  kms_conf    = var.kms_conf            // Configuration settings for AWS Key Management Service (KMS)
  region      = var.region              // AWS region
  environment = var.environment         // Deployment environment
}
