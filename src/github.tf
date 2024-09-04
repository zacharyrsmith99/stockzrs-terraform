data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-eks-access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:zacharyrsmith99/stockzrs-relay-service:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_access" {
  name        = "github-actions-eks-access-policy"
  path        = "/"
  description = "IAM policy for GitHub Actions to access EKS and manage Kubernetes resources"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:ListFargateProfiles",
          "eks:DescribeFargateProfile",
          "eks:ListIdentityProviderConfigs",
          "eks:DescribeIdentityProviderConfig",
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:ListTagsForResource",
          "eks:DescribeVpcConfig"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_eks_access" {
  policy_arn = aws_iam_policy.eks_access.arn
  role       = aws_iam_role.github_actions.name
}


resource "aws_iam_role_policy_attachment" "github_actions_eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.github_actions.name
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = aws_iam_role.github_actions.arn
  kubernetes_groups = ["github-actions"]
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}


resource "github_actions_secret" "aws_account_id" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "AWS_ACCOUNT_ID"
  plaintext_value = data.aws_caller_identity.current.account_id
}

resource "github_actions_secret" "aws_region" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_secret" "ec2_user_name" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "EC2_USER_NAME"
  plaintext_value = "ec2-user"
}

resource "github_actions_secret" "ecr_repository_name" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "ECR_REPOSITORY_NAME"
  plaintext_value = aws_ecr_repository.stockzrs_relay_repository.name
}

resource "github_actions_secret" "ecr_repository_url" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "ECR_REPOSITORY_URL"
  plaintext_value = aws_ecr_repository.stockzrs_relay_repository.repository_url
}

resource "github_actions_secret" "STOCKZRS_RELAY_PORT" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "STOCKZRS_RELAY_PORT"
  plaintext_value = var.stockzrs_relay_port
}

resource "github_actions_secret" "AWS_STOCKZRS_KUBERNETES_CLUSTER_NAME" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "AWS_STOCKZRS_KUBERNETES_CLUSTER_NAME"
  plaintext_value = aws_eks_cluster.eks.name
}

resource "github_actions_secret" "aws_gha_role_arn" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "AWS_GHA_ROLE_ARN"
  plaintext_value = aws_iam_role.github_actions.arn
}
