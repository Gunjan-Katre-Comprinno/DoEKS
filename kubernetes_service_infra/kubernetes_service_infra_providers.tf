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
//                                 Terraform provider
//=======================================================================================================
terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.57"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }

  # backend "s3" {
  #    # Pre-existing bucket name in which to store the terraform state file
  #    bucket = "terraform-tfstate-bucket-1998"

  #    # Key path within bucket where state will be stored. This path will be prefixed with Environment tag in code
  #    key    = "packaging/kubernetes_service_infra/terraform.tfstate"

  #    # Region where dynamodb table and s3 bucket is created. Both needs to be in same region
  #    region = "us-east-1"

  #    # To enable encryption for the remote state stored in S3
  #    encrypt = true
  #    # Name of dynamodb table to be used for Remote state locking which has LockID of type "String" as Primary Key
  #    #   dynamodb_table = "<remote-state-table>"
  #    # if using workspace, you can use a prefix to store remote state of workspace separately. This prefix will act as key to your workspace.
  #    #   workspace_key_prefix = "<development>"
  #  }

}

//=======================================================================================================
//                                Kubernetes provider
//=======================================================================================================
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}

//=======================================================================================================
//                                   Helm provider
//=======================================================================================================
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}

//=======================================================================================================
//                                   Kubectl provider
//=======================================================================================================
provider "kubectl" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  load_config_file       = false
}

//======================================================================================================
//                                          AWS provider
//======================================================================================================
provider "aws" {
  region = var.region
}

