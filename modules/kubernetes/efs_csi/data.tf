data "aws_efs_file_system" "efs" {
  tags = {
    Name = try("${var.environment}-${var.efs_conf.name}", "${var.environment}-csi-efs")
  }
}


data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


data "aws_kms_key" "efs" {
  key_id = "alias/${var.environment}-efs-cmk"
}