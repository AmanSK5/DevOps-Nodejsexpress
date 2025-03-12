terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
}

# Create a Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix

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

# Private DNS Zone for Private AKS Cluster
resource "azurerm_private_dns_zone" "aks_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}

# Link DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "aks_dns_link" {
  name                  = "aks-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-log-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# AKS Private Cluster (Fixed for Terraform v3.70.0)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devopsaks-private"

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }

  # ✅ Correct way for Private AKS in Terraform v3.70.0
  api_server_access_profile {
    private_dns_zone_id = azurerm_private_dns_zone.aks_dns.id
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "dev"
  }

  depends_on = [
    azurerm_log_analytics_workspace.aks,
    azurerm_private_dns_zone.aks_dns
  ]
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
