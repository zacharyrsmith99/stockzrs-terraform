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
    }
    spec = {
      kafka = {
        version  = "3.8.0"
        replicas = 2
        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
          },
          {
            name = "tls"
            port = 9093
            type = "internal"
            tls  = true
          }
        ]
        config = {
          "offsets.topic.replication.factor"         = 2
          "transaction.state.log.replication.factor" = 2
          "transaction.state.log.min.isr"            = 2
          "default.replication.factor"               = 2
          "min.insync.replicas"                      = 2
        }
        storage = {
          type = "jbod"
          volumes = [
            {
              id          = 0
              type        = "persistent-claim"
              size        = "20Gi"
              deleteClaim = false
              class       = "gp2"
            }
          ]
        }
        resources = {
          requests = {
            memory = "1Gi"
            cpu    = "500m"
          }
          limits = {
            memory = "2Gi"
            cpu    = "1"
          }
        }
      }
      zookeeper = {
        replicas = 2
        storage = {
          type        = "persistent-claim"
          size        = "10Gi"
          deleteClaim = false
          class       = "gp2"
        }
        resources = {
          requests = {
            memory = "512Mi"
            cpu    = "250m"
          }
          limits = {
            memory = "1Gi"
            cpu    = "500m"
          }
        }
      }
      entityOperator = {
        topicOperator = {}
        userOperator  = {}
      }
    }
  }
  depends_on = [helm_release.kafka_operator]
}

resource "kubernetes_manifest" "raw_financial_updates_topic" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = "raw-financial-updates"
      namespace = "kafka"
      labels = {
        "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      }
    }
    spec = {
      partitions = 2
      replicas   = 2
      config = {
        "retention.ms"  = 604800000
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
      name      = "minute-aggregated-financial-updates"
      namespace = "kafka"
      labels = {
        "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      }
    }
    spec = {
      partitions = 2
      replicas   = 2
      config = {
        "retention.ms"  = 604800000
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
