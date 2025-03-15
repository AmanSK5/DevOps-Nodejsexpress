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
  default     = "devops-aks-cluster"  # Default value, can be overridden in terraform.tfvars
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 1  # Default value, can be overridden in terraform.tfvars
}

variable "vm_size" {
  description = "VM size for the AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"  # Default VM size, can be overridden in terraform.tfvars
}
