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

resource "kubernetes_namespace" "calico" {
  count = (var.calico_conf.namespace != "kube-system" &&
  var.calico_conf.namespace != "default") ? 1 : 0
  metadata {
    name = var.calico_conf.namespace
    labels = {
      "name" = var.calico_conf.namespace
    }
  }
}

//=====================================================================================================================================
// Since this cluster will use Calico for networking, you must delete the aws-node daemon set to disable AWS VPC networking for pods.
//=====================================================================================================================================
resource "null_resource" "delete" {

  triggers = {
    cluster_name = var.cluster_name
    region       = var.region
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl delete daemonset -n kube-system aws-node
    EOT
  }
}

//=====================================================================================================================================
// Install version v3.xx.x of the Calico operator and custom resource definitions.
//=====================================================================================================================================
resource "helm_release" "calico" {
  depends_on = [kubernetes_namespace.calico[0], null_resource.delete]
  name       = "calico"
  repository = "https://docs.projectcalico.org/charts"
  chart      = "tigera-operator"
  version    = var.calico_conf.version
  namespace  = var.calico_conf.namespace
}


//=====================================================================================================================================
// Patch the CNI type with value Calico.
//=====================================================================================================================================                           
resource "null_resource" "patch" {
  depends_on = [
    helm_release.calico
  ]

  triggers = {
    cluster_name = var.cluster_name
    region       = var.region
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --region "${self.triggers.region}" --name "${self.triggers.cluster_name}" &&
      kubectl patch installation default --type='json' -p='[{"op": "replace", "path": "/spec/cni", "value": {"type":"Calico"} }]'
    EOT
  }
}
