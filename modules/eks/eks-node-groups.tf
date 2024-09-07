resource "aws_iam_role" "nodes_general" {
  name = "nodes_general"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "secrets_manager_access" {
  name = "secrets_manager_access"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect = "Allow"
        Resource = [
          var.stockzrs_secrets_configs.stockzrs_relay.arn,
          var.stockzrs_secrets_configs.stockzrs_frontend.arn,
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "route53_cert_manager" {
  name        = "route53_cert_manager_policy"
  path        = "/"
  description = "Policy for Route 53 cert-manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:GetChange",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/*",
          "arn:aws:route53:::change/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "route53:ListHostedZonesByName"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "route53_cert_manager" {
  policy_arn = aws_iam_policy.route53_cert_manager.arn
  role       = aws_iam_role.nodes_general.name
}

# resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
#   policy_arn = aws_iam_policy.secrets_manager_access.arn
#   role       = aws_iam_role.nodes_general.name
# }

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes_general.name
}


resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes_general.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes_general.name
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  version         = "1.30"
  node_group_name = "general"
  node_role_arn   = aws_iam_role.nodes_general.arn

  subnet_ids = [
    var.stockzrs_subnets.private[0].id,
    var.stockzrs_subnets.private[1].id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.route53_cert_manager
  ]
}