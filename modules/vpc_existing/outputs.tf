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
//                               Terraform Output Variables
//=======================================================================================================
// These output variables provide information about the created resources.

// The ID of the VPC created.
output "vpc_id" {
  value = data.aws_vpc.selected.id
}

// The public subnets created.
output "public_subnets" {
  value = data.aws_subnets.public_subnets[*]
}

// The IDs of the public subnets created.
output "public_subnets_ids" {
  value = data.aws_subnets.public_subnets.ids
}

// The private application subnets created.
output "private_app_subnets" {
  value = data.aws_subnets.private_app_subnets[*]
}

// The IDs of the private application subnets created.
output "private_app_subnets_ids" {
  value = data.aws_subnets.private_app_subnets.ids
}

// The private database subnets created.
output "db_private_subnets" {
  value = data.aws_subnets.db_subnets[*]
}

// The IDs of the private database subnets created.
output "db_private_subnets_ids" {
  value = data.aws_subnets.db_subnets.ids
}
