resource "kubernetes_namespace" "stockzrs_relay_service" {
  metadata {
    name = "stockzrs-relay-service"
    labels = {
      name        = "stockzrs-relay-service"
      environment = "production"
    }
  }
  depends_on = [aws_eks_cluster.eks]
}

resource "kubernetes_namespace" "stockzrs_frontend" {
  metadata {
    name = "stockzrs-frontend"
    labels = {
      name        = "stockzrs-frontend"
      environment = "production"
    }
  }
  depends_on = [aws_eks_cluster.eks]
}

resource "kubernetes_manifest" "github_actions_cluster_role" {
  manifest = yamldecode(file("${path.module}/k8s/cluster-roles/github-actions-cluster-role.yaml"))

  depends_on = [aws_eks_cluster.eks]
}

resource "kubernetes_manifest" "github_actions_cluster_role_binding" {
  manifest = yamldecode(file("${path.module}/k8s/cluster-roles/github-actions-cluster-role-binding.yaml"))

  depends_on = [kubernetes_manifest.github_actions_cluster_role, aws_eks_cluster.eks]
}