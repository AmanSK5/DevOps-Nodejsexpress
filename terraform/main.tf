provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "devops-aks-resource-group"  # Name of the resource group
  location = "West Europe"                # Region within Azure
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "devops-aks-cluster"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devopsaks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
