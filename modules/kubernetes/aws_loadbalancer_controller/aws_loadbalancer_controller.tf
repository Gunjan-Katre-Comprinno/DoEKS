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

// Please refer the link for any updates, or AWS Load Balancer Controller documentation: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
resource "kubernetes_namespace" "loadbalancer_controller_namespace" {
  count = (var.loadbalancer_controller_conf.namespace != "kube-system" &&
  var.loadbalancer_controller_conf.namespace != "default") ? 1 : 0
  metadata {
    name = var.loadbalancer_controller_conf.namespace
    labels = {
      "name" = var.loadbalancer_controller_conf.namespace
    }
  }
}
resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = var.loadbalancer_controller_conf.namespace
  version    = var.loadbalancer_controller_conf.version

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "image.repository"
      value = "public.ecr.aws/eks/aws-load-balancer-controller"
    },
    {
      name  = "rbac.create"
      value = "true"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.lb_controller_role.arn
    },
    {
      name  = "enableShield"
      value = "false"
    },
    {
      name  = "enableWaf"
      value = "false"
    },
    {
      name  = "enableWafv2"
      value = "false"
    }
  ]
}


//=======================================================================================================
//                             Custom Resource Definitions
// Run the following null resource to install the TargetGroupBinding custom resource definitions.
// Please read more https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html                            
//=======================================================================================================
resource "null_resource" "crd" {
  depends_on = [
    helm_release.lb_controller
  ]
  triggers = {
    cluster_name = "${var.cluster_name}"
    region       = var.region
  }
  provisioner "local-exec" {
    working_dir = "./"
    command     = "aws eks update-kubeconfig --region ${self.triggers.region} --name ${self.triggers.cluster_name}"
  }

  provisioner "local-exec" {
    working_dir = "./"
    command     = "kubectl apply --validate=false -f https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.7.2/v2_7_2_full.yaml"
  }
}