terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kubernetes" {
  client_key             = base64decode(var.client_key)
  client_certificate     = base64decode(var.client_certificate)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  host                   = var.host
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.deployment_namespace
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.deployment_name
    namespace = var.deployment_namespace
    labels    = var.deployment_labels
  }

  spec {
    replicas = var.deployment_replicas

    selector {
      match_labels = var.deployment_labels
    }

    template {
      metadata {
        labels = var.deployment_labels
      }

      spec {
        container {
          name              = var.deployment_container_name
          image             = var.deployment_container_image
          image_pull_policy = "Always"

          resources {
            limits   = var.deployment_container_limits
            requests = var.deployment_container_requests
          }

          liveness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }

          port {
            container_port = var.container_port
            protocol       = var.protocol
          }
        }
      }
    }
  }
}

locals {
  name        = kubernetes_deployment.deployment.metadata.0.name
  namespace   = kubernetes_deployment.deployment.metadata.0.namespace
  labels      = kubernetes_deployment.deployment.metadata.0.labels
  selector    = kubernetes_deployment.deployment.spec.0.selector.0.match_labels
  port        = kubernetes_deployment.deployment.spec.0.template.0.spec.0.container.0.port.0.container_port
  target_port = kubernetes_deployment.deployment.spec.0.template.0.spec.0.container.0.port.0.container_port
}

resource "kubernetes_service_v1" "service" {
  metadata {
    name      = local.name
    namespace = local.namespace
  }

  spec {
    selector = local.selector

    port {
      port        = local.port
      target_port = local.target_port
    }

    type = var.service_type
  }

  depends_on = [
    kubernetes_deployment.deployment
  ]
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = local.name
    namespace = local.namespace
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = local.name
              port {
                number = local.port
              }
            }
          }
          path_type = var.ingress_path_type
          path      = var.ingress_path_prefix
        }
      }
    }
    ingress_class_name = var.ingress_class_name
  }

  depends_on = [
    kubernetes_service_v1.service
  ]
}
