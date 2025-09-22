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
//                  Policy document for Cluster AutoScaler 
//=======================================================================================================

data "aws_iam_policy_document" "cluster_autoscaler_policy_document" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "eks:DescribeNodegroup"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }
}

//=======================================================================================================
// Cluster Autoscaler policy which uses the above policy document
// Cluster Autoscaler policy is taken from following documentation: https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html
// For any future updates to the policy, please refer the documentation
//=======================================================================================================

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "${var.cluster_name}-cluster-autoscaler-policy"
  path        = "/"
  description = "Policy for Cluster Autoscaler"
  policy      = data.aws_iam_policy_document.cluster_autoscaler_policy_document.json
}

//=======================================================================================================
//                               Assume role policy for cluster autoscaler controller
//=======================================================================================================

data "aws_iam_policy_document" "cluster_autoscaler_assume_policy" {
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
        "system:serviceaccount:${var.cluster_autoscaler_conf.namespace}:cluster-autoscaler",
      ]
    }
    effect = "Allow"
  }
}
//=======================================================================================================
//                  Role for cluster autoscaler with above created document for assume role
//=======================================================================================================

resource "aws_iam_role" "cluster_autoscaler_role" {
  name               = "${var.cluster_name}-cluster-autoscaler-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_policy.json
}

//=======================================================================================================
//                              Attaching Policy to Cluster Autoscaler Role
//=======================================================================================================

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler_role.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}