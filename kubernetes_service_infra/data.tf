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

//======================================================================================================
//                                 Retrieve Information about EKS Cluster
//======================================================================================================
// Retrieves information about the EKS cluster
data "aws_eks_cluster" "eks_cluster" {
  name = "${var.environment}-${var.eks_conf.cluster.cluster_name}" // Name of the EKS cluster to retrieve information about
}

//======================================================================================================
//                           Retrieve Authentication Information for EKS Cluster
//======================================================================================================
// Retrieves authentication information for the EKS cluster
data "aws_eks_cluster_auth" "eks_cluster" {
  name = "${var.environment}-${var.eks_conf.cluster.cluster_name}" // Name of the EKS cluster to retrieve authentication information for
}

