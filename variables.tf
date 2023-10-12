
variable "dns_prefix" {
  type    = string
  default = "aks"
}

variable "environment" {
  type    = string
  default = "Production"
}

variable "rg_name" {
  type    = string
  default = "aks-rg"
}

variable "location" {
  type    = string
  default = "westus2"
}

variable "k8s_name" {
  type    = string
  default = "aks-cluster"
}

variable "k8s_version" {
  type    = string
  default = "1.28.0"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "default_node_pool_name" {
  type    = string
  default = "default"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "client_id" {
  type = string
  sensitive = true
}

variable "client_secret" {
  type = string
  sensitive = true
}

variable "tenant_id" {
  type = string
  sensitive = true
}

variable "subscription_id" {
  type = string
sensitive = true
}
