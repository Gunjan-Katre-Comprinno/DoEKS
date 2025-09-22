

---

# Comprinno Terraform Code for EKS-Boilerplate

## About Terraform

**Terraform** is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

## Technical Details

All resources are deployed on AWS and use Terraform for Infrastructure as Code.

## What This Code Creates

**Note: VPC creation is optional and is controlled by a boolean variable.**

### VPC and Related Resources 

- VPC
- NAT Gateways
- Internet Gateway
- Subnets
  - Public Application Subnets
  - Private Application Subnets
  - Private Database Subnets
- Route Tables
  - Main Route Table
  - Public Application Subnets Route Table
  - Private Application Subnets Route Table (Varies based on the number of NAT Gateways)
  - Private Databases Subnets Route Table
- Routes
  - Local routes
  - Internet gateway route for public application subnets
  - NAT gateway route for private application subnets
  - Databases only have local route within the VPC.
- VPC Flow Logs with flag-based log destination to S3 or AWS CloudWatch 
- Existing VPC support

### AWS Elastic Kubernetes Service Cluster

- EKS Cluster with enabled IRSA(IAM Roles for Service Accounts)
- EKS Cluster role
- AWS launch template
- Nodes
- Node IAM role
- Auto-scaling group
- Elastic Block Storage
- OIDC identity provider 
- Security Groups
  - Primary Security Group
  - Secondary Security Group
- KMS CMK Keys
  - EBS CMK Key
  - EKS CMK Key 

### AWS Elastic FileSystem

- AWS EFS storage
- Mount Targets
- EFS Security Group
- Automated Backup policy

### AWS Elastic Container Registry

- AWS ECR Repositories 
- AWS ECR CMK Key

### Common KMS Keys

- S3 CMK Key

### Kubernetes Resources (In a separate Terraform apply)

- AWS Load Balancer Controller and its dependencies
- Cluster Autoscaler and its dependencies
- Service Account for application namespace
- Metrics Servers
- EBS CSI controller
- EFS CSI controller
- Fluentbit and its dependencies
- Prometheus
- Grafana
- ArgoCD
- Calico
- CNI Metrics Helper
- Kubernetes Dashboard 
- Jaeger  
- Container Insight
- Karpenter


### CICD (sample nginx application) (as part of the base infra)

- AWS S3 bucket for CodePipeline
- AWS S3 bucket for applications configurations, if required as a secondary source
- AWS CodePipelines
- AWS CodeBuild projects under AWS Code Pipelines
- AWS IAM policy and role for CodeBuild and CodePipeline

**Note:** Creation of the following resources in the `example.tfvars` file are optional.

- Creation of the following resources in `aws_base_infra` are controlled by a boolean flag. To create these resources, their respective flags must be set to `true`, else `false`.
  * VPC
  * EKS
  * CodePipelines
  * Parameter Store
  * ECR
  * EFS

- Similarly, creation of the following resources in `kubernetes_service_infra` are controlled by a boolean flag. To create these resources, their respective flags must be set to `true`, else `false`.
  * Cluster Autoscaler
  * AWS LoadBalancer Controller
  * Metrics Server
  * Grafana
  * Prometheus
  * Fluentbit
  * EBS CSI
  * EFS CSI
  * ArgoCD
  #### Optional modules
  * Karpenter
  * CNI Metrics Helper
  * Calico
  * Kubernetes Dashboard
  * Jaeger
  * Container Insight
## Supported Software Versions

| Software                      |  Helm Chart Versions |
|-------------------------------|----------|
| Metrics Server     | 3.12.2   |
| AWS ALB Controller | 1.11.0   |
| ArgoCD              | 7.7.14   |
| Grafana             | 8.8.2   |
| Prometheus         | 26.1.0  |
| Fluentbit           | 0.1.34   |
| CNI Metrics Helper	| 1.16.3
| Kubernetes Dashboard |	7.10.1
| Jaeger      |	1.0.2
| Container Insight	| 0.22.0
| Calico	| v3.27.2
| Karpenter	| 0.37.6




## Access Required

1. To apply and create AWS EKS cluster using this code, one needs to have Administrator access to AWS account.

2. To give access to the cluster to other users

, you need to add IAM user to the configmap `aws-auth.yml` of the cluster. The sample `aws-auth.yml` is given with this code which can be edited and then applied to the cluster using the below command.

   ```bash
   kubectl apply -f aws-auth.yml -n kube-system
   ```

## Important Notes

