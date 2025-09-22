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


// Fetches the selected VPC using its name
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_conf.existing_vpc.existing_vpc_name]
  }
}

// Fetches public subnets within the selected VPC based on their names
data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Name"
    values = var.vpc_conf.existing_vpc.existing_public_subnet_names
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

// Fetches private application subnets within the selected VPC based on their names
data "aws_subnets" "private_app_subnets" {
  filter {
    name   = "tag:Name"
    values = var.vpc_conf.existing_vpc.existing_private_app_subnet_names
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

// Fetches database subnets within the selected VPC based on their names
data "aws_subnets" "db_subnets" {
  filter {
    name   = "tag:Name"
    values = var.vpc_conf.existing_vpc.existing_db_subnet_names
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}
