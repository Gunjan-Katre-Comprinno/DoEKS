resource "kubectl_manifest" "aws_auth" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: aws-auth
      namespace: kube-system
    data:
      mapRoles: |
        - groups:
          - system:bootstrappers
          - system:nodes
          rolearn: ${data.aws_iam_role.node_role.arn}
          username: system:node:{{EC2PrivateDNSName}}
        - groups:
          - system:bootstrappers
          - system:nodes
          rolearn: ${aws_iam_role.karpenter_instance_node_role.arn}
          username: system:node:{{EC2PrivateDNSName}}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}