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

// Tag public subnets to denote their role as ELBs
resource "aws_ec2_tag" "public_subnet_alb_tagging" {
  count       = length(data.aws_subnets.public_subnets.ids)
  resource_id = element(data.aws_subnets.public_subnets.ids, count.index)
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

// Tag public subnets to denote their association with the cluster
resource "aws_ec2_tag" "public_subnet_cluster_tagging" {
  count       = length(data.aws_subnets.public_subnets.ids)
  resource_id = element(data.aws_subnets.public_subnets.ids, count.index)
  key         = "kubernetes.io/cluster/${var.environment}-${var.cluster_name}"
  value       = "shared"
}


// Tag private subnets to denote their role as internal ELBs
resource "aws_ec2_tag" "private_subnet_alb_tagging" {
  count       = length(data.aws_subnets.private_app_subnets.ids)
  resource_id = element(data.aws_subnets.private_app_subnets.ids, count.index)
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}


// Tag private subnets to denote their association with the cluster
resource "aws_ec2_tag" "private_subnet_cluster_tagging" {
  count       = length(data.aws_subnets.private_app_subnets.ids)
  resource_id = element(data.aws_subnets.private_app_subnets.ids, count.index)
  key         = "kubernetes.io/cluster/${var.environment}-${var.cluster_name}"
  value       = "shared"
}


// Tag private subnets to denote their association with Karpenter
resource "aws_ec2_tag" "private_subnet_karpenter_tagging" {
  count       = length(data.aws_subnets.private_app_subnets.ids)
  resource_id = element(data.aws_subnets.private_app_subnets.ids, count.index)
  key         = "karpenter.sh/discovery"
  value       = "${var.environment}-${var.cluster_name}"
}