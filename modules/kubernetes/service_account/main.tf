# Create Namespace for service account
resource "kubernetes_namespace" "service_account" {
  count = (var.service_account_conf.name != "kube-system" &&
  var.service_account_conf.name != "default") ? 1 : 0
  metadata {
    name = var.service_account_conf.namespace
    labels = {
      "name" = var.service_account_conf.namespace
    }
  }
}

# Create a kubernetes service account
resource "kubernetes_service_account" "my_service_account" {
  depends_on = [kubernetes_namespace.service_account, aws_iam_role.service_account_role]
  metadata {
    name      = var.service_account_conf.name
    namespace = kubernetes_namespace.service_account[0].metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.service_account_role.arn
    }
  }
}