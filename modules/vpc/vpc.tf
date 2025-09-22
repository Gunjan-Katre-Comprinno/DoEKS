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
//                            Retrieving Available Availability Zones
//=======================================================================================================
// This data source retrieves information about the available AWS availability zones.
// - Retrieves information about the availability zones in the current AWS region
// - Filters the availability zones based on their state (e.g., "available")
data "aws_availability_zones" "available" {
  state = "available"
}


//=======================================================================================================
//                                           Resource for VPC
//=======================================================================================================
// This resource defines the Virtual Private Cloud (VPC) in AWS.
// - Defines the VPC with the specified CIDR block
// - Enables DNS support and hostnames
// - Sets tags for identification and discovery
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_conf.vpc.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    {
      "Name"                   = "${var.environment}-vpc"
      "Environment"            = var.environment
      "karpenter.sh/discovery" = "${var.environment}-${var.cluster_name}"
    },
    var.vpc_conf.vpc.additional_tags
  )
}


//=======================================================================================================
//                                        Creation of Public Subnets  
//=======================================================================================================
// This resource defines public subnets within the VPC.
// - Creates public subnets within the VPC with specified CIDR blocks
// - Enables mapping of public IP addresses on launch
// - Associates subnets with the VPC and availability zones
// - Sets tags for identification and Kubernetes role
resource "aws_subnet" "public_subnets" {
  count                   = length(var.vpc_conf.vpc.public_subnets_cidr)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  cidr_block              = element(var.vpc_conf.vpc.public_subnets_cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    {
      Name                     = "${var.environment}-public-app-subnet-${count.index + 1}"
      Environment              = var.environment
      "kubernetes.io/role/elb" = "1"
    },
    var.vpc_conf.vpc.additional_tags
  )
  depends_on = [data.aws_availability_zones.available, aws_vpc.vpc]
}


//=======================================================================================================
//                            Creation of Public route table having route to IGW 
//=======================================================================================================
// This resource defines a route table for public subnets with a route to the internet gateway.
// - Defines a route table for public subnets
// - Specifies a route to the internet gateway for all traffic
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    {
      "Name"        = "${var.environment}-public-app-route-table"
      "Environment" = var.environment
    },
    var.vpc_conf.vpc.additional_tags
  )
  depends_on = [aws_internet_gateway.igw]
}


//=======================================================================================================
//                                              PUBLIC ROUTE 
//=======================================================================================================
// This resource defines a route in the public route table to route traffic to the internet gateway.
// - Creates a route in the public route table
// - Routes all traffic (0.0.0.0/0) to the internet gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.rtb_public.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.igw.id
  depends_on = [aws_route_table.rtb_public]
}


//=======================================================================================================
//                                   ASSOCIATE PUBLIC SUBNETS TO ROUTE TABLE
//=======================================================================================================
// This resource associates public subnets with the public route table.
// - Associates each public subnet with the public route table
// - Ensures that traffic from the public subnets is routed to the internet gateway
resource "aws_route_table_association" "public_route_association" {
  count          = length(var.vpc_conf.vpc.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.rtb_public.id
  depends_on     = [aws_subnet.public_subnets, aws_route_table.rtb_public]
}


//=======================================================================================================
//                           Internet Gateway is used to enable connection to internet
//=======================================================================================================
// This resource defines an internet gateway for the VPC.
// - Creates an internet gateway to enable connectivity to the internet
// - Sets tags for identification and environment
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    "Name"        = "${var.environment}-internet-gateway"
    "Environment" = var.environment
    },
    var.vpc_conf.vpc.additional_tags
  )
  depends_on = [aws_vpc.vpc]
}


//=======================================================================================================
//                                   Creation of Elastic IPs for individual NATs
//=======================================================================================================
// This resource defines Elastic IPs for individual NAT gateways.
// - Creates Elastic IPs to be associated with NAT gateways
// - Sets tags for identification and environment
resource "aws_eip" "nat" {
  count = var.vpc_conf.vpc.nat_gateway_count
  vpc   = true
  tags = merge(
    {
      "Name"        = "${var.environment}-nat-gateway-${count.index + 1}-elastic-ip"
      "Environment" = var.environment
    },
    var.vpc_conf.vpc.additional_tags
  )
}


//=======================================================================================================
//                                       Creation of NAT gateways
//=======================================================================================================
// This resource defines NAT gateways within the VPC.
// - Creates NAT gateways for the VPC
// - Associates Elastic IPs with NAT gateways
// - Sets tags for identification and environment
resource "aws_nat_gateway" "nat-gateways" {
  count         = try(var.vpc_conf.vpc.nat_gateway_count, 1)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index % length(aws_subnet.public_subnets)].id

  tags = merge(
    {
      "Name"        = "${var.environment}-nat-gateway-${count.index + 1}"
      "Environment" = var.environment
    },
    var.vpc_conf.vpc.additional_tags
  )
  depends_on = [aws_eip.nat, aws_subnet.public_subnets]
}


