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
//                                    Dynamic Launch Templates
//=======================================================================================================

# Data source for dynamic node group AMIs
data "aws_ssm_parameter" "node_group_ami_id" {
  for_each = {
    for key, ng in var.node_groups_conf : key => ng
    if try(ng.use_latest_ami, var.eks_conf.launch_template.use_latest_ami, true)
  }

  name = "/aws/service/eks/optimized-ami/${var.eks_conf.cluster.eks_kubernetes_version}/${local.node_group_ami_types[each.key]}/recommended/image_id"
}

# User data template for dynamic node groups
data "template_file" "node_group_userdata" {
  for_each = var.node_groups_conf

  template = file("${path.module}/templates/userdata.sh.tpl")
  vars = {
    cluster_name         = "${var.environment}-${var.eks_conf.cluster.cluster_name}"
    endpoint             = module.eks.cluster_endpoint
    cluster_auth_base64  = module.eks.cluster_certificate_authority_data
    bootstrap_extra_args = try(each.value.bootstrap_extra_args, "")
    kubelet_extra_args   = try(each.value.kubelet_extra_args, "")
    cluster_service_cidr = coalesce(var.eks_conf.cluster.cluster_service_ipv4_cidr, "172.20.0.0/16")
  }
}

# Dynamic launch templates for each node group
resource "aws_launch_template" "node_group_lt" {
  for_each = var.node_groups_conf

  name                   = "${var.environment}-${var.eks_conf.cluster.cluster_name}-${each.value.name}-lt"
  description            = "Launch Template for ${var.environment}-${var.eks_conf.cluster.cluster_name}-${each.value.name} node group"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = try(each.value.root_volume_size, var.eks_conf.launch_template.root_volume_size)
      volume_type           = try(each.value.volume_type, var.eks_conf.launch_template.volume_type)
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ebs_key.arn
    }
  }

  monitoring {
    enabled = try(each.value.enhanced_monitoring_enabled, var.eks_conf.launch_template.enhanced_monitoring_enabled)
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  # Dynamic AMI selection
  image_id = try(each.value.use_latest_ami, var.eks_conf.launch_template.use_latest_ami, true) ? data.aws_ssm_parameter.node_group_ami_id[each.key].value : try(each.value.image_id, var.eks_conf.launch_template.image_id)

  user_data = base64encode(data.template_file.node_group_userdata[each.key].rendered)

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name        = "${var.environment}-${var.eks_conf.cluster.cluster_name}-${each.value.name}-instance"
        Environment = var.environment
      },
      try(each.value.additional_tags, {}),
      try(var.eks_conf.launch_template.additional_tags, {})
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name        = "${var.environment}-${var.eks_conf.cluster.cluster_name}-${each.value.name}-ebs"
        Environment = var.environment
      },
      try(each.value.additional_tags, {}),
      try(var.eks_conf.launch_template.additional_tags, {})
    )
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.eks_conf.cluster.cluster_name}-${each.value.name}-lt"
      Environment = var.environment
    },
    try(each.value.additional_tags, {}),
    try(var.eks_conf.launch_template.additional_tags, {})
  )

  lifecycle {
    create_before_destroy = true
  }
}
