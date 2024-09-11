# resource "kubernetes_namespace" "delete_kafka" {
#   metadata {
#     name = "kafka"
#   }

#   lifecycle {
#     create_before_destroy = false
#   }
# }

resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
  }
}

resource "helm_release" "kafka_operator" {
  name       = "kafka-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = "0.43.0"
  namespace  = kubernetes_namespace.kafka.metadata[0].name

  depends_on = [kubernetes_namespace.kafka]
}

resource "kubernetes_manifest" "kafka_cluster" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata = {
      name      = "stockzrs-kafka-cluster"
      namespace = kubernetes_namespace.kafka.metadata[0].name
      annotations = {
        "strimzi.io/node-pools" = "enabled"
        "strimzi.io/kraft"      = "enabled"
      }
    }
    spec = {
      kafka = {
        version  = "3.8.0"
        replicas = 3
        config = {
          "offsets.topic.replication.factor"         = 3
          "transaction.state.log.replication.factor" = 3
          "transaction.state.log.min.isr"            = 2
          "default.replication.factor"               = 3
          "min.insync.replicas"                      = 2
          "num.partitions"                           = 3
        }
        # authorization = {
        #   type = "simple"
        # }
        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
            # authentication = {
            #   type = "scram-sha-512"
            # }
          },
          {
            name = "tls"
            port = 9093
            type = "internal"
            tls  = true
            authentication = {
              type = "scram-sha-512"
            }
          }
        ]
      }
    }
  }
  depends_on = [helm_release.kafka_operator]
}

resource "kubernetes_manifest" "kafka_nodepool_combined" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaNodePool"
    metadata = {
      name      = "dual-role"
      namespace = kubernetes_namespace.kafka.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      }
    }
    spec = {
      replicas = 3
      roles    = ["controller", "broker"]
      storage = {
        type = "jbod"
        volumes = [
          {
            id          = 0
            type        = "persistent-claim"
            size        = "10Gi"
            deleteClaim = false
            class       = "ebs-sc"
          }
        ]
      }
      resources = {
        requests = {
          memory = "512Mi"
          cpu    = "250m"
        }
        limits = {
          memory = "1400Mi"
          cpu    = "1000m"
        }
      }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}

resource "kubernetes_manifest" "raw_financial_updates_topic" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = var.kafka_raw_financial_updates_topic
      namespace = "kafka"
      labels = {
        "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      }
    }
    spec = {
      partitions = 3
      replicas   = 2
      config = {
        "retention.ms"  = 104800000
        "segment.bytes" = 1073741824
      }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}

resource "kubernetes_manifest" "minute_aggregated_financial_updates_topic" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = var.kafka_minute_aggregates_topic
      namespace = "kafka"
      labels = {
        "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      }
    }
    spec = {
      partitions = 3
      replicas   = 2
      config = {
        "retention.ms"  = 304800000
        "segment.bytes" = 1073741824
      }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}

resource "kubernetes_service" "kafka_bootstrap" {
  metadata {
    name      = "kafka-bootstrap"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }
  spec {
    selector = {
      "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      "strimzi.io/kind"    = "Kafka"
    }
    port {
      port        = 9092
      target_port = 9092
    }
    type = "ClusterIP"
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}