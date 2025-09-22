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

data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

//=======================================================================================================
//                                    EKS Optimized AMI Data Sources
//=======================================================================================================

# Data source to get the latest EKS optimized AMI ID based on configuration
data "aws_ssm_parameter" "eks_ami_id" {
  count = var.eks_conf.launch_template.use_latest_ami ? 1 : 0
  name  = "/aws/service/eks/optimized-ami/${var.eks_conf.cluster.eks_kubernetes_version}/${local.resolved_ami_type}/recommended/image_id"
}

locals {
  # Use ami_type directly or fallback to default
  resolved_ami_type = coalesce(
    var.eks_conf.launch_template.ami_type,
    "amazon-linux-2023/x86_64/standard"
  )

  # Dynamic AMI type resolution for each node group
  node_group_ami_types = {
    for key, ng in var.node_groups_conf : key => coalesce(
      try(ng.ami_type, null),
      var.eks_conf.launch_template.ami_type,
      "amazon-linux-2023/x86_64/standard"
    )
  }

  # Use custom AMI if provided and use_latest_ami is false, otherwise use the latest from SSM
  ami_id = var.eks_conf.launch_template.use_latest_ami ? data.aws_ssm_parameter.eks_ami_id[0].value : var.eks_conf.launch_template.image_id
}