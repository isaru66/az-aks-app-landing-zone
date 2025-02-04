variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "environment" {
  description = "Environment name for the resources"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the existing private DNS zone for blob storage"
  type        = string
}

variable "identity_type" {
  description = "Type of identity (SystemAssigned, UserAssigned, SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "user_assigned_identity_ids" {
  description = "List of user-assigned identity IDs"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
