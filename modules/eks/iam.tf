
//=======================================================================================================
//                                            Node Cluster Role
//                               IAM Role to be used for the nodes within EKS Cluster
//=======================================================================================================

resource "aws_iam_role" "eks_node_role" {
  name               = "${var.environment}-${var.eks_conf.cluster.cluster_name}-node-role"
  description        = "IAM Role to be used for the nodes within EKS cluster"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = merge(
    {
      Name        = "${var.environment}-${var.eks_conf.cluster.cluster_name}-node-role"
      Environment = var.environment
    },
    try(var.eks_conf.cluster.additional_tags, {})
  )

}

//=======================================================================================================
//                                               Creating Instance Profile
//=======================================================================================================

resource "aws_iam_instance_profile" "eks_instance_role_profile" {
  name = "${var.environment}-${var.eks_conf.cluster.cluster_name}-node-role"
  role = aws_iam_role.eks_node_role.name
}

//=======================================================================================================
//                           Attach following AWS Managed Policies to EKS Node Role
//=======================================================================================================

resource "aws_iam_role_policy_attachment" "attach_amazon_eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "attach_amazon_ecr_ro_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "attach_amazon_eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "attach_ssm_managed_instance_core_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "aws_cloudwatch_logs_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

//=======================================================================================================
//                               IAM Role to be used by the Cluster
//=======================================================================================================

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.environment}-${var.eks_conf.cluster.cluster_name}-cluster-role"
  description        = "IAM Role to be used by EKS cluster"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "EKSClusterAssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF
  tags = merge(
    {
      Name        = "${var.environment}-${var.eks_conf.cluster.cluster_name}-cluster-role"
      Environment = var.environment
    },
    try(var.eks_conf.cluster.additional_tags, {})
  )
}

//=======================================================================================================
//                             Attach following Policies to EKS Cluster Role
//=======================================================================================================
resource "aws_iam_role_policy_attachment" "attach_amazon_eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "attach_amazon_eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "attach_amazon_eks_vpc_controller_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}