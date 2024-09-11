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
        replicas = 3
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
          "offsets.topic.replication.factor"         = 3
          "transaction.state.log.replication.factor" = 3
          "transaction.state.log.min.isr"            = 3
          "default.replication.factor"               = 3
          "min.insync.replicas"                      = 3
        }
        storage = {
          type = "jbod"
          volumes = [
            {
              id          = 0
              type        = "persistent-claim"
              size        = "20Gi"
              deleteClaim = false
              class       = "ebs-sc"
            }
          ]
        }
        resources = {
          requests = {
            memory = "768Mi"
            cpu    = "400m"
          }
          limits = {
            memory = "1536Mi"
            cpu    = "800m"
          }
        }
      }
      zookeeper = {
        replicas = 3
        storage = {
          type        = "persistent-claim"
          size        = "10Gi"
          deleteClaim = false
          class       = "ebs-sc"
        }
        resources = {
          requests = {
            memory = "384Mi"
            cpu    = "200m"
          }
          limits = {
            memory = "768Mi"
            cpu    = "400m"
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
      partitions = 3
      replicas   = 3
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
      partitions = 3
      replicas   = 3
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