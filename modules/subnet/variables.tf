variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network where the subnet will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the subnet will be created"
  type        = string
}

variable "address_prefix" {
  description = "The address prefix for the subnet"
  type        = string
  validation {
    condition     = can(cidrhost(var.address_prefix, 0))
    error_message = "The address_prefix must be a valid CIDR block."
  }
}

variable "delegation" {
  description = "Delegation for the subnet"
  type        = list(object({
    name    = string
    service = string
  }))
  default = []
}

variable "network_security_group_id" {
  description = "The ID of the Network Security Group to associate with the subnet"
  type        = string
}