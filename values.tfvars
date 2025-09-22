region      = "us-east-1"
environment = "testing"

# Flags to control the creation of resources
create = {
  spark_operator = true
  yunikorn = true
}

# Certificate Arn used for creating loadbalancers
elb_certificate_arn = "arn:aws:acm:us-east-1:785975698029:certificate/4f80e5f3-49f0-4201-95a2-0253459898ae"

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
    eks_kubernetes_version = "1.31"
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

    # AMI Configuration Options:
    # Set use_latest_ami = true to automatically use the latest EKS-optimized AMI
    # Set use_latest_ami = false to use a custom AMI specified in image_id
    use_latest_ami = true

    # AMI Type - Specifies the AMI type for EKS nodes
    # Available options:
    # - "amazon-linux-2023/x86_64/standard"  # AL2023 x86 standard instances
    # - "amazon-linux-2023/x86_64/nvidia"    # AL2023 NVIDIA x86 instances  
    # - "amazon-linux-2023/arm64/standard"   # AL2023 ARM instances (Graviton)
    # - "amazon-linux-2023/arm64/nvidia"     # AL2023 NVIDIA ARM instances
    # - "amazon-linux-2023/x86_64/neuron"    # AL2023 AWS Neuron instances
    # - "amazon-linux-2"                     # AL2 x86 instances
    # - "amazon-linux-2-arm64"               # AL2 ARM instances (Graviton)
    # - "amazon-linux-2-gpu"                 # AL2 GPU/Inferentia/Trainium instances
    ami_type = "amazon-linux-2023/x86_64/standard"

    # Custom AMI ID - Used when use_latest_ami = false
    # This is region specific and AMI should be available in that region
    # EKS optimized public AMI managed by AWS built on top of Amazon Linux 2 is being used.
    # Retrieving Amazon EKS optimized Amazon Linux AMI IDs from this document: 
    # https://docs.aws.amazon.com/eks/latest/userguide/retrieve-ami-id.html
    #image_id = "ami-00a2c6fcb070edafc" # Kubernetes version 1.28 compatible Amazon Linux AMI ID.

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
      version   = "3.13.0"
    }

    # Values for the AWS Loadbalancer Controller configurations
    aws_loadbalancer_controller_conf = {
      namespace = "kube-system"
      version   = "1.13.4"
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
      version   = "8.3.3"
      ingress = {
        enabled     = "true"
        host        = "argocd.comprinno.net"
        annotations = {}
      }
    }

    # Values for the fluentbit configurations
    fluentbit_conf = {
      namespace                   = "logging"
      version                     = "0.1.35"
      cloudWatch_logRetentionDays = 30
      logkey                      = "log"
    }

    # Values for the prometheus configurations
    prometheus_conf = {
      namespace            = "prometheus"
      version              = "26.1.0"
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
      version          = "8.8.2"
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
      namespace = "kube-system"
      version   = "v3.27.2"
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
      version      = "7.10.1"
      replicaCount = "1"
      ingress = {
        enabled     = "true"
        host        = "kubernetes-dashboard.comprinno.net"
        annotations = {}
      }

    }

    jaeger_conf = {
      namespace        = "jaeger"
      version          = "1.0.2"
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
      namespace = "karpenter"
      version   = "1.5.0"
      replicas  = 2
    }

    # Values for the spark operator configurations
    spark_operator_conf = {
      sparkJobNamespace = "spark-operator"
      image = {
        repository = "kubeflow/spark-operator"
        tag        = "2.1.1"
      }
      serviceAccount = {
        create = true
        name   = "spark-operator-sa"
      }
      metrics = {
        enabled = true
        service = {
          annotations = {
            "prometheus.io/scrape" = "true"
            "prometheus.io/port"   = "8080"
          }
        }
      }
    }

    # Values for YuniKorn scheduler configuration
    yunikorn_conf = {
      namespace = "yunikorn-system"
      queues = {
        root = {
          submitacl = "*"
          queues = {
            production = {
              resources = {
                guaranteed = {
                  memory = "100Gi"
                  vcore  = "50"
                }
                max = {
                  memory = "200Gi"
                  vcore  = "100"
                }
              }
              submitacl = "spark-production"
            }
            development = {
              resources = {
                guaranteed = {
                  memory = "50Gi"
                  vcore  = "25"
                }
                max = {
                  memory = "100Gi"
                  vcore  = "50"
                }
              }
              submitacl = "spark-dev"
            }
          }
        }
      }
    }

    # Values for Volcano scheduler configuration
    volcano_conf = {
      namespace = "volcano-system"
      queues = {
        default = {
          weight = 1
          capability = {
            cpu    = "1000"
            memory = "1000Gi"
          }
          reclaimable = true
        }
        ml-training = {
          weight = 3
          capability = {
            cpu    = "2000"
            memory = "2000Gi"
          }
          reclaimable = true
        }
        hpc-batch = {
          weight = 2
          capability = {
            cpu    = "1500"
            memory = "1500Gi"
          }
          reclaimable = true
        }
        dev = {
          weight = 1
          capability = {
            cpu    = "500"
            memory = "500Gi"
          }
          reclaimable = true
        }
      }
      plugins = ["gang", "priority", "conformance", "drf", "predicates", "proportion", "nodeorder"]
      actions = ["enqueue", "allocate", "backfill"]
    }
  }
}