//=======================================================================================================
//                                   Creation of Private Application Subnets 
//=======================================================================================================
// This resource defines private subnets for application servers within the VPC.
// - Creates private subnets for application servers within the VPC
// - Associates subnets with the VPC and availability zones
// - Sets tags for identification and Kubernetes role
resource "aws_subnet" "private_app_subnets" {
  count             = length(var.vpc_conf.vpc.private_app_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.vpc_conf.vpc.private_app_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    {
      Name                              = "${var.environment}-private-app-subnet-${count.index + 1}"
      Environment                       = var.environment
      "kubernetes.io/role/internal-elb" = "1"
      "karpenter.sh/discovery"          = "${var.environment}-${var.cluster_name}"

    },
    var.vpc_conf.vpc.additional_tags
  )
  depends_on = [data.aws_availability_zones.available, aws_vpc.vpc]
}


//=======================================================================================================
//                        Creation of Private route table having route to Nat-Gateway 
//=======================================================================================================
// This resource defines a route table for private subnets with a route to the NAT gateway.
// - Creates a route table for private subnets
// - Specifies a route to the NAT gateway for all outbound traffic
resource "aws_route_table" "rtb_private_app" {
  count  = length(aws_nat_gateway.nat-gateways)
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      "Name"        = "${var.environment}-private-app-route-table-${count.index + 1}"
      "Environment" = var.environment
    },
    var.vpc_conf.vpc.additional_tags
  )
  depends_on = [aws_vpc.vpc]
}


//=======================================================================================================
//                                        PRIVATE ROUTE 
//=======================================================================================================
// This resource defines a route in the private route table to route outbound traffic through the NAT gateway.
// - Creates a route in the private route table
// - Routes all outbound traffic (0.0.0.0/0) to the NAT gateway
resource "aws_route" "private_routes" {
  count                  = length(aws_nat_gateway.nat-gateways)
  route_table_id         = aws_route_table.rtb_private_app[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateways[count.index].id
  depends_on             = [aws_route_table.rtb_private_app, aws_nat_gateway.nat-gateways]
}


//=======================================================================================================
//                         ASSOCIATE PRIVATE APP SUBNETS TO PRIVATE ROUTE TABLE
//=======================================================================================================
// This resource associates private application subnets with the private route table.
// - Associates each private subnet with the private route table
// - Ensures that traffic from the private subnets is routed through the NAT gateway
resource "aws_route_table_association" "private_control_plane_route_association" {
  count          = length(var.vpc_conf.vpc.private_app_subnets_cidr)
  subnet_id      = aws_subnet.private_app_subnets[count.index].id
  route_table_id = aws_route_table.rtb_private_app[count.index % length(aws_nat_gateway.nat-gateways)].id
  depends_on     = [aws_subnet.private_app_subnets, aws_route_table.rtb_private_app]
}


//=======================================================================================================
//                                 Creation of private db Subnets
//=======================================================================================================
// This resource defines private subnets for database servers within the VPC.
// - Creates private subnets for database servers within the VPC
// - Associates subnets with the VPC and availability zones
// - Sets tags for identification and environment
resource "aws_subnet" "private_db_subnets" {
  count             = length(var.vpc_conf.vpc.private_db_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.vpc_conf.vpc.private_db_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    {
      Name        = "${var.environment}-private-db-subnet-${count.index + 1}"
      Environment = var.environment

    },
    var.vpc_conf.vpc.additional_tags
  )
  depends_on = [data.aws_availability_zones.available, aws_vpc.vpc]
}


//=======================================================================================================
//                                 CREATION OF PRIVATE DB ROUTE TABLE
//=======================================================================================================
// This resource defines a route table for private database subnets.
// - Creates a route table for private database subnets
// - Sets tags for identification and environment
resource "aws_route_table" "rtb_private_db" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      "Name"        = "${var.environment}-private-db-route-table"
      "Environment" = var.environment
    },
    var.vpc_conf.vpc.additional_tags
  )
  depends_on = [aws_vpc.vpc]
}


//=======================================================================================================
//                               ASSOCIATE PRIVATE DB SUBNETS TO ROUTE TABLE
//=======================================================================================================
// This resource associates private database subnets with the private database route table.
// - Associates each private database subnet with the private database route table
resource "aws_route_table_association" "private_route_association_db" {
  count          = length(var.vpc_conf.vpc.private_db_subnets_cidr)
  subnet_id      = aws_subnet.private_db_subnets[count.index].id
  route_table_id = aws_route_table.rtb_private_db.id
  depends_on     = [aws_subnet.private_app_subnets, aws_route_table.rtb_private_db]
}