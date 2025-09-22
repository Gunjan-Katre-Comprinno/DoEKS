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
resource "helm_release" "efs_csi" {
  name       = "aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  namespace  = "kube-system"

  set = [
    {
      name  = "image.repository"
      value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/eks/aws-efs-csi-driver"
    },
    {
      name  = "controller.serviceAccount.create"
      value = "true"
    },
    {
      name  = "controller.serviceAccount.name"
      value = "efs-csi-controller-sa"
    },
    {
      name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.efs_csi_controller_role.arn
    },
    {
      name  = "useFips"
      value = "false"
    }
  ]
}


resource "kubernetes_storage_class" "efs_csi" {
  depends_on = [helm_release.efs_csi]
  metadata {
    name        = var.efs_csi_conf.storageclass_name
    annotations = {}
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode      = "efs-ap"
    fileSystemId          = "${data.aws_efs_file_system.efs.id}"
    directoryPerms        = "700"
    gidRangeStart         = "1000"                  # optional
    gidRangeEnd           = "2000"                  # optional
    basePath              = "/dynamic_provisioning" # optional
    ensureUniqueDirectory = "true"                  # optional
    reuseAccessPoint      = "false"                 # optional
    #subPathPattern = "${.PVC.namespace}/${.PVC.name}" # optional
  }
}