variable "group_name" {
  description = "Display name of the Azure AD group"
  type        = string
}

variable "description" {
  description = "Description of the Azure AD group"
  type        = string
  default     = "AKS administrators group managed by Terraform"
}

variable "group_owners" {
  description = "List of Azure AD object IDs that will be owners of the group"
  type        = list(string)
  default     = null
}

variable "aks_cluster_id" {
  description = "The ID of the AKS cluster to assign admin access to"
  type        = string
  default     = null # Making this optional
}