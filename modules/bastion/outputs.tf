output "bastion_host_id" {
  description = "The ID of the Bastion Host"
  value       = azurerm_bastion_host.bastion.id
}

output "public_ip" {
  description = "The public IP of the Bastion Host"
  value       = azurerm_public_ip.bastion.ip_address
}