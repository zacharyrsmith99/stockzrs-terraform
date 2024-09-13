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
            "token.actions.githubusercontent.com:sub" = [
              "repo:zacharyrsmith99/stockzrs-relay-service:*",
              "repo:zacharyrsmith99/stockzrs-frontend:*",
              "repo:zacharyrsmith99/stockzrs-financial-aggregator-service:*",
              "repo:zacharyrsmith99/stockzrs-data-persistence-service:*",
              "repo:zacharyrsmith99/stockzrs-metrics-service:*"
            ]
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
  cluster_name      = module.eks.stockzrs_cluster_name
  principal_arn     = aws_iam_role.github_actions.arn
  kubernetes_groups = ["github-actions"]
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

####################################
#################################### SHARED GITHUB SECRETS

resource "github_actions_secret" "aws_region" {
  count           = length(var.github_repositories_with_common_secrets)
  repository      = var.github_repositories_with_common_secrets[count.index]
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_secret" "aws_stockzrs_kubernetes_cluster_name" {
  count           = length(var.github_repositories_with_common_secrets)
  repository      = var.github_repositories_with_common_secrets[count.index]
  secret_name     = "AWS_STOCKZRS_KUBERNETES_CLUSTER_NAME"
  plaintext_value = module.eks.stockzrs_cluster_name
}

resource "github_actions_secret" "aws_gha_role_arn" {
  count           = length(var.github_repositories_with_common_secrets)
  repository      = var.github_repositories_with_common_secrets[count.index]
  secret_name     = "AWS_GHA_ROLE_ARN"
  plaintext_value = aws_iam_role.github_actions.arn
}


resource "github_actions_secret" "ec2_user_name" {
  count           = length(var.github_repositories_with_common_secrets)
  repository      = var.github_repositories_with_common_secrets[count.index]
  secret_name     = "EC2_USER_NAME"
  plaintext_value = "ec2-user"
}

resource "github_actions_secret" "aws_account_id" {
  count           = length(var.github_repositories_with_common_secrets)
  repository      = var.github_repositories_with_common_secrets[count.index]
  secret_name     = "AWS_ACCOUNT_ID"
  plaintext_value = data.aws_caller_identity.current.account_id
}

####################################
####################################

####################################
####################################STOCKZRS RELAY SERVICE GITHUB SECRETS

resource "github_actions_secret" "stockzrs_relay_service_ecr_repository_name" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "ECR_REPOSITORY_NAME"
  plaintext_value = module.services.ecr_repositories.stockzrs_relay.name
}

resource "github_actions_secret" "stockzrs_relay_service_ecr_repository_url" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "ECR_REPOSITORY_URL"
  plaintext_value = module.services.ecr_repositories.stockzrs_relay.url
}

resource "github_actions_secret" "stockzrs_relay_service_port" {
  repository      = var.stockzrs_relay_github_repository
  secret_name     = "STOCKZRS_RELAY_PORT"
  plaintext_value = var.stockzrs_relay_port
}

####################################
####################################

####################################
####################################STOCKZRS FRONTEND GITHUB SECRETS

resource "github_actions_secret" "stockzrs_frontend_port" {
  repository      = var.stockzrs_frontend_github_repository
  secret_name     = "STOCKZRS_FRONTEND_PORT"
  plaintext_value = var.stockzrs_frontend_port
}

resource "github_actions_secret" "stockzrs_frontend_ecr_repository_name" {
  repository      = var.stockzrs_frontend_github_repository
  secret_name     = "ECR_REPOSITORY_NAME"
  plaintext_value = module.services.ecr_repositories.stockzrs_frontend.name
}
resource "github_actions_secret" "stockzrs_frontend_ecr_repository_url" {
  repository      = var.stockzrs_frontend_github_repository
  secret_name     = "ECR_REPOSITORY_URL"
  plaintext_value = module.services.ecr_repositories.stockzrs_frontend.url
}

####################################
####################################

####################################
####################################STOCKZRS FINANCIAL AGGREGATOR SERVICE GITHUB SECRETS

resource "github_actions_secret" "stockzrs_financial_aggregator_service_ecr_repository_name" {
  repository      = var.stockzrs_financial_aggregator_service_github_repository
  secret_name     = "ECR_REPOSITORY_NAME"
  plaintext_value = module.services.ecr_repositories.stockzrs_financial_aggregator_service.name
}
resource "github_actions_secret" "stockzrs_financial_aggregator_service_ecr_repository_url" {
  repository      = var.stockzrs_financial_aggregator_service_github_repository
  secret_name     = "ECR_REPOSITORY_URL"
  plaintext_value = module.services.ecr_repositories.stockzrs_financial_aggregator_service.url
}

####################################
####################################

####################################
####################################STOCKZRS DATA PERSISTENCE SERVICE GITHUB SECRETS

resource "github_actions_secret" "stockzrs_data_persistence_service_ecr_repository_name" {
  repository      = var.stockzrs_data_persistence_service_github_repository
  secret_name     = "ECR_REPOSITORY_NAME"
  plaintext_value = module.services.ecr_repositories.stockzrs_data_persistence_service.name
}
resource "github_actions_secret" "stockzrs_data_persistence_service_ecr_repository_url" {
  repository      = var.stockzrs_data_persistence_service_github_repository
  secret_name     = "ECR_REPOSITORY_URL"
  plaintext_value = module.services.ecr_repositories.stockzrs_data_persistence_service.url
}

####################################
####################################

####################################
####################################STOCKZRS DATA PERSISTENCE SERVICE GITHUB SECRETS

resource "github_actions_secret" "stockzrs_metrics_service_ecr_repository_name" {
  repository      = var.stockzrs_metrics_service_github_repository
  secret_name     = "ECR_REPOSITORY_NAME"
  plaintext_value = module.services.ecr_repositories.stockzrs_metrics_service.name
}
resource "github_actions_secret" "stockzrs_metrics_service_ecr_repository_url" {
  repository      = var.stockzrs_metrics_service_github_repository
  secret_name     = "ECR_REPOSITORY_URL"
  plaintext_value = module.services.ecr_repositories.stockzrs_metrics_service.url
}

####################################
####################################
