variable "aws_region" {
  description = "The AWS region where resources will be created"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  default     = "devops-eks-cluster"
}
