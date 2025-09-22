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
//                                       AWS EKS Cluster                         
//=======================================================================================================
module "eks" {
  depends_on = [aws_iam_role.eks_cluster_role, aws_iam_role.eks_node_role]
  source     = "terraform-aws-modules/eks/aws"
  # Determines module version
  version = "~> 19.0"
  # Determines kubernetes cluster version
  cluster_version = var.eks_conf.cluster.eks_kubernetes_version
  # Determines whether a an IAM role is created by the eks module or to use an existing IAM role
  create_iam_role = var.eks_conf.cluster.create_iam_role
  # set iam_role_arn only when create_iam_role is set to false
  iam_role_arn                   = aws_iam_role.eks_cluster_role.arn
  cluster_name                   = "${var.environment}-${var.eks_conf.cluster.cluster_name}"
  cluster_endpoint_public_access = var.eks_conf.cluster.cluster_endpoint_public_access
  cluster_enabled_log_types      = var.eks_conf.cluster.cluster_enabled_log_types
  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = aws_kms_key.eks_key.arn
  }

  vpc_id                               = var.vpc_id
  subnet_ids                           = var.private_subnets
  cluster_service_ipv4_cidr            = var.eks_conf.cluster.cluster_service_ipv4_cidr
  cluster_endpoint_public_access_cidrs = var.eks_conf.cluster.cluster_endpoint_public_access_cidrs #The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks

  tags = merge(
    {
      Name                     = "${var.environment}-${var.eks_conf.cluster.cluster_name}"
      Environment              = var.environment
      "karpenter.sh/discovery" = "${var.environment}-${var.eks_conf.cluster.cluster_name}"
    },
    try(var.eks_conf.cluster.additional_tags, {})
  )
  cluster_security_group_use_name_prefix = false
  cluster_security_group_name            = "${var.environment}-${var.eks_conf.cluster.cluster_name}-cluster-security-group"
  cluster_security_group_tags = merge(
    {
      Name        = "${var.environment}-${var.eks_conf.cluster.cluster_name}-cluster-additional-security-group"
      Environment = var.environment
    },
    try(var.eks_conf.cluster.additional_tags, {})
  )
}

//=======================================================================================================
//                                      EKS managed Node groups (Dynamic)                        
//=======================================================================================================
module "eks_managed_node_groups" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "19.21.0"

  for_each = var.node_groups_conf

  name                              = "${var.environment}-${var.eks_conf.cluster.cluster_name}-${each.value.name}"
  use_name_prefix                   = false
  capacity_type                     = upper(each.value.capacity_type)
  cluster_name                      = "${var.environment}-${var.eks_conf.cluster.cluster_name}"
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  create_iam_role                   = false
  iam_role_arn                      = aws_iam_role.eks_node_role.arn
  create_launch_template            = false
  launch_template_id                = aws_launch_template.node_group_lt[each.key].id
  desired_size                      = each.value.desired_capacity
  min_size                          = each.value.min_capacity
  max_size                          = each.value.max_capacity
  instance_types                    = each.value.instance_types
  subnet_ids                        = var.private_subnets

  update_config = {
    max_unavailable_percentage = try(each.value.update_config.max_unavailable_percentage, 33)
  }

  labels = try(each.value.labels, null)
  taints = try(each.value.taints, {})

  tags = merge(
    {
      Name        = "${var.environment}-${var.eks_conf.cluster.cluster_name}-${each.value.name}"
      Environment = var.environment
    },
    try(each.value.additional_tags, {})
  )
}
 