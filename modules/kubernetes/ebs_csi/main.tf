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



//=======================================================================================================
//                               Helm for EBS CSI Controller 
//=======================================================================================================

resource "helm_release" "ebs_csi" {
  name       = "aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  namespace  = "kube-system"

  set = [
    {
      name  = "image.repository"
      value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/eks/aws-ebs-csi-driver"
    },
    {
      name  = "controller.serviceAccount.create"
      value = "true"
    },
    {
      name  = "controller.serviceAccount.name"
      value = "ebs-csi-controller"
    },
    {
      name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.ebs_csi_controller_role.arn
    },
    {
      name  = "controller.k8sTagClusterId"
      value = var.cluster_name
    }
  ]
}


resource "kubernetes_storage_class" "ebs_csi" {
  depends_on = [helm_release.ebs_csi]
  metadata {
    name = var.ebs_csi_conf.storageclass_name
    # annotations = {
    #   "storageclass.kubernetes.io/is-default-class" = "true"
    # }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    "csi.storage.k8s.io/fstype" = "ext4"
    type                        = "gp3"
    encrypted                   = true
    kmsKeyId                    = data.aws_kms_key.ebs.arn
  }
}