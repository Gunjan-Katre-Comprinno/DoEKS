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

resource "kubernetes_namespace" "fluentbit" {
  count = (var.fluentbit_conf.namespace != "monitoring" &&
  var.fluentbit_conf.namespace != "default") ? 1 : 0
  metadata {
    name = var.fluentbit_conf.namespace
    labels = {
      "name" = var.fluentbit_conf.namespace
    }
  }
}
resource "helm_release" "fluentbit" {
  depends_on = [kubernetes_namespace.fluentbit[0]]

  name       = "fluent-bit"
  namespace  = var.fluentbit_conf.namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = var.fluentbit_conf.version

  set = [
    {
      name  = "global.namespaceOverride"
      value = var.fluentbit_conf.namespace
    },
    {
      name  = "cloudWatchLogs.logGroupTemplate"
      value = "/aws/eks/${var.cluster_name}/namespace/$kubernetes['namespace_name']"
    },
    {
      name  = "cloudWatchLogs.logStreamTemplate"
      value = "$kubernetes['pod_name']"
    },
    {
      name  = "cloudWatchLogs.enabled"
      value = "true"
    },
    {
      name  = "cloudWatchLogs.logGroupName"
      value = "/aws/eks/${var.cluster_name}/logs"
    },
    {
      name  = "cloudWatchLogs.region"
      value = var.region
    },
    {
      name  = "cloudWatchLogs.logKey"
      value = var.fluentbit_conf.logkey
    },
    {
      name  = "cloudWatchLogs.logRetentionDays"
      value = var.fluentbit_conf.cloudWatch_logRetentionDays
    },
    {
      name  = "firehose.enabled"
      value = "false"
    },
    {
      name  = "kinesis.enabled"
      value = "false"
    },
    {
      name  = "elasticsearch.enabled"
      value = "false"
    }
  ]


}


