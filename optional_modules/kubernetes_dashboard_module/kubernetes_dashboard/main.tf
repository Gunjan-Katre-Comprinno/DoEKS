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
//                    Namespace of Kubernetes Dashboard
//==================================================================================
resource "kubernetes_namespace" "kubernetes_dashboard" {
  count = (var.kubernetes_dashboard_conf.namespace != "kube-system" &&
  var.kubernetes_dashboard_conf.namespace != "default") ? 1 : 0
  metadata {
    name = var.kubernetes_dashboard_conf.namespace
    labels = {
      "name" = var.kubernetes_dashboard_conf.namespace
    }
  }
}

//==================================================================================
//                    Helm provisioner for Kubernetes Dashboard
//==================================================================================
resource "helm_release" "kubernetes_dashboard" {
  depends_on = [kubernetes_namespace.kubernetes_dashboard[0]]
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  namespace  = var.kubernetes_dashboard_conf.namespace
  version    = var.kubernetes_dashboard_conf.version

  set = [
    {
      name  = "metricsScraper.enabled"
      value = "true"
      }, {
      name  = "ingress.enabled"
      value = var.kubernetes_dashboard_conf.ingress.enabled
    },
    {
      name  = "ingress.className"
      value = "alb"
    },
    {
      name  = "ingress.hosts[0]"
      value = var.kubernetes_dashboard_conf.ingress.host
    },
    {
      name  = "service.externalPort"
      value = 443
    },
    {
      name  = "ingress.paths[0]"
      value = "/"
    },

    {
      name  = "replicaCount"
      value = var.kubernetes_dashboard_conf.replicaCount
    },
    {
      name  = "rbac.clusterReadOnlyRole"
      value = "true"
    }
  ]
  values = [data.template_file.dashboard_values.rendered]
}


//==================================================================================
//                    Render Helm values from template
//==================================================================================
data "template_file" "dashboard_values" {
  template = file("${path.module}/values.yaml")

  vars = {
    annotations = jsonencode(merge(
      try(var.kubernetes_dashboard_conf.ingress.annotations, {}),
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
        "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
        "kubernetes.io/ingress.class"                = "alb"
        "alb.ingress.kubernetes.io/healthcheck-path" = "/"
        "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
        "alb.ingress.kubernetes.io/group.name"       = "eks.apps"
        "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      }
    ))
  }
}

# create token
#kubectl create token kubernetes-dashboard -n kubernetes-dashboard