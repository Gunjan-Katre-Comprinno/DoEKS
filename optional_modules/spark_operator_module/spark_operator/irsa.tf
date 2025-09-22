resource "aws_iam_role" "spark_operator_irsa" {
  name               = "${var.cluster_name}-spark-operator-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role_policy.json
}

data "aws_iam_policy_document" "irsa_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.id]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:spark-operator:spark-operator-sa"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "spark_operator_policy_attach" {
  role       = aws_iam_role.spark_operator_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  # Example
}

resource "kubernetes_service_account" "spark_operator_sa" {
  metadata {
    name      = "spark-operator-sa"
    namespace = "spark-operator"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.spark_operator_irsa.arn
    }
  }
}
