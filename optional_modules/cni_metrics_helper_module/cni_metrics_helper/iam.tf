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
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster
//=======================================================================================================

data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

//=======================================================================================================
//                 https://docs.aws.amazon.com/eks/latest/userguide/cni-metrics-helper.html
//                                      Policy document cni metrics helper
//=======================================================================================================

data "aws_iam_policy_document" "cni_metrics_helper_policy_document" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }
}

//=======================================================================================================
//                                          Create a cni metrics helper policy
//=======================================================================================================

resource "aws_iam_policy" "cni_metrics_helper_policy" {
  name        = "${var.cluster_name}-cni-metrics-helper-policy"
  description = "Grants permission to write metrics to CloudWatch"
  policy      = data.aws_iam_policy_document.cni_metrics_helper_policy_document.json
}

//=======================================================================================================
//                                    Assume role trust policy for cni metrics helper
//=======================================================================================================

data "aws_iam_policy_document" "cni_metrics_helper_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:cni-metrics-helper",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com",
      ]
    }

    effect = "Allow"
  }
}

//=======================================================================================================
//               Role for CNI metrics with above created document for assume role
//=======================================================================================================

resource "aws_iam_role" "cni_metrics_helper_role" {
  name               = "${var.cluster_name}-cni-metrics-helper-role"
  assume_role_policy = data.aws_iam_policy_document.cni_metrics_helper_assume_policy.json
}

//=======================================================================================================
//                         Attach cni_metrics_helper_policy to cni_metrics_helper_role
//=======================================================================================================
resource "aws_iam_role_policy_attachment" "cni_metrics_helper_role_policy_attachment" {
  role       = aws_iam_role.cni_metrics_helper_role.name
  policy_arn = aws_iam_policy.cni_metrics_helper_policy.arn
}