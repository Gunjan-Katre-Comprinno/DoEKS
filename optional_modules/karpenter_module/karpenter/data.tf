data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_ecrpublic_authorization_token" "token" {}

data "aws_iam_role" "node_role" {
  name = "${var.cluster_name}-node-role"
}