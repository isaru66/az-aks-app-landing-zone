variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "The location of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the AKS cluster"
  type        = string
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.kubernetes_version))
    error_message = "Kubernetes version must be in the format X.Y.Z"
  }
}

variable "subnet_id" {
  description = "The ID of the subnet for the AKS cluster"
  type        = string
}

variable "dns_service_ip" {
  description = "The DNS service IP for the AKS cluster"
  type        = string
}

variable "docker_bridge_cidr" {
  description = "The Docker bridge CIDR for the AKS cluster"
  type        = string
}

variable "service_cidr" {
  description = "The service CIDR for the AKS cluster"
  type        = string
}

variable "system_node_pool_name" {
  description = "The name of the system node pool"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{1,12}$", var.system_node_pool_name))
    error_message = "System node pool name must be 1-12 lowercase alphanumeric characters"
  }
}

variable "system_node_pool_vm_size" {
  description = "The VM size for the system node pool"
  type        = string
}

variable "system_node_pool_enable_auto_scaling" {
  description = "Enable auto-scaling for the system node pool"
  type        = bool
}

variable "system_node_pool_min_count" {
  description = "The minimum number of nodes for the system node pool"
  type        = number
  validation {
    condition     = var.system_node_pool_min_count >= 1
    error_message = "System node pool minimum count must be at least 1"
  }
}

variable "system_node_pool_max_count" {
  description = "The maximum number of nodes for the system node pool"
  type        = number
  validation {
    condition     = var.system_node_pool_max_count >= var.system_node_pool_min_count
    error_message = "System node pool maximum count must be greater than or equal to minimum count"
  }
}

variable "system_node_pool_os_disk_size_gb" {
  description = "The OS disk size in GB for the system node pool"
  type        = number
}

variable "system_node_pool_zones" {
  description = "The availability zones for the system node pool"
  type        = list(string)
}

variable "work_node_pool_name" {
  description = "The name of the work node pool"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{1,12}$", var.work_node_pool_name))
    error_message = "Work node pool name must be 1-12 lowercase alphanumeric characters"
  }
}

variable "work_node_pool_vm_size" {
  description = "The VM size for the work node pool"
  type        = string
}

variable "work_node_pool_enable_auto_scaling" {
  description = "Enable auto-scaling for the work node pool"
  type        = bool
}

variable "work_node_pool_min_count" {
  description = "The minimum number of nodes for the work node pool"
  type        = number
}

variable "work_node_pool_max_count" {
  description = "The maximum number of nodes for the work node pool"
  type        = number
}

variable "work_node_pool_os_disk_size_gb" {
  description = "The OS disk size in GB for the work node pool"
  type        = number
}

variable "work_node_pool_zones" {
  description = "The availability zones for the work node pool"
  type        = list(string)
}

variable "identity_type" {
  description = "The type of identity for the AKS cluster"
  type        = string
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "Identity type must be either SystemAssigned or UserAssigned"
  }
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  type        = string
  default     = "/subscriptions/16ae6f44-2b54-4372-9d8c-54c8431ad26d/resourceGroups/DefaultResourceGroup-SEA/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-16ae6f44-2b54-4372-9d8c-54c8431ad26d-SEA"
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy for the AKS cluster"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
}

variable "private_cluster_enabled" {
  description = "Enable private cluster for AKS"
  type        = bool
  default     = true
}

variable "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone for private cluster"
  type        = string
}

variable "admin_group_object_ids" {
  description = "AD Group Object IDs that will have admin access to the cluster"
  type        = list(string)
}

variable "network_plugin" {
  description = "The network plugin to use for the AKS cluster"
  type        = string
  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either azure or kubenet"
  }
  default     = "azure"
}

variable "network_policy" {
  description = "The network policy to use for the AKS cluster"
  type        = string
  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be either azure or calico"
  }
  default     = "azure"
}

variable "sku_tier" {
  description = "The SKU tier for the AKS cluster"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "SKU tier must be either Free or Standard"
  }
}

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for the AKS cluster"
  type        = string
  default     = "stable"
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    allowed = list(object({
      day   = string
      hours = list(number)
    }))
    not_allowed = list(object({
      end   = string
      start = string
    }))
  })
  default = null
}

variable "enable_defender" {
  description = "Enable Microsoft Defender for Containers"
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable workload identity"
  type        = bool
  default     = true
}

variable "enable_oidc_issuer" {
  description = "Enable OIDC issuer"
  type        = bool
  default     = true
}

variable "api_server_authorized_ip_ranges" {
  description = "The IP ranges to allow for incoming traffic to the server nodes"
  type        = list(string)
  default     = null
}

variable "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  type        = string
  default     = "aks-diagnostics"
}

variable "enable_prometheus" {
  description = "Enable Azure Managed Prometheus"
  type        = bool
  default     = true
}

variable "drain_timeout_in_minutes" {
  description = "The amount of time to wait before forcefully draining/deleting a node during maintenance"
  type        = number
  default     = 20
}

variable "max_surge" {
  description = "The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade"
  type        = string
  default     = "25%"
}

variable "node_soak_duration_in_minutes" {
  description = "The duration to wait after each node upgrade before continuing with the next node upgrade"
  type        = number
  default     = 10
}
