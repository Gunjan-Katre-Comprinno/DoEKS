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
//                                           Karpenter Instance Node Role
//                               IAM Role to be used for the nodes within EKS Cluster
//=======================================================================================================

resource "aws_iam_role" "karpenter_instance_node_role" {
  name               = "${var.cluster_name}-karpenter-instance-node-role"
  description        = "IAM Role to be used by karpenter within EKS cluster"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

//=======================================================================================================
//                                       Creating Instance Profile
//=======================================================================================================

resource "aws_iam_instance_profile" "eks_instance_role_profile" {
  name = "${var.cluster_name}-karpenter-instance-node-role"
  role = aws_iam_role.karpenter_instance_node_role.name
}

//=======================================================================================================
//                Attach following AWS Managed Policies to  Karpenter Instance Node Role
//=======================================================================================================

resource "aws_iam_role_policy_attachment" "attach_amazon_eks_worker_node_policy" {
  role       = aws_iam_role.karpenter_instance_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "attach_amazon_ecr_ro_policy" {
  role       = aws_iam_role.karpenter_instance_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "attach_amazon_eks_cni_policy" {
  role       = aws_iam_role.karpenter_instance_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "attach_ssm_managed_instance_core_policy" {
  role       = aws_iam_role.karpenter_instance_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



//=======================================================================================================
//                           Policy document for karpenter controller
//=======================================================================================================

data "aws_iam_policy_document" "controller_policy" {
  version = "2012-10-17"

  statement {
    actions = [
      "ssm:GetParameter",
      "ec2:DescribeImages",
      "ec2:RunInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DeleteLaunchTemplate",
      "ec2:CreateTags",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:DescribeSpotPriceHistory",
      "pricing:GetProducts"
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "Karpenter"
  }

  statement {
    actions = ["ec2:TerminateInstances"]

    effect = "Allow"

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/karpenter.sh/nodepool"

      values = ["*"]
    }

    resources = ["*"]
    sid       = "ConditionalEC2Termination"
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-karpenter-instance-node-role"]
    sid       = "PassNodeIAMRole"
  }

  statement {
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"]
    sid       = "EKSClusterEndpointLookup"
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage"
    ]
    resources = ["arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.environment}-${var.cluster_name}-karpenter"]
    sid       = "SQSInterruptionQueue"
  }

  statement {
    sid    = "AllowScopedInstanceProfileCreationActions"
    effect = "Allow"
    actions = [
      "iam:CreateInstanceProfile"
    ]
    resources = ["*"]

    condition {
      test   = "StringEquals"
      values = ["owned"]

      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
    }

    condition {
      test   = "StringEquals"
      values = ["${var.region}"]

      variable = "aws:RequestTag/topology.kubernetes.io/region"
    }

    condition {
      test   = "StringLike"
      values = ["*"]

      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
    }
  }

  statement {
    sid    = "AllowScopedInstanceProfileTagActions"
    effect = "Allow"
    actions = [
      "iam:TagInstanceProfile"
    ]
    resources = ["*"]

    condition {
      test   = "StringEquals"
      values = ["owned"]

      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
    }
    condition {
      test   = "StringEquals"
      values = ["${var.region}"]

      variable = "aws:ResourceTag/topology.kubernetes.io/region"
    }
    condition {
      test     = "StringEquals"
      values   = ["owned"]
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
    }

    condition {
      test     = "StringEquals"
      values   = ["${var.region}"]
      variable = "aws:RequestTag/topology.kubernetes.io/region"
    }
    condition {
      test   = "StringLike"
      values = ["*"]

      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
    }
    condition {
      test   = "StringLike"
      values = ["*"]

      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
    }
  }

  statement {
    sid    = "AllowScopedInstanceProfileActions"
    effect = "Allow"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile"
    ]
    resources = ["*"]

    condition {
      test   = "StringEquals"
      values = ["owned"]

      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
    }

    condition {
      test   = "StringEquals"
      values = ["${var.region}"]

      variable = "aws:ResourceTag/topology.kubernetes.io/region"
    }

    condition {
      test   = "StringLike"
      values = ["*"]

      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
    }
  }

  statement {
    sid    = "AllowInstanceProfileReadActions"
    effect = "Allow"
    actions = [
      "iam:GetInstanceProfile"
    ]
    resources = ["*"]
  }
}
//=======================================================================================================
//                                 Policy fo karpenter controller role
//=======================================================================================================
resource "aws_iam_policy" "controller_policy" {
  name        = "${var.cluster_name}-karpenter-controller-policy"
  description = "IAM policy for Karpenter Controller"
  policy      = data.aws_iam_policy_document.controller_policy.json
}



//=======================================================================================================
//                              Attaching Policy to karpenter controller role
//=======================================================================================================
resource "aws_iam_role_policy_attachment" "controller_policy_attachment" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.controller_policy.arn
}



//=======================================================================================================
//                                       karpenter controller role
//=======================================================================================================

resource "aws_iam_role" "karpenter_controller_role" {
  name               = "${var.cluster_name}-karpenter-controller-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_policy.json
}

data "aws_iam_policy_document" "karpenter_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.karpenter_conf.namespace}:karpenter",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com",
      ]
    }

    effect = "Allow"
  }
}

