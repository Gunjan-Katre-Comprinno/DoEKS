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

variable "region" {
  description = "The AWS region where the resources will be deployed."
}

variable "environment" {
  description = "A tag indicating the deployment environment (e.g., dev, qa, production)."
}


variable "kms_conf" {
  description = "Configuration settings for creating AWS Key Management Service (KMS) keys."
}

variable "eks_conf" {
  description = "Configuration settings for Amazon Elastic Kubernetes Service (EKS), including cluster configuration and launch template."
}

variable "vpc_conf" {
  description = "Configuration settings for network-related resources like Virtual Private Cloud (VPC), subnets, Internet Gateway, and NAT configurations."
}

variable "create" {
  description = "Flags to control the creation of resources. Set to true to create new resources or false to use existing ones."
}

variable "efs_conf" {
  description = "Configuration settings for creating Amazon Elastic File System (EFS)."
}

variable "ecr_repository_conf" {
  description = "Configuration settings for creating Amazon Elastic Container Registry (ECR) repositories, including repository configurations such as mutability and scan on push."
}

variable "code_pipeline_conf" {
  description = "Configuration settings related to AWS CodePipeline."
}

variable "node_groups_conf" {
  description = "Configuration settings for node groups in the Amazon Elastic Kubernetes Service (EKS) cluster created by this code."
}


variable "parameters_conf" {
  description = "All parameters  created in aws parameter store related configurations"
}