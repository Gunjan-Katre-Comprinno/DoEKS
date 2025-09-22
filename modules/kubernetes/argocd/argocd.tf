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
//                    Namespace for ArgoCD
//==================================================================================
resource "kubernetes_namespace" "argocd" {
  count = (var.argocd_conf.namespace != "kube-system" &&
  var.argocd_conf.namespace != "default") ? 1 : 0
  metadata {
    name = var.argocd_conf.namespace
    labels = {
      "name" = var.argocd_conf.namespace
    }
  }
}

//==================================================================================
//                    Helm provisioner for ArgoCD
//==================================================================================
resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace.argocd[0]]
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.argocd_conf.namespace
  version    = var.argocd_conf.version

  set = [
    {
      name  = "server.ingress.enabled"
      value = var.argocd_conf.ingress.enabled
    },
    {
      name  = "server.ingress.hostname"
      value = var.argocd_conf.ingress.host
    }
  ]
  values = [data.template_file.argocd_values.rendered]
}

//==================================================================================
//                    Render Helm values from template
//==================================================================================
data "template_file" "argocd_values" {
  template = file("${path.module}/values.yaml")

  vars = {
    annotations = jsonencode(merge(
      try(var.argocd_conf.ingress.annotations, {}),
      {
        "alb.ingress.kubernetes.io/listen-ports" = jsonencode([
          { "HTTP" : 80 },
          { "HTTPS" : 443 }
        ])
        "alb.ingress.kubernetes.io/load-balancer-name" = "${var.cluster_name}-alb"
        "alb.ingress.kubernetes.io/certificate-arn"    = "${var.elb_certificate_arn}"

        "alb.ingress.kubernetes.io/listen-ports"         = <<JSON
            [
              {"HTTP":80},
              {"HTTPS":443}    
            ]
          JSON
        "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
        "alb.ingress.kubernetes.io/target-type"          = "ip"
        "kubernetes.io/ingress.class"                    = "alb"
        "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTPS"
        "alb.ingress.kubernetes.io/backend-protocol"     = "HTTPS"
        "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
        "alb.ingress.kubernetes.io/group.name"           = "eks.apps"
        "alb.ingress.kubernetes.io/ssl-policy"           = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      }
    ))
  }
}