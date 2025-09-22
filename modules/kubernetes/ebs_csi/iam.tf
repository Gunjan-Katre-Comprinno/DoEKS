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
//                               Policy document for EBS CSI Controller 
//=======================================================================================================
data "aws_iam_policy_document" "ebs_csi_controller_policy_document" {
  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*",
    ]
    effect = "Allow"
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateVolume", "CreateSnapshot"]
    }
  }
  statement {
    actions = [
      "ec2:DeleteTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*",
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "ec2:CreateVolume"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
  statement {
    actions = [
      "ec2:CreateVolume"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/CSIVolumeName"
      values   = ["*"]
    }
  }
  statement {
    actions = [
      "ec2:CreateVolume"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/kubernetes.io/cluster/*"
      values   = ["owned"]
    }
  }
  statement {
    actions = [
      "ec2:DeleteVolume"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
  statement {
    actions = [
      "ec2:DeleteVolume"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/CSIVolumeName"
      values   = ["*"]
    }
  }
  statement {
    actions = [
      "ec2:DeleteVolume"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/kubernetes.io/cluster/*"
      values   = ["owned"]
    }
  }
  statement {
    actions = [
      "ec2:DeleteSnapshot"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/CSIVolumeSnapshotName"
      values   = ["*"]
    }
  }
  statement {
    actions = [
      "ec2:DeleteSnapshot"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = [
      data.aws_kms_key.ebs.arn,
    ]
    effect = "Allow"
  }

}

//=======================================================================================================
// policy which uses the above policy document
// Policy is taken from following documentation: https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
// For any future updates to the policy, please refer the documentation
//=======================================================================================================

resource "aws_iam_policy" "ebs_csi_controller_policy" {
  name        = "${var.cluster_name}-ebs-csi-controller-policy"
  path        = "/"
  description = "Policy for EBS CSI Controller"
  policy      = data.aws_iam_policy_document.ebs_csi_controller_policy_document.json
}

//=======================================================================================================
//                                Assume role policy for EBS CSI Controller
//=======================================================================================================
data "aws_iam_policy_document" "ebs_csi_controller_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn] #[module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller",
      ]
    }
    effect = "Allow"
  }
}

//=======================================================================================================
//                      Role for EBS CSI with above created document for assume role
//=======================================================================================================
resource "aws_iam_role" "ebs_csi_controller_role" {
  name               = "${var.cluster_name}-ebs-csi-controller-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_controller_assume_policy.json
}

//=======================================================================================================
//                                   Attaching Policy to EBS CSI role
//=======================================================================================================
resource "aws_iam_role_policy_attachment" "ebs_csi_controller" {
  role       = aws_iam_role.ebs_csi_controller_role.name
  policy_arn = aws_iam_policy.ebs_csi_controller_policy.arn
}