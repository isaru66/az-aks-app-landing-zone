variable "server_name" {
  description = "Name of the MySQL Flexible Server"
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

variable "administrator_login" {
  description = "Administrator username for the server"
  type        = string
}

variable "administrator_password" {
  description = "Administrator password for the server"
  type        = string
  sensitive   = true
}

variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "8.0.21"
  validation {
    condition     = can(regex("^(5\\.7|8\\.0)", var.mysql_version))
    error_message = "MySQL version must be either 5.7 or 8.0"
  }
}

variable "sku_name" {
  description = "SKU Name for the MySQL Flexible Server"
  type        = string
  default     = "GP_Standard_D2ds_v4"
}

variable "storage_iops" {
  description = "Storage IOPS for the server"
  type        = number
  default     = 360
}

variable "storage_size_gb" {
  description = "Storage size in GB"
  type        = number
  default     = 20
}

variable "backup_retention_days" {
  description = "Backup retention days for the server"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 7 and 35"
  }
}

variable "subnet_id" {
  description = "ID of the subnet for the MySQL Flexible Server"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR of the subnet for firewall rules"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  type        = string
}

variable "zone" {
  description = "Availability zone for the server"
  type        = string
  default     = "1"
}

variable "high_availability_mode" {
  description = "High availability mode"
  type        = string
  default     = "ZoneRedundant"
  validation {
    condition     = contains(["ZoneRedundant", "SameZone", "Disabled"], var.high_availability_mode)
    error_message = "High availability mode must be ZoneRedundant, SameZone, or Disabled"
  }
}

variable "standby_availability_zone" {
  description = "Availability zone for the standby server"
  type        = string
  default     = "2"
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = {
    day_of_week  = 0  # Sunday
    start_hour   = 2  # 2 AM
    start_minute = 0
  }
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for diagnostics"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the MySQL Flexible Server"
  type        = map(string)
  default     = {}
}

variable "identity_id" {
  description = "ID of the User Assigned Identity to be used by the MySQL Flexible Server"
  type        = string
}

variable "import_existing_diagnostics" {
  description = "Whether to attempt importing existing diagnostic settings"
  type        = bool
  default     = true
}

variable "prevent_diagnostic_settings_deletion" {
  description = "Prevent the destruction of existing diagnostic settings"
  type        = bool
  default     = true
}

variable "diagnostic_setting_name" {
  description = "Name of the diagnostic setting for MySQL Flexible Server"
  type        = string
  default     = "jm-mysql-server-diagnostics"
}