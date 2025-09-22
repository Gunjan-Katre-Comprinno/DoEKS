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

terraform {
  required_version = ">= 1.7"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

//==================================================================================
//                    SQS Queue for Spot Interruption
//==================================================================================
resource "aws_sqs_queue" "karpenter" {
  name                      = "${var.environment}-${var.cluster_name}-karpenter"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-karpenter"
    Environment = var.environment
    Cluster     = var.cluster_name
    Component   = "karpenter"
  }
}

resource "aws_sqs_queue_policy" "karpenter" {
  queue_url = aws_sqs_queue.karpenter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "events.amazonaws.com",
            "sqs.amazonaws.com"
          ]
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter.arn
      }
    ]
  })
}

//==================================================================================
//                    EventBridge Rules for Node Lifecycle
//==================================================================================
resource "aws_cloudwatch_event_rule" "karpenter_spot_interruption" {
  name = "${var.environment}-${var.cluster_name}-karpenter-spot-interruption"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Spot Instance Interruption Warning"]
  })

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-karpenter-spot-interruption"
    Environment = var.environment
    Cluster     = var.cluster_name
    Component   = "karpenter"
  }
}

resource "aws_cloudwatch_event_target" "karpenter_spot_interruption" {
  rule      = aws_cloudwatch_event_rule.karpenter_spot_interruption.name
  target_id = "KarpenterSpotInterruption"
  arn       = aws_sqs_queue.karpenter.arn
}

resource "aws_cloudwatch_event_rule" "karpenter_instance_state_change" {
  name = "${var.environment}-${var.cluster_name}-karpenter-instance-state-change"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
  })

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-karpenter-instance-state-change"
    Environment = var.environment
    Cluster     = var.cluster_name
    Component   = "karpenter"
  }
}

resource "aws_cloudwatch_event_target" "karpenter_instance_state_change" {
  rule      = aws_cloudwatch_event_rule.karpenter_instance_state_change.name
  target_id = "KarpenterInstanceStateChange"
  arn       = aws_sqs_queue.karpenter.arn
}

//==================================================================================
//                    Namespce for karpenter
//==================================================================================
resource "kubernetes_namespace" "karpenter" {
  count = (var.karpenter_conf.namespace != "kube-system" &&
  var.karpenter_conf.namespace != "default") ? 1 : 0
  metadata {
    name = var.karpenter_conf.namespace
    labels = {
      "name" = var.karpenter_conf.namespace
    }
  }
}

//==================================================================================
//                    Helm provisioner for karpenter
//==================================================================================
resource "helm_release" "karpenter" {
  depends_on          = [kubernetes_namespace.karpenter[0]]
  namespace           = var.karpenter_conf.namespace
  name                = "karpenter"
  chart               = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  version             = var.karpenter_conf.version
  set = [
    {
      name  = "replicas"
      value = var.karpenter_conf.replicas
    },
    {
      name  = "settings.clusterName"
      value = var.cluster_name
    },
    {
      name  = "settings.interruptionQueue"
      value = aws_sqs_queue.karpenter.name
    },
    {
      name  = "settings.featureGates.drift"
      value = "true"
    },
    {
      name  = "settings.featureGates.spotToSpotConsolidation"
      value = "true"
    },
    {
      name  = "controller.resources.requests.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.requests.memory"
      value = "1Gi"
    },
    {
      name  = "controller.resources.limits.cpu"
      value = "2"
    },
    {
      name  = "controller.resources.limits.memory"
      value = "2Gi"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.karpenter_controller_role.arn
    },
    {
      name  = "dnsPolicy"
      value = "Default"
    },
    {
      name  = "logLevel"
      value = "info"
    }
  ]
  values = [
    templatefile("${path.module}/values.yaml",
      {
        nodeGroupName = var.node_group_name
      }
    )
  ]
}



resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      role: ${aws_iam_role.karpenter_instance_node_role.name}
      amiSelectorTerms:
        - alias: al2023@latest
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          requirements:
            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]
            - key: kubernetes.io/os
              operator: In
              values: ["linux"]
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["on-demand"]
            - key: karpenter.k8s.aws/instance-category
              operator: In
              values: ["c", "m", "r"]
            - key: karpenter.k8s.aws/instance-generation
              operator: Gt
              values: ["2"]
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: default
          expireAfter: 720h
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenEmptyOrUnderutilized
        consolidateAfter: 1m
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}


 