- AWS EKS must be launched in private subnets.
- Route53/DNS updates will not be part of this code.
- Route53/DNS update entries are to be made for the load balancer.
- Pushing Microservices images to ECR will not be part of this code.
- Also, for accessing the UI of Grafana deployed on Kubernetes, the links and credentials are shared separately.

## Assumptions

- You want to create an EKS cluster with an autoscaling group of `Managed` Nodes, their corresponding dependencies, Kubernetes resources, and other tools/services on Kubernetes.
- You have a Linux system. For Windows users, as the EKS module used in the code may give issues, please read the following [doc](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#deploying-from-windows-binsh-file-does-not-exist).


# Provision Your Environment
## Prerequisites

- You need to create an S3 bucket and DynamoDB table(Optional) beforehand to store the `.tfstate` for Terraform backend mentioned in the `providers.tf` files.

- **You must have Docker installed**

    1. To check if it's installed, run:

        ```bash
        docker --version
        ```
      
       
    If Docker is not installed or to upgrade to the latest version, refer to [this doc](https://docs.docker.com/engine/install/i).

    **Note**: Make sure Docker version should be `Docker version 26.0.2` or    above, as this package is configured with this very version.

  2.Create a AWS IAM User with Administrator permissions, generate the `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` keys.

  3. Customize the `value.tfvars` and `flag.tfvars` as per the environment.
  4. Update the `aws_base_infra_providers.tf` and  `kubernetes_service_infra_providers.tf`.
# Usage
  ### 1. Run the docker container to provision you environment.
  ```bash
  docker run -it --name boilerplate \
   -e AWS_ACCESS_KEY_ID="" \
   -e AWS_SECRET_ACCESS_KEY="" \
   -v "<abolute path on host>"/values.tfvars:/terraform/values.tfvars \
   -v <abolute path on host>"/flag.tfvars:/terraform/flag.tfvars \
   -v <abolute path on host>"/aws_base_infra_providers.tf:/terraform/aws_base_infra/providers.tf \
   -v <abolute path on host>"/kubernetes_service_infra_providers.tf:/terraform/kubernetes_service_infra/providers.tf \
   boilerplate:latest
  ``` 

### 2. Entrypoints supported: Apply/Destroy Infrastructure

- Apply all: `./run.sh apply all`
- Apply AWS: `./run.sh apply aws`
- Apply Kubernetes: `./run.sh apply k8s`



- Destroy all (Kubernetes first, then AWS): `./run.sh destroy all`
- Destroy Kubernetes: `./run.sh destroy k8s`
- Destroy AWS: `./run.sh destroy aws`

Ensure Terraform files and variables are configured before running.

**NOTE: To destroy all the resources, you have to destroy Kubernetes resources first and then the base infra.**

### 3. AWS Base Infrastructure providers (aws_base_infra_providers.tf)
```hcl

//=======================================================================================================
//                                 Terraform provider
//=======================================================================================================
terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      version = "4.57.0"
    }
  }

  backend "s3" {
     # Pre-existing bucket name in which to store the terraform state file
    bucket = "<remote-state-bucket-name>"
    
     # Key path within bucket where state will be stored. This path will be prefixed with Environment tag in code
     key    = "<ENVIRONMENT>/aws_base_infra/terraform.tfstate"
    
     # Region where dynamodb table and s3 bucket is created. Both needs to be in same region
     region = "<s3-bucket-aws-region>"
    
     # To enable encryption for the remote state stored in S3
     encrypt = true
     # Name of dynamodb table to be used for Remote state locking which has LockID of type "String" as Primary Key (Optional)
     #   dynamodb_table = "<remote-state-table-name>" 
     # if using workspace, you can use a prefix to store remote state of workspace separately. This prefix will act as key to your workspace (Optional).
     #   workspace_key_prefix = "<ENVIRONMENT>"
   }
}

//=======================================================================================================
//                                  AWS provider
//=======================================================================================================
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner = "comprinno"
    }
  }
}

```

### 4. Kubernetes Service Infrastructure providers (kubernetes_service_infra_providers.tf)

```hcl

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

  backend "s3" {
     # Pre-existing bucket name in which to store the terraform state file
    bucket = "<remote-state-bucket-name>"
    
     # Key path within bucket where state will be stored. This path will be prefixed with Environment tag in code
     key    = "<ENVIRONMENT>/kubernetes_service_infra/terraform.tfstate"
    
     # Region where dynamodb table and s3 bucket is created. Both needs to be in same region
     region = "<s3-bucket-aws-region>"
    
     # To enable encryption for the remote state stored in S3
     encrypt = true
     # Name of dynamodb table to be used for Remote state locking which has LockID of type "String" as Primary Key (Optional)
     #   dynamodb_table = "<remote-state-table-name>" 
     # if using workspace, you can use a prefix to store remote state of workspace separately. This prefix will act as key to your workspace (Optional).
     #   workspace_key_prefix = "<ENVIRONMENT>"
   }
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
  kubernetes {
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
  default_tags {
    tags = {
      Owner = "comprinno"
    }
  }
}

```

### 5. Flags Supported(flag.tfvars)

```hcl

create = {
# aws_base_infra flags
  vpc = true
  eks_cluster = true
  parameter_store = true
  ecr = true
  codepipeline = true
  efs = true

# kubernetes_service_infra flags
  service_account = true
  cluster_autoscaler = true
  aws_loadbalancer_controller = true
  metrics_server = true
  ebs_csi = true
  efs_csi = true
  prometheus = true
  grafana = true
  fluentbit = true
  argocd = true

  # Optional Modules
  karpenter = false
  container_insight = false
  jaeger = false
  calico = false
  cni_metrics_helper = false
  kubernetes_dashboard = false

}

```

### 6. Values file details (values.tfvars)

```hcl

region      = "us-east-1"
environment = "packaging"


# Certificate Arn used for creating loadbalancers
elb_certificate_arn = "<aws acm-certificate arn for elastic loadbalancers>"

# VPC configuration to create new vpc or use existing VPC and other network related infra depending on the value flag vpc in create 
# section above. If vpc=true, vpc and subnets sub-section of vpc_conf will be used for passing the valid CIDR values VPC and subnets, otherwise, existing_vpc
# sub-section of vpc_conf will be used for passing the existing VPC and subnet name tags for data call
vpc_conf = {

  # the vpc configuration block is only applicable if you set create.vpc=true, otherwise the existing_vpc configuration is applicable.
  vpc = {
    # Pass the VPC's CIDR range
    vpc_cidr = "10.30.0.0/16"

    # Pass the tags that should be associated with this VPC and respective resources
    additional_tags = {}

    # Mention number of nat gateways  by default it is set to 1
    nat_gateway_count = 1

    #By default vpc flowlogs goes to cloudwatch, if you want to send flowlogs to s3 then set enable_s3_vpc_flow_logs = true
    enable_s3_vpc_flow_logs = false

    # Configuration of subnets to be created
    # The number of subnet CIDRs provided will be equal to no of subnets to be created in subsequent AZs of selected region

    public_subnets_cidr = [
      "10.30.0.0/20",
      "10.30.16.0/20",
      "10.30.32.0/20",
    ]

    # Configuration of private data and control plane (which is basically app subnets) subnets to be created
    # The number of subnet CIDRs provided will be equal to no of subnets to be created in subsequent AZs of selected reagion
    private_app_subnets_cidr = [
      "10.30.48.0/20",
      "10.30.64.0/20",
      "10.30.80.0/20",
    ]

    # Configuration of private data and control plane subnets to be created
    # The number of subnet CIDRs provided will be equal to no of subnets to be created in subsequent AZs of selected reagion
    private_db_subnets_cidr = [
      "10.30.144.0/20",
      "10.30.160.0/20",
      "10.30.176.0/20"
    ]
  }
  # Specify the existing_vpc configuration only if you have existing vpc
  existing_vpc = {
    # Pass the existing VPC name if vpc=false is selected in create section. 
    existing_vpc_name = "testing-vpc"
    # Pass a list public subnet names from the existing VPC if configuration needs public subnets
    existing_public_subnet_names = [
      "testing-public-app-subnet-1",
      "testing-public-app-subnet-2",
      "testing-public-app-subnet-3",
    ]
    # Pass a list of private subnet names from the existing VPC for creating cluster's control and data plane
    existing_private_app_subnet_names = [
      "testing-private-app-subnet-1",
      "testing-private-app-subnet-2",
      "testing-private-app-subnet-3",
    ]
    # Pass a list priavete database(db) subnet names from the existing VPC
    existing_db_subnet_names = [
      "testing-private-db-subnet-1",
      "testing-private-db-subnet-2",
      "testing-private-db-subnet-3",
    ]
  }
}

# All KMS configurations
kms_conf = {
  s3 = {
    cmk_name                = "s3-cmk"
    cmk_description         = "CMK for s3 encryption"
    deletion_window_in_days = 7
    enable_key_rotation     = true
    additional_tags = {
    }
  }
}

# EKS configuration including cluster, nodegroups, launch template
# DYNAMIC number of EKS clusters can be launched by reusing the code
eks_conf = {
  cluster = {
    #Name of the EKS Cluster.
    cluster_name = "eks-cluster"
    #Specify kubernetes version.The Kubernetes version can be configured to either "1.23" or "1.24"
    eks_kubernetes_version = "1.28"
    #This variable is a Boolean that determines whether a role for an EKS cluster should be created or an existing one should be used. If you prefer to create a custom role specifically for AWS EKS, please set the value of this variable to false.
    create_iam_role = false
    #This variable controls access to the Kubernetes API server, allowing or restricting public access. If you want to access the API server from outside, set it to "true".
    cluster_endpoint_public_access = true
    #Determines whether the cluster will have a private endpoint to access it within the same network.
    cluster_endpoint_private_access = true
    #Determines whether to create an OpenID Connect Provider for EKS to enable IRSA
    enable_irsa = true
    # Control Plane Logs
    cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

    # The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks
    cluster_service_ipv4_cidr = null

    #EKS Clusters have public access cidrs set to 0.0.0.0/0 by default which is wide open to the internet. This should be explicitly set to a more specific private CIDR range
    cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

    #Additional Tags   
    additional_tags = {}
  }

  launch_template = {
    # volume size is in GB
    root_volume_size = 30
    volume_type      = "gp3"

    #Specify true to enable detailed monitoring. Otherwise, basic monitoring is enabled.
    #Note: Enhanced monitoring has extra charges
    # https://aws.amazon.com/cloudwatch/pricing/
    enhanced_monitoring_enabled = true

    # ID of the Image which will be used to launch nodes for AWS EKS. 
    # This is region specific and AMI should be available in that region
    # EKS optimized public AMI managed by AWS built on top of Amazon Linux 2 is being used.
    # Retrieving Amazon EKS optimized Amazon Linux AMI IDs from this document: https://docs.aws.amazon.com/eks/latest/userguide/retrieve-ami-id.html

    image_id = "ami-04bb6de45022a5c0a" # kuberntees version 1.28 compatible Amazon Linux AMI ID.

    additional_tags = {}
  }

  # ALl kubernetes related configurations
  kubernetes_conf = {
    # Map of microservices configurations 

    # Values for service account
    service_account_conf = {
      namespace = "application-namespace"
      name      = "application-namespace"
    }

    # Values for the Cluster Autoscaler configurations
    cluster_autoscaler_conf = {
      namespace = "kube-system"
    }

    # Values for the metrics server configurations
    metrics_server_conf = {
      namespace = "metrics-server"
      version   = "3.12.0"
    }

    # Values for the AWS Loadbalancer Controller configurations
    aws_loadbalancer_controller_conf = {
      namespace = "kube-system"
      version   = "1.7.1"
    }

    # Values for EBS CSI controller
    ebs_csi_conf = {
      storageclass_name = "ebs-sc"
    }

    # Values for EFS CSI controller
    efs_csi_conf = {
      storageclass_name = "efs-sc"
    }


    # Values for argo cd deployment
    argocd_conf = {
      namespace = "argocd"
      version   = "5.46.3"
      ingress = {
        enabled     = "true"
        host        = "argocd.comprinno.net"
        annotations = {}
      }
    }

    # Values for the fluentbit configurations
    fluentbit_conf = {
      namespace                   = "logging"
      version                     = "0.1.32"
      cloudWatch_logRetentionDays = 30
      logkey                      = "log"
    }

    # Values for the peometheus configurations
    prometheus_conf = {
      namespace            = "prometheus"
      version              = "25.13.0"
      storageClass         = "ebs-sc"
      server_pvcSize       = "20Gi"
      alertmanager_pvcSize = "3Gi"
      ingress = {
        enabled     = "true"
        host        = "prometheus.comprinno.net"
        annotations = {}
      }
    }

    # Values for the grafana configurations
    grafana_conf = {
      namespace        = "grafana"
      version          = "7.3.0"
      pvcSize          = "20Gi" #set the pvc size accordingly
      storageClassName = "ebs-sc"
      ingress = {
        enabled     = "true"
        host        = "grafana.comprinno.net"
        annotations = {}
      }
    }

    # Values for the calico configurations
    calico_conf = {
      namespace  = "kube-system"
      version    = "v3.27.2"
    }

    # Values for the CNI helper configurations
    cni_metrics_helper_conf = {
      version   = "1.16.3"
      namespace = "kube-system"
      loglevel  = "DEBUG" #Log verbosity level (ie. FATAL, ERROR, WARN, INFO, DEBUG)
    }

    # values for kubernetes dashboard
    kubernetes_dashboard_conf = {
      namespace    = "kubernetes-dashboard"
      version      = "6.0.8"
      replicaCount = "1"
      ingress = {
        enabled     = "true"
        host        = "kubernetes-dashboard.comprinno.net"
        annotations = {}
      }
    }

    jaeger_conf = {
      namespace = "jaeger"
      version   = "1.0.2"
      pvcSize          = "20Gi" #set the pvc size accordingly
      storageClassName = "ebs-sc"
      ingress = {
        enabled     = "true"
        host        = "jaeger.comprinno.net"
        annotations = {}
      }
    }


    # Values for Container Insight configuration
    container_insight_conf = {
      namespace = "amazon-metrics"
      version   = "0.22.0"
    }

    # Values for karpenter configuration
    karpenter_conf = {
      namespace            = "kube-system"
      chart                = "karpenter"
      version              = "0.35.2"
      replicas             = "1"
    }
  }
}

//=======================================================================================================
//                              Values for AWS EKS Node Groups
//=======================================================================================================  
# Nodegroup configuration can launch spot nodegroups as well.
node_groups_conf = {
  ondemand = {
    name             = "ondemand-ng"
    desired_capacity = 1
    max_capacity     = 5
    min_capacity     = 1
    # Choose instance types that are supported in the selected region
    instance_types = ["t3a.medium"] #["m5.xlarge"] #, t2.xlarge "t3.large", "t3.xlarge", "m5.large"
  }
  spot = {
    name             = "spot-ng"
    desired_capacity = 1
    max_capacity     = 5
    min_capacity     = 0
    # Choose instance types that are supported in the selected region
    instance_types = ["t3a.medium"] #, t2.xlarge "t3.large", "t3.xlarge", "m5.large"

  }

}

//=======================================================================================================
//                              Values for AWS EFS
//=======================================================================================================  
efs_conf = {
  name                            = "csi-efs"
  backup_policy_status            = "ENABLED",
  encrypted                       = true,
  performance_mode                = "generalPurpose",
  provisioned_throughput_in_mibps = 0,
  throughput_mode                 = "bursting",
  additional_tags                 = {}
}

//=======================================================================================================
//                                Values for Parameter Store Parameters
//=======================================================================================================  
parameters_conf = {
  0 = {
    name = "/CODEBUILD/DOCKER_USER_NAME"
    description = "s3 bucket for configurations"
    type        = "String"                   # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  },
  1 = {
    name = "/CODEBUILD/DOCKER_PASSWD"
    description = "netrc parameter"
    type        = "SecureString"                   # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  },
  2 = {
    name = "/CODEBUILD/ARGOCD_DIR_NAME"
    description = "argocd ssh private key parameter"
    type        = "SecureString"                   # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  },
  3 = {
    name = "/CODEBUILD/ARGOCD_REPOSITORY"
    description = "argocd git repository ssh url parameter"
    type        = "SecureString"                   # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  },
  4 = {
    name = "/CODEBUILD/ARGOCD_REPOSITORY_BRANCH_NAME"
    description = "argocd git repository branch parameter"
    type        = "SecureString"                   # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  }

  5 = {
    name = "/CODEBUILD/ARGOCD-GIT-SSH-KEY"
    description = "argocd ssh private key parameter"
    type        = "SecureString"                   # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  }

}


//=======================================================================================================
//                              Values for AWS ECR
//======================================================================================================= 
ecr_repository_conf = {
  additional_tags = {}

  repositories = {
    0 = {
      # Repo name must be lowercase
      repository_name     = "nginx"
      is_mutable          = false
      enable_scan_on_push = true

    }
  }
}

//=======================================================================================================
//                                Values for CodePipeline/s configuration
//=======================================================================================================  

code_pipeline_conf = {
  #enable_configurations_s3 = false  # By default false,
  pipelines = {
    0 = {
      name            = "nginx" #name of the pipeline
      build_timeout   = "30"
      privileged_mode = true
      compute_type    = "BUILD_GENERAL1_SMALL"
      image           = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
      type            = "ARM_CONTAINER"
      connection_name = "eks-boilerplate-aafaq"
      repository_id   = "aafaq-rashid-comprinno/jenkins-demo"
      branch_name     = "master"
    },
  }
}

```
