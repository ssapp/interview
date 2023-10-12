variable "host" {
  type      = string
  sensitive = true
}

variable "client_key" {
  type      = string
  sensitive = true
}

variable "client_certificate" {
  type      = string
  sensitive = true
}

variable "cluster_ca_certificate" {
  type      = string
  sensitive = true
}

variable "deployment_name" {
  type    = string
  default = "web-app"
}

variable "deployment_namespace" {
  type    = string
  default = "default"
}

variable "deployment_labels" {
  type = map(string)
  default = {
    app = "web-app"
  }
}

variable "deployment_replicas" {
  type    = number
  default = 1
}

variable "deployment_container_image" {
  type    = string
  default = "nginxdemos/hello"
}

variable "deployment_container_name" {
  type    = string
  default = "web-app-container"
}

variable "deployment_container_limits" {
  type = map(string)
  default = {
    cpu    = "100m"
    memory = "100Mi"
  }
}

variable "deployment_container_requests" {
  type = map(string)
  default = {
    cpu    = "100m"
    memory = "100Mi"
  }
}

variable "container_port" {
  type    = number
  default = 80
}

variable "protocol" {
  type    = string
  default = "TCP"
}

variable "service_type" {
  type    = string
  default = "ClusterIP"
}

variable "ingress_class_name" {
  type    = string
  default = "nginx"
}

variable "ingress_path_type" {
  type    = string
  default = "Prefix"
}

variable "ingress_path_prefix" {
  type    = string
  default = "/"
}

