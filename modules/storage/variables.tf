variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the storage account will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for the private endpoint"
  type        = string
}

variable "principal_id" {
  description = "Principal ID (object ID) of the identity that needs blob data access"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the storage account"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name used for resource naming and tagging"
  type        = string
}
