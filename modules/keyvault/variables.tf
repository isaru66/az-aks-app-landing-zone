variable "name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku_name" {
  description = "SKU name of the Key Vault"
  type        = string
  default     = "standard"
}

variable "enabled_for_deployment" {
  description = "Enable VM deployment access"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Enable disk encryption access"
  type        = bool
  default     = true
}

variable "enabled_for_template_deployment" {
  description = "Enable template deployment access"
  type        = bool
  default     = false
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 90
}

variable "network_acls" {
  description = "Network ACLs for the Key Vault"
  type = object({
    bypass                     = string
    default_action            = string
    ip_rules                  = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = {
    bypass                     = "AzureServices"
    default_action            = "Deny"
    ip_rules                  = []
    virtual_network_subnet_ids = []
  }
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for private endpoint"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}