//=======================================================================================================
//                              Values for AWS EKS Node Groups (Dynamic Configuration)
//=======================================================================================================  
# Dynamic node group configuration - supports unlimited number of node groups
# Each node group is defined as a map entry with customizable properties
node_groups_conf = {

  # ========== ON-DEMAND NODE GROUP ==========
  ondemand = {
    # Required: Node group identifier (used in resource naming)
    name = "ondemand-ng"

    # Required: Capacity type - "on_demand" or "spot"
    capacity_type = "on_demand"

    # Required: Auto Scaling configuration
    desired_capacity = 1 # Initial number of nodes
    max_capacity     = 5 # Maximum nodes for scaling
    min_capacity     = 1 # Minimum nodes (0 for spot groups)

    # Required: EC2 instance types (array supports multiple types for flexibility)
    # Choose instances supported in your selected region
    instance_types = ["t3a.medium"] # Options: t3.medium, m5.large, c5.xlarge, etc.

    # Optional: AMI type for this node group (overrides global setting)
    ami_type = "amazon-linux-2"


    # Optional: AMI selection method
    # use_latest_ami = true   # true = fetch latest from SSM, false = use custom image_id
    # image_id = "ami-12345"  # Custom AMI ID (used when use_latest_ami = false)

    # Optional: Storage configuration
    # root_volume_size = 30              # EBS root volume size in GB
    # volume_type = "gp3"                # EBS volume type: gp2, gp3, io1, io2

    # Optional: Monitoring
    # enhanced_monitoring_enabled = true  # CloudWatch detailed monitoring (extra cost)

    # Optional: Kubernetes node labels
    # labels = {
    #   "node.kubernetes.io/instance-type" = "standard"
    #   "environment" = "production"
    # }

    # Optional: Kubernetes node taints
    # taints = {
    #   dedicated = {
    #     key    = "dedicated"
    #     value  = "gpuGroup"
    #     effect = "NO_SCHEDULE"
    #   }
    # }

    # Optional: Update configuration
    # update_config = {
    #   max_unavailable_percentage = 25  # Percentage of nodes unavailable during updates
    # }

    # Optional: Bootstrap customization
    # bootstrap_extra_args = "--container-runtime containerd"
    # kubelet_extra_args = "--max-pods=110"

    # Optional: Additional AWS resource tags
    # additional_tags = {
    #   "Project" = "MyProject"
    #   "Owner"   = "TeamName"
    # }
  }

  # # ========== SPOT NODE GROUP ==========
  # spot = {
  #   name             = "spot-ng"
  #   capacity_type    = "spot"
  #   desired_capacity = 1
  #   max_capacity     = 5
  #   min_capacity     = 0      # Spot instances can scale to 0
  #   instance_types   = ["t3a.medium", "t3.medium"]  # Multiple types for better spot availability
  #   ami_type         = "amazon-linux-2023/x86_64/standard"
  # }

  # ========== GPU NODE GROUP EXAMPLE (Commented) ==========
  # gpu_ondemand = {
  #   name             = "gpu-ng"
  #   capacity_type    = "on_demand"
  #   desired_capacity = 0
  #   max_capacity     = 3
  #   min_capacity     = 0
  #   instance_types   = ["g4dn.xlarge", "g4dn.2xlarge"]
  #   ami_type         = "amazon-linux-2023/x86_64/nvidia"
  #   root_volume_size = 100  # Larger storage for GPU workloads
  #   labels = {
  #     "accelerator" = "nvidia-tesla-t4"
  #     "node.kubernetes.io/instance-type" = "gpu"
  #   }
  #   taints = {
  #     nvidia_gpu = {
  #       key    = "nvidia.com/gpu"
  #       value  = "true"
  #       effect = "NO_SCHEDULE"
  #     }
  #   }
  # }

  # ========== ARM GRAVITON NODE GROUP EXAMPLE (Commented) ==========
  # arm_spot = {
  #   name             = "graviton-spot-ng"
  #   capacity_type    = "spot"
  #   desired_capacity = 0
  #   max_capacity     = 5
  #   min_capacity     = 0
  #   instance_types   = ["m6g.medium", "m6g.large", "c6g.large"]
  #   ami_type         = "amazon-linux-2023/arm64/standard"
  #   labels = {
  #     "kubernetes.io/arch" = "arm64"
  #     "node.kubernetes.io/instance-type" = "graviton"
  #   }
  # }

  # ========== MIXED INSTANCE TYPE EXAMPLE (Commented) ==========
  # mixed_workload = {
  #   name             = "mixed-ng"
  #   capacity_type    = "spot"
  #   desired_capacity = 2
  #   max_capacity     = 10
  #   min_capacity     = 1
  #   instance_types   = ["m5.large", "m5a.large", "m4.large", "c5.large"]
  #   ami_type         = "amazon-linux-2023/x86_64/standard"
  #   labels = {
  #     "workload-type" = "mixed"
  #   }
  # }
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
    name        = "/CODEBUILD/DOCKER_USER_NAME"
    description = "s3 bucket for configurations"
    type        = "String" # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  },
  1 = {
    name        = "/CODEBUILD/DOCKER_PASSWD"
    description = "netrc parameter"
    type        = "SecureString" # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  },
  2 = {
    name        = "/CODEBUILD/ARGOCD_DIR_NAME"
    description = "argocd ssh private key parameter"
    type        = "SecureString" # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  },
  3 = {
    name        = "/CODEBUILD/ARGOCD_REPOSITORY"
    description = "argocd git repository ssh url parameter"
    type        = "SecureString" # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  },
  4 = {
    name        = "/CODEBUILD/ARGOCD_REPOSITORY_BRANCH_NAME"
    description = "argocd git repository branch parameter"
    type        = "SecureString" # Valid types are String, StringList and SecureString.
    value       = "Please provide the exact value"
  }

  5 = {
    name        = "/CODEBUILD/ARGOCD-GIT-SSH-KEY"
    description = "argocd ssh private key parameter"
    type        = "SecureString" # Valid types are String, StringList and SecureString.
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



