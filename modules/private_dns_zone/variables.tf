variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the private DNS zone"
  type        = string
}

variable "virtual_network_id" {
  description = "ID of the virtual network to link with the private DNS zone"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the private DNS zone"
  type        = map(string)
  default     = {}
}