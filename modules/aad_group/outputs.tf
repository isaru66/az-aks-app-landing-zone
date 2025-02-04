output "group_id" {
  description = "The object ID of the Azure AD group"
  value       = azuread_group.aks_admins.id
}

output "group_object_id" {
  description = "The object ID of the Azure AD group"
  value       = azuread_group.aks_admins.object_id
}

output "group_name" {
  description = "The display name of the Azure AD group"
  value       = azuread_group.aks_admins.display_name
}