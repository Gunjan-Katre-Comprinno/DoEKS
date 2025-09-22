data "aws_eks_cluster" "cluster" {
  name = "testing-eks-cluster"
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "spark_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.spark_operator_conf.serviceAccount.name}"]
    }
  }
}

resource "aws_iam_role" "spark_operator_role" {
  name               = "testing-eks-cluster-spark-operator-role"
  assume_role_policy = data.aws_iam_policy_document.spark_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "spark_s3_access" {
  role       = aws_iam_role.spark_operator_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "spark_ecr_access" {
  role       = aws_iam_role.spark_operator_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
