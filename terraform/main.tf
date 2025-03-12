terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70.0"  # Ensure Terraform pulls a supported version
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network for AKS
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for AKS Nodes
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  # Required for AKS Private Link
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

# ✅ Private DNS Zone for AKS API
resource "azurerm_private_dns_zone" "aks_dns" {
  name                = "privatelink.westeurope.azmk8s.io"
  resource_group_name = azurerm_resource_group.rg.name
}

# ✅ Private DNS Link to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "aks_dns_link" {
  name                  = "aks-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# ✅ Log Analytics for AKS Monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-log-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ✅ AKS Private Cluster (Corrected for Terraform v3.70)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devopsaks"

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
    network_policy = "calico" # Security best practice
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }

  # ✅ Corrected Private Cluster Configuration
  api_server_access_profile {
    private_cluster_enabled = true  # FIXED
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "dev"
  }

  # ✅ Ensure DNS and Monitoring are created first
  depends_on = [
    azurerm_private_dns_zone.aks_dns,
    azurerm_private_dns_zone_virtual_network_link.aks_dns_link,
    azurerm_log_analytics_workspace.aks
  ]
}

# ✅ Output the AKS Cluster Name
output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
