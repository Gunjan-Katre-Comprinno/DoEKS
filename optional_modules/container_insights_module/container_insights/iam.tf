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
data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

//=======================================================================================================
//                           Attach following AWS Managed Policies to Container Insight Role
//=======================================================================================================

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_logs_access_policy" {
  role       = aws_iam_role.container_insight_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_ec2_access_policy" {
  role       = aws_iam_role.container_insight_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

//=======================================================================================================
//               Role for Container Insights
//=======================================================================================================

resource "aws_iam_role" "container_insight_role" {
  name               = "${var.cluster_name}-container-insight-role"
  assume_role_policy = data.aws_iam_policy_document.container_insight_assume_policy.json
}

data "aws_iam_policy_document" "container_insight_assume_policy" {
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
        "system:serviceaccount:container-insight:aws-otel-sa",
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