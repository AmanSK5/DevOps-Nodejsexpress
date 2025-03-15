provider "azurerm" {
  features {}

  # Using the variable for subscription_id
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name  # Reference the variable for resource group name
  location = var.location  # Reference the variable for location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name  # Reference the variable for AKS cluster name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devopsaks"

  default_node_pool {
    name       = "default"
    node_count = var.node_count  # Reference the variable for node count
    vm_size    = var.vm_size    # Reference the variable for VM size
  }

  identity {
    type = "SystemAssigned"
  }
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
