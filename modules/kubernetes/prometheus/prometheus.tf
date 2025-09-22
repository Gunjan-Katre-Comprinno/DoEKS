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

resource "kubernetes_namespace" "prometheus" {
  count = (var.prometheus_conf.namespace != "kube-system" &&
  var.prometheus_conf.namespace != "default") ? 1 : 0
  metadata {
    name = var.prometheus_conf.namespace
    labels = {
      "name" = var.prometheus_conf.namespace
    }
  }
}

resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace.prometheus[0]]

  name       = "prometheus"
  namespace  = var.prometheus_conf.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_conf.version
  timeout    = 360

  set = [
    {
      name  = "alertmanager.persistence.storageClass"
      value = var.prometheus_conf.storageClass
    },
    {
      name  = "server.persistentVolume.storageClass"
      value = var.prometheus_conf.storageClass
    },
    {
      name  = "server.persistentVolume.size"
      value = var.prometheus_conf.server_pvcSize
    },
    {
      name  = "alertmanager.persistence.enabled"
      value = "true"
    },
    {
      name  = "alertmanager.persistence.size"
      value = var.prometheus_conf.alertmanager_pvcSize
    },
    {
      name  = "server.ingress.enabled"
      value = var.prometheus_conf.ingress.enabled
    },
    {
      name  = "server.ingress.hosts[0]"
      value = var.prometheus_conf.ingress.host
    }
  ]

  values = [
    data.template_file.prometheus_values.rendered
  ]
}



//==================================================================================
//                    Render Helm values from template
//==================================================================================
data "template_file" "prometheus_values" {
  template = file("${path.module}/values.yaml")

  vars = {
    annotations = jsonencode(merge(
      try(var.prometheus_conf.ingress.annotations, {}),
      {
        "alb.ingress.kubernetes.io/listen-ports" = jsonencode([
          { "HTTP" : 80 },
          { "HTTPS" : 443 }
        ])
        "alb.ingress.kubernetes.io/load-balancer-name" = "${var.cluster_name}-alb"
        "alb.ingress.kubernetes.io/certificate-arn"    = "${var.elb_certificate_arn}"

        "alb.ingress.kubernetes.io/listen-ports"     = <<JSON
            [
              {"HTTP":80},
              {"HTTPS":443}    
            ]
          JSON
        "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
        "alb.ingress.kubernetes.io/target-type"      = "ip"
        "kubernetes.io/ingress.class"                = "alb"
        "alb.ingress.kubernetes.io/healthcheck-path" = "/graph"
        "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
        "alb.ingress.kubernetes.io/group.name"       = "eks.apps"
        "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      }
    ))
  }
}