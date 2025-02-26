output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "resource_group" {
  description = "The resource group name"
  value       = azurerm_resource_group.rg.name
}
