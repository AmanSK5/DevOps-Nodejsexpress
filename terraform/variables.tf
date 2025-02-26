variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
  default     = "devops-aks-resource-group"  
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "West Europe"   
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "devops-aks-cluster"   

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "devopsaks"  
}

variable "node_count" {
  description = "Number of worker nodes in AKS"
  type        = number
  default     = 2   
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"   
}
