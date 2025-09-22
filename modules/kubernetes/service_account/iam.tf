
//=======================================================================================================
//                           Assume role policy for Service Account 
//=======================================================================================================

data "aws_iam_policy_document" "service_account_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.service_account_conf.namespace}:${var.service_account_conf.name}",
      ]
    }

    effect = "Allow"
  }
}

//=======================================================================================================
//             Role for Service Account  with above created document for assume role
//=======================================================================================================

resource "aws_iam_role" "service_account_role" {
  name               = "${var.cluster_name}-${var.service_account_conf.name}-service-account-role"
  assume_role_policy = data.aws_iam_policy_document.service_account_assume_policy.json
}

# Attaching Policy to Service Account Role

resource "aws_iam_role_policy_attachment" "service_account" {
  role       = aws_iam_role.service_account_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

