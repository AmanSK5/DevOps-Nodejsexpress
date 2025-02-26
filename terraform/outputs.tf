output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "resource_group" {
  description = "The resource group name"
  value       = azurerm_resource_group.rg.name
}

output "aks_kube_config" {
  description = "Kubeconfig command to access the AKS cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}
