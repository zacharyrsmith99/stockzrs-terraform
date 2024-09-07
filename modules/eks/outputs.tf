output "stockzrs_cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "Name of the Stockzrs EKS cluster"
}

output "ingress_nginx_lb_hostname" {
  value = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
}