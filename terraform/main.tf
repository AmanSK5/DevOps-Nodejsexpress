provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "my-aks-resource-group"   # <your-resource-group>
  location = "East US"                 # <your-location>
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"  # <your-cluster-name>
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myaks"

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
