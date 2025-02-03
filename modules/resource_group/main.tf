resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

output "resource_group_id" {
  value = azurerm_resource_group.this.id
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}