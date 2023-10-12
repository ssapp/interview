
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

variable "kubernetes_cluster_name" {
  type    = string
  default = "aks-cluster"
}

variable "kubernetes_version" {
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

variable "vnet_name" {
  type    = string
  default = "aks-vnet"
}

variable "vnet_address_space" {
  type = list(string)
  default = [
    "10.0.0.0/8"
  ]

}

variable "subnet_name" {
  type    = string
  default = "aks-subnet"
}

variable "subnet_address_prefixes" {
  type = list(string)
  default = [
    "10.240.0.0/16"
  ]

}

variable "node_count" {
  type    = number
  default = 1
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "subscription_id" {
  type      = string
  sensitive = true
}
