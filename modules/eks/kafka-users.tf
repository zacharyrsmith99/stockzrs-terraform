resource "random_password" "kafka_user_admin" {
  length  = 16
  special = false
}

resource "random_password" "kafka_user_stockzrs_relay_service" {
  length  = 16
  special = false
}

resource "random_password" "kafka_user_stockzrs_financial_aggregator_service" {
  length  = 16
  special = false
}

resource "random_password" "kafka_user_data_persistence_service" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "kafka_admin_user" {
  metadata {
    name      = "stockzrs-admin"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }
  data = {
    password = random_password.kafka_user_admin.result
  }
}

resource "kubernetes_secret" "kafka_user_stockzrs_relay_service" {
  metadata {
    name      = "stockzrs-relay-service"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }
  data = {
    password = random_password.kafka_user_stockzrs_relay_service.result
  }
}

resource "kubernetes_secret" "kafka_user_stockzrs_financial_aggregator_service" {
  metadata {
    name      = "stockzrs-financial-aggregator-service"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }
  data = {
    password = random_password.kafka_user_stockzrs_financial_aggregator_service.result
  }
}

resource "kubernetes_secret" "kafka_user_data_persistence_service" {
  metadata {
    name      = "stockzrs-data-persistence-service"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }
  data = {
    password = random_password.kafka_user_data_persistence_service.result
  }
}


resource "kubernetes_manifest" "kafka_admin_user" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaUser"
    metadata = {
      name      = "stockzrs-admin"
      namespace = kubernetes_namespace.kafka.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      }
    }
    spec = {
      authentication = {
        type = "scram-sha-512"
        password = {
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_secret.kafka_admin_user.metadata[0].name
              key  = "password"
            }
          }
        }
      }
      authorization = {
        type = "simple"
        acls = [
          {
            operation = "All"
            resource = {
              type = "topic"
              name = "*"
            }
          },
          {
            operation = "All"
            resource = {
              type = "group"
              name = "*"
            }
          }
        ]
      }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}

# User 1: Can only write to raw-financial-updates
# stockzrs-relay-service
resource "kubernetes_manifest" "kafka_user_stockzrs_relay_service" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaUser"
    metadata = {
      name      = "stockzrs-relay-service"
      namespace = kubernetes_namespace.kafka.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      }
    }
    spec = {
      authentication = {
        type = "scram-sha-512"
        password = {
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_secret.kafka_user_stockzrs_relay_service.metadata[0].name
              key  = "password"
            }
          }
        }
      }
      authorization = {
        type = "simple"
        acls = [
          {
            operation = "Write"
            resource = {
              type = "topic"
              name = "raw-financial-updates"
            }
          },
          {
            operation = "Describe"
            resource = {
              type = "topic"
              name = "raw-financial-updates"
            }
          }
        ]
      }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}

# User 2: Can read from raw-financial-updates and write to minute-aggregated-financial-updates
# stockzrs-financial-aggregator-service
resource "kubernetes_manifest" "kafka_user_stockzrs_financial_aggregator_service" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaUser"
    metadata = {
      name      = "stockzrs-financial-aggregator-service"
      namespace = kubernetes_namespace.kafka.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      }
    }
    spec = {
      authentication = {
        type = "scram-sha-512"
        password = {
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_secret.kafka_user_stockzrs_financial_aggregator_service.metadata[0].name
              key  = "password"
            }
          }
        }
      }
      authorization = {
        type = "simple"
        acls = [
          {
            operation = "Read"
            resource = {
              type = "topic"
              name = "raw-financial-updates"
            }
          },
          {
            operation = "Describe"
            resource = {
              type = "topic"
              name = "raw-financial-updates"
            }
          },
          {
            operation = "Write"
            resource = {
              type = "topic"
              name = "minute-aggregated-financial-updates"
            }
          },
          {
            operation = "Describe"
            resource = {
              type = "topic"
              name = "minute-aggregated-financial-updates"
            }
          },
          {
            operation = "Read"
            resource = {
              type = "group"
              name = "financial-aggregator-group"
            }
          }
        ]
      }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}

# User 3: Can only read from minute-aggregated-financial-updates
# stockzrs-data-persistence-service
resource "kubernetes_manifest" "kafka_user_data_persistence_service" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaUser"
    metadata = {
      name      = "stockzrs-data-persistence-service"
      namespace = kubernetes_namespace.kafka.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "stockzrs-kafka-cluster"
      }
    }
    spec = {
      authentication = {
        type = "scram-sha-512"
        password = {
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_secret.kafka_user_data_persistence_service.metadata[0].name
              key  = "password"
            }
          }
        }
      }
      authorization = {
        type = "simple"
        acls = [
          {
            operation = "Read"
            resource = {
              type = "topic"
              name = "minute-aggregated-financial-updates"
            }
          },
          {
            operation = "Describe"
            resource = {
              type = "topic"
              name = "minute-aggregated-financial-updates"
            }
          },
          {
            operation = "Read"
            resource = {
              type = "group"
              name = "aggregated-financial-reader-group"
            }
          }
        ]
      }
    }
  }
  depends_on = [kubernetes_manifest.kafka_cluster]
}
