output "stockzrs_cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "Name of the Stockzrs EKS cluster"
}

output "ingress_nginx_lb_hostname" {
  value = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
}

output "kafka_bootstrap_server" {
  value = "${kubernetes_service.kafka_bootstrap.metadata[0].name}.${kubernetes_namespace.kafka.metadata[0].name}.svc.cluster.local:9092"
}

output "kafka_users" {
  value = {
    admin = {
      username = "stockzrs-admin"
      password = random_password.kafka_user_admin.result
    }
    stockzrs_relay_service = {
      username = "stockzrs-relay-service"
      password = random_password.kafka_user_stockzrs_relay_service.result
    }
    stockzrs_financial_aggregator_service = {
      username = "stockzrs-financial-aggregator-service"
      password = random_password.kafka_user_stockzrs_financial_aggregator_service.result
    }
    stockzrs_data_persistence_service = {
      username = "stockzrs-data-persistence-service"
      password = random_password.kafka_user_data_persistence_service.result
    }
  }
  sensitive = true
}

output "kafka_topics" {
  value = {
    raw_financial_updates_topic = var.kafka_raw_financial_updates_topic
    minute_aggregates_topic     = var.kafka_minute_aggregates_topic
  }
}