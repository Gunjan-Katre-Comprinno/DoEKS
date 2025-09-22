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
//                                     Terraform Input Variables
//=======================================================================================================
// These variables are populated by the calling function values.

// The AWS region where the resources will be deployed.
variable "region" {
  description = "AWS region where the resources will be deployed."
}

// Configuration for network resources such as VPC, subnets, internet gateway, NAT gateway, and route table.
variable "vpc_conf" {
  description = "Configuration settings for network-related resources like Virtual Private Cloud (VPC), subnets, Internet Gateway, and NAT configurations."
}

// The environment tag to be used, such as 'dev', 'qa', or 'production'.
variable "environment" {
  description = "A tag indicating the deployment environment (e.g., dev, qa, production)."
}

// The name of the EKS cluster to add relevant tags on subnets.
variable "cluster_name" {
  description = "Name of the EKS cluster to add relevant tags on subnets."
}
