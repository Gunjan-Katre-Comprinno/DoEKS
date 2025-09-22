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

//==================================================================================
//                    Namespce for container-insight
//==================================================================================

resource "kubernetes_namespace" "container_insight" {
  count = (var.container_insight_conf.namespace != "kube-system" &&
  var.container_insight_conf.namespace != "default") ? 1 : 0
  metadata {
    name = var.container_insight_conf.namespace
    labels = {
      "name" = var.container_insight_conf.namespace
    }
  }
}


//==================================================================================
//                    Helm provisioner for Container Insight
//==================================================================================
resource "helm_release" "container_insight" {
  depends_on = [kubernetes_namespace.container_insight]
  name       = "container-insight"
  repository = "https://aws-observability.github.io/aws-otel-helm-charts"
  chart      = "adot-exporter-for-eks-on-ec2"
  namespace  = var.container_insight_conf.namespace
  version    = var.container_insight_conf.version
  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "awsRegion"
      value = var.region
    }
  ]
  values = [data.template_file.container_insight_values.rendered]
}


//==================================================================================
//                    Render Helm values from template
//==================================================================================
data "template_file" "container_insight_values" {
  template = file("${path.module}/values.yaml")

  vars = {
    namespace = var.container_insight_conf.namespace
  }
}


