variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
  default     = "my-aks-resource-group"   # Change this
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US"   # Change this
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "my-aks-cluster"   # Change this
}

variable "node_count" {
  description = "Number of worker nodes in AKS"
  type        = number
  default     = 2   # Change this if needed
}
