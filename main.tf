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

locals {
  resource_tags = {
    Environment = var.environment
  }
}

resource "azurerm_resource_group" "k8s" {
  name     = var.rg_name
  location = var.location
  tags     = local.resource_tags
}

resource "azurerm_virtual_network" "k8s" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  tags                = local.resource_tags
}

resource "azurerm_subnet" "k8s" {
  name                 = var.subnet_name
  address_prefixes     = var.subnet_address_prefixes
  resource_group_name  = azurerm_resource_group.k8s.name
  virtual_network_name = azurerm_virtual_network.k8s.name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  dns_prefix          = var.dns_prefix
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  name                = var.kubernetes_cluster_name
  kubernetes_version  = var.kubernetes_version
  tags                = local.resource_tags

  default_node_pool {
    name                = var.default_node_pool_name
    node_count          = var.node_count
    vm_size             = var.vm_size
    enable_auto_scaling = false
    vnet_subnet_id      = azurerm_subnet.k8s.id
    tags                = local.resource_tags
  }

  identity {
    type = "SystemAssigned"
  }

}


# Public IP for Ingress Controller
resource "azurerm_public_ip" "k8s" {
  name                = "ingress-ip"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
  domain_name_label   = var.dns_prefix
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = local.resource_tags
}

locals {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_key             = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  client_certificate     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  cluster_ca_certificate = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
}

# Ingress Controller Module
module "ingress" {
  source = "./modules/ingress_controller"

  # Kube Config from AKS Cluster
  host                   = local.host
  client_key             = local.client_key
  client_certificate     = local.client_certificate
  cluster_ca_certificate = local.cluster_ca_certificate

  # Ingress Controller Config
  deployment_name                  = "nginx-ingress"
  deployment_namespace             = "ingress-nginx"
  force_update                     = false
  create_namespace                 = true
  public_ip_address_name           = azurerm_public_ip.k8s.name
  loadbalancer_ipv4_address        = azurerm_public_ip.k8s.ip_address
  loadbalancer_dns_label_name      = var.dns_prefix
  loadbalancer_resource_group_name = var.rg_name
}

# Web App Module
module "k8s" {
  source = "./modules/web_app"

  # Kube Config from AKS Cluster
  host                   = local.host
  client_key             = local.client_key
  client_certificate     = local.client_certificate
  cluster_ca_certificate = local.cluster_ca_certificate

  # Web App Config
  deployment_name            = "web-app"
  deployment_namespace       = "software-ag"
  deployment_container_image = "nginxdemos/hello"
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



