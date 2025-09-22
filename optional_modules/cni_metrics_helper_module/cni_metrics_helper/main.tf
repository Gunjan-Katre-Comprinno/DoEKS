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

// https://artifacthub.io/packages/helm/aws/cni-metrics-helper
resource "helm_release" "cni_metrics_helper" {
  depends_on = [aws_iam_role.cni_metrics_helper_role]
  name       = "cni-metrics-helper"
  repository = "https://aws.github.io/eks-charts"
  chart      = "cni-metrics-helper"
  version    = var.cni_metrics_helper_conf.version
  namespace  = var.cni_metrics_helper_conf.namespace

  set = [
    {
      // https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
      name  = "image.region"
      value = var.region
    }

    , {
      name  = "image.account"
      value = lookup(var.public_image_account, var.region, "602401143452")
    },
    {
      name  = "env.USECLOUDWATCH"
      value = true
    },
    {
      name  = "env.USE_PROMETHEUS"
      value = "true"
    },
    {
      name  = "env.AWS_CLUSTER_ID"
      value = var.cluster_name
    },
    {
      name  = "env.AWS_VPC_K8S_CNI_LOGLEVEL"
      value = var.cni_metrics_helper_conf.loglevel
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.cni_metrics_helper_role.arn
    },
    {
      name  = "resources.limits.cpu"
      value = "200m"
    },
    {
      name  = "resources.limits.memory"
      value = "256Mi"
    }
  ]
}


# https://aws.amazon.com/blogs/opensource/cni-metrics-helper/