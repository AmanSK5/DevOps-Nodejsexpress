variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "West Europe"  # Default region, can be overridden in terraform.tfvars
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "devops-aks-resource-group"  # Default value, can be overridden in terraform.tfvars
}

variable "aks_cluster_name" {
  description = "Name of the AKS Cluster"
  type        = string
  default     = "devops-aks-private-cluster"  # Updated for private cluster
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2  # Default value, can be overridden in terraform.tfvars
}

variable "vm_size" {
  description = "VM size for the AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"  # Default VM size, can be overridden in terraform.tfvars
}

# Virtual Network and Subnet for Private AKS
variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "aks-vnet"
}

variable "vnet_address_space" {
  description = "CIDR block for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the AKS Subnet"
  type        = string
  default     = "aks-subnet"
}

variable "subnet_address_prefix" {
  description = "CIDR block for the AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# Private DNS Zone for Private AKS Cluster
variable "private_dns_zone_name" {
  description = "Private DNS Zone Name for Private Link"
  type        = string
  default     = "privatelink.westeurope.azmk8s.io"
}
