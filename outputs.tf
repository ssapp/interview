output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  description = "The kubeconfig for the AKS cluster"
  sensitive = true
}

output "ingress_fqdn" {
    value = azurerm_public_ip.k8s.fqdn
    description = "The FQDN of the ingress controller"
}