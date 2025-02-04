variable "workspace_name" {
  type        = string
  description = "Name of the Log Analytics workspace"
}

variable "location" {
  type        = string
  description = "Azure region where the workspace will be created"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "sku" {
  type        = string
  default     = "PerGB2018"
  description = "SKU of the Log Analytics workspace"
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "Data retention in days"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to the workspace"
  default     = {}
}
