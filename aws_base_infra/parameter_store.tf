//=======================================================================================================
//                                 AWS Parameter Store
//=======================================================================================================
module "parameter_store" {
  count           = (var.create.parameter_store == true) ? 1 : 0 // Conditional creation based on var.create.parameter_store
  source          = "../modules/parameter_store"                 // Path to the Parameter Store module
  environment     = var.environment                              // Deployment environment
  parameters_conf = var.parameters_conf                          // Parameter Store configurations

}