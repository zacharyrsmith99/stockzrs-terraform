resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "eks" {
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  name     = "eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.29"

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

resource "kubernetes_namespace" "stockzrs_relay_service" {
  metadata {
    name = "stockzrs-relay-service"
    labels = {
      name        = "stockzrs-relay-service"
      environment = "production"
    }
  }
}

resource "kubernetes_manifest" "github_actions_cluster_role" {
  manifest = yamldecode(file("${path.module}/k8s/cluster-roles/github-actions-cluster-role.yaml"))

  depends_on = [aws_eks_cluster.eks]
}

resource "kubernetes_manifest" "github_actions_cluster_role_binding" {
  manifest = yamldecode(file("${path.module}/k8s/cluster-roles/github-actions-cluster-role-binding.yaml"))

  depends_on = [kubernetes_manifest.github_actions_cluster_role]
}
