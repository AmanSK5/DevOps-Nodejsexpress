provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create Subnets
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  # Required for Private AKS clusters
  delegation {
    name = "aksdelegation"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Private DNS Zone for AKS API Server
resource "azurerm_private_dns_zone" "aks_dns" {
  name                = "privatelink.westeurope.azmk8s.io"
  resource_group_name = azurerm_resource_group.rg.name
}

# Private Link Service for AKS API Server
resource "azurerm_private_dns_zone_virtual_network_link" "aks_dns_link" {
  name                  = "aks-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# AKS Cluster with Private Link
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devopsaks"

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id  # Assign the subnet
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico" # Improves security
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }

  # Configure API Server for Private Access
  api_server_access_profile {
    enable_private_cluster = true
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "dev"
  }
}

# Log Analytics for AKS Monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-log-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
