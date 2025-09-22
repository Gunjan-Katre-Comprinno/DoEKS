MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -e

# Detect AMI type at runtime by checking OS version
if grep -q "Amazon Linux 2023" /etc/os-release; then
    # AL2023 - Use nodeadm
    cat > /tmp/nodeadm-config.yaml << 'EOF'
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_name}
    apiServerEndpoint: ${endpoint}
    certificateAuthority: ${cluster_auth_base64}
    cidr: ${cluster_service_cidr}
  kubelet:
    config:
      clusterDNS:
        - 172.20.0.10
%{ if kubelet_extra_args != "" ~}
    flags:
      - ${kubelet_extra_args}
%{ endif ~}
EOF
    /usr/bin/nodeadm init --config-source file:///tmp/nodeadm-config.yaml
else
    # AL2 - Use bootstrap.sh
    /etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' ${bootstrap_extra_args} --kubelet-extra-args "${kubelet_extra_args}" '${cluster_name}'
fi

--//--
