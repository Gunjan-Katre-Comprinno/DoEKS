//=======================================================================================================
//                                   Local Variables
//=======================================================================================================
locals {
  //-----------------------------------------------------------------------------------------------------
  // VPC ID
  // This variable holds the ID of the Virtual Private Cloud (VPC) to be used by the resources.
  // If `var.create.vpc` is true, it uses the VPC created by the module. Otherwise, it uses an existing VPC.
  //-----------------------------------------------------------------------------------------------------
  vpc_id = (var.create.vpc == true) ? module.vpc[0].vpc_id : module.vpc_existing[0].vpc_id

  //-----------------------------------------------------------------------------------------------------
  // Public Subnets
  // This variable contains a list of IDs of public subnets within the VPC.
  // If `var.create.vpc` is true, it refers to the public subnets created by the module.
  // Otherwise, it refers to the existing public subnets.
  //-----------------------------------------------------------------------------------------------------
  public_subnets = (var.create.vpc == true) ? module.vpc[0].public_subnets_ids : module.vpc_existing[0].public_subnets_ids

  //-----------------------------------------------------------------------------------------------------
  // Private Application Subnets
  // This variable contains a list of IDs of private subnets for application servers within the VPC.
  // If `var.create.vpc` is true, it refers to the private application subnets created by the module.
  // Otherwise, it refers to the existing private application subnets.
  //-----------------------------------------------------------------------------------------------------
  private_app_subnets = (var.create.vpc == true) ? module.vpc[0].private_app_subnets_ids : module.vpc_existing[0].private_app_subnets_ids

  //-----------------------------------------------------------------------------------------------------
  // Private Database Subnets
  // This variable contains a list of IDs of private subnets for database servers within the VPC.
  // If `var.create.vpc` is true, it refers to the private database subnets created by the module.
  // Otherwise, it refers to the existing private database subnets.
  //-----------------------------------------------------------------------------------------------------
  private_db_subnets = (var.create.vpc == true) ? module.vpc[0].private_db_subnets_ids : module.vpc_existing[0].db_private_subnets_ids
}