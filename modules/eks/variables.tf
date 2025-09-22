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

variable "environment" {
  description = "Environment tag to be used. Ex: dev/qa/production"
}

variable "region" {
  description = "AWS region to deploy the resources in"
}

variable "vpc_id" {
  description = "ID of VPC where EKS nodes will be deployed"
}

variable "eks_conf" {
  description = "AWS EKS configuration including cluster configuration and launch template"
}

variable "vpc_conf" {
  description = "Network resources related configuration such as VPC, Subnets, Internet Gateway, NAT and so on"
}

variable "private_subnets" {
  description = "ID of subnets in which Nodegroups are to be deployed"
}

variable "node_groups_conf" {
  description = "Configuration for creating nodegroups for the AWS EKS Cluster"
}

variable "create" {
  description = "Flags for all the resources to have control over their creation. Flag values will be true (for creation) and false (For using existing resources)"
}
