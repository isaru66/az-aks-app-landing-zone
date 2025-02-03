variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "location" {
  description = "The Azure location where the virtual network will be created"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the virtual network"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "The name of the resource group where the subnet will be created"
  type        = string
}