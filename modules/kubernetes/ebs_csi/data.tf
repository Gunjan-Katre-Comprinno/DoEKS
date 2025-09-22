//=======================================================================================================
//                               Data calls
//=======================================================================================================


data "aws_kms_key" "ebs" {
  key_id = "alias/${var.environment}-ebs-cmk"
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}