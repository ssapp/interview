#
# This is the main Terraform file that will be used to deploy the AKS Cluster and the Web App
#
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "k8s" {
  name     = var.rg_name
  location = var.location
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  default_node_pool {
    name                = var.default_node_pool_name
    node_count          = var.node_count
    vm_size             = var.vm_size
    enable_auto_scaling = false
    tags = {
      Environment = var.environment
    }
  }

  identity {
    type = "SystemAssigned"
  }

  location            = azurerm_resource_group.k8s.location
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.k8s_version
  resource_group_name = azurerm_resource_group.k8s.name
  name                = var.k8s_name
  tags = {
    Environment = var.environment
  }
}

# Public IP for Ingress Controller
resource "azurerm_public_ip" "ingress_ip" {
  name                = "ingress-ip"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
  domain_name_label   = var.dns_prefix
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = var.environment
  }
}

# Ingress Controller Module
module "ingress" {
  source = "./modules/ingress_controller"

  # Kube Config from AKS Cluster
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_key             = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  client_certificate     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  cluster_ca_certificate = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate

  # Ingress Controller Config
  deployment_name                  = "nginx-ingress"
  deployment_namespace             = "ingress-nginx"
  public_ip_address_name           = azurerm_public_ip.ingress_ip.name
  loadbalancer_ipv4_address        = azurerm_public_ip.ingress_ip.ip_address
  loadbalancer_dns_label_name      = var.dns_prefix
  loadbalancer_resource_group_name = var.rg_name
}

# Web App Module
module "k8s" {
  source = "./modules/web_app"

  # Kube Config from AKS Cluster
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_key             = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  client_certificate     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  cluster_ca_certificate = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate

  # Web App Config
  deployment_name            = "web-app"
  deployment_namespace       = "software-ag"
  deployment_container_image = "nginx:latest"
  deployment_replicas        = 1

  deployment_container_limits = {
    "cpu"    = "100m"
    "memory" = "100Mi"
  }

  deployment_container_requests = {
    "cpu"    = "100m"
    "memory" = "100Mi"
  }
}



