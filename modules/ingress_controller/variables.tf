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
  default = "ingress-nginx"
}

variable "deployment_namespace" {
  type    = string
  default = "default"
}

variable "chart_version" {
  type    = string
  default = "4.8.1"
}

variable "create_namespace" {
  type = bool
}

variable "force_update" {
  type = bool
}

variable "public_ip_address_name" {
  type = string
}

variable "loadbalancer_ipv4_address" {
  type = string
}

variable "loadbalancer_dns_label_name" {
  type = string
}

variable "loadbalancer_resource_group_name" {
  type = string
}